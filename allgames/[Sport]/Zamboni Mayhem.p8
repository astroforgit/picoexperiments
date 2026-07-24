pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- zamboni mayhem
-- by andy

-- Cool features:
-- Dynamic Music - specific music queues when the zamboni shows up and when you die.
-- Randomized sprites - skin and scarf colors are randomized when the game starts.
-- Attract Screen - some of the time the attract screen skater skates backwards, or is replaced by the zamboni driver.

-- changelog:
-- 2020-11-24 Beta 0.92		Paralax scrolling implemented with modulo math!
-- 2020-11-24 Beta 0.91		High score implemented and return to new game/title screen fixed.
-- 2020-11-21 Beta 0.90		Static/zamboni hahaha rendering.  Buggy new game.
-- 2020-06-10 Alpha 0.81	Static/zamboni hahaha rendering.  Buggy new game.
-- 2020-06-07 Alpha 0.8		Increasing zamboni speed and zamboni collision detection.  Zamboni goes faster with increasing difficulty.
-- 2020-06-05 Alpha 0.7		Working enemy zamboni driver.  No colision dectection.
-- 2020-06-03 Alpha 0.62 	Refined score bonuses.
-- 2020-06-03 Alpha 0.61	Updating the score algorithm.
-- 2020-06-03 Alpha 0.6		Endless obstacles and increasing difficulty.
-- 2020-05-23 Alpha 0.51	Updates to attract mode.  Drew a zamboni.
-- 2020-05-22 Alpha 0.5 	Obstacles can only be tripped over a single time.  You get a random scarf and skin color when you start the game.  Pretty slick attract mode.
-- 2020-05-19 You can brake like Wayne Gretsky and when you collide, objects are pruned.
-- 2020-05-12 Obstacle generation and placement tests.
-- 2020-05-07 Tech alpha 2.  Added music and fixed the crash bug.
-- 2020-05-07 Tech alpha? Three sick frames of animation, random SFX and a crash if you hit the top or bottom of the screen.

-- to do list
-- ice trail for the zamboni
-- check to reset the zamboni if he passes the skater instead of ending the game.
-- bonus indicator sprites shown for the multiplier.
-- barriers - Done!
-- scrolling barriers - done!
-- paralax scrolling on the barriers - Done!
 

function _init()
	difficulty = {25, 50, 75, 100, 125, 150, 175, 200, 250, 300}
	versionstring = 'zamboni mayhem beta 0.92'
	--instructions = '”ƒ + ‘ - skate\n‹ brake\n— spawn extra object'
	instructions = '”ƒ + ‘ - skate\n‹ brake'
	mode = 'title'	-- valid modes are title, game1, gameover
	sparks = {}		-- table of particle effects including hahah.
	obs = {}
	obstacles = {}	-- table of obstacles that need to be moved and updated including cones, barriers, and enemy zambonis.
	obstacle_sprites = {60, 61, 62, 63}
	zamboni = {}	-- check to see if the zamboni driver has started.
	zamboniarrives = 2	-- difficulty level the zamboni driver starts chasing you
	nextmusic = {}
	highscore = 0			-- initializes high score
	barriertop_y = 21		-- top barrier constant.  Effects playfield width.
	barrierbottom_y = 106	-- bottom barrier constant
	barrier_offset = 3		-- offset for barrier sprite clamping.
	barrier_slide = -3		-- offset to make the bottom barriers look different
	barrier_top_scroll = .75
	barrier_bottom_scroll = 1.25
		
	gameover = {
		texty = 32,
		textx = 1,
		text = {'game over', '\npush x or z to play again'},
		
		draw = function(self)	-- gameover mode draws.
			print(self.text[1], 64-#self.text[1]*2, self.texty, 8)
			print(self.text[2], 64-#self.text[2]*2, self.texty, 8)
		end,	-- end of gameover draw.
		
		update = function(self)
			if (btnp(4) or btnp(5)) then
				del(zamboni, zamboni[1])	-- drop the zamboni
				skater:reinit()				-- reset the skater
				nextmusic = {}				-- empty the music queue
				music(-1)					-- kill music
				mode = 'title'	-- set the game mode to 'title' if a button is pushed.

			end
		end,	-- end of gameover update.
		
		reinit = function(self)		-- reset behavior.
			self.texty = 32
			self.textx = 1
		end,	-- end of gameover reinit.
		
	}	-- end of gameover table
	
	skater = {
		score = 0,
		scoreconstant = 25,
		bonusfactor = 1,
		bonustable = {1, 1.25, 1.5, 2, 3},
		bonustable_sprite = {17, 18, 19, 20, 21},
		bonusconstant = 15,
		bonusdistance = 0,
		distance = 0,
		level = 1, -- value for keying into the difficulty table
		cameraoffset = -40,		-- offset for the camera for skater space.
		
		crashed = false,				-- false means you can skate, true means you are crashed and sliding and inputs are disabled.
		crashed_cooldown_const = 180,	-- frames of waiting after crashing.
		crashed_counter = 0,			-- frames remaining of crashed state.
		
		x = 0,					-- skater initial position.
		y = 64,					-- skater initial position.
		ay = 0.0125,			-- skater acceleration constants.
		ay_decay = 0.003,		-- y friction.
		ax = 0.3,				-- skater burn (right is +)
		ax_brake = 0.0125,		-- skater braking value.
		ax_decay = -0.0075,		-- speed "friction" decay (- left)
		ax_overspeed = .010,
		braking = false,
		vx = 0,					-- Skater velocity.
		vy = 0,
		vxmax = 1,			-- max speed
		vymax = 1,			-- max speed
		
		-- animation sprite sheet values
		framenumber = 1,
		skaterframes = {48, 49, 48, 50},
		brakeframe = 51,
		skatesfx = {16, 17, 18, 19},
		crashframe = 52,
		
		-- cosmetic tables.
		-- scarfcolornumber = rnd(scarfchoices), -- reminder: can't do math in a table initialization
		scarfchoices = {1, 2, 3, 4, 6, 8, 9, 10, 11, 13, 15},		
		scarfcolornumber = 9,

		skinchoices = {4, 15},
		skincolornumber = 15,
		
		reinit = function(self)	-- reinitialize the skater.
			self.score = 0
			self.bonusfactor = 1
			self.distance = 0
			self.bonusdistance = 0
			self.level = 1				-- value for keying into the difficulty table
			self.crashed = false
			self.crashed_counter = 0	-- frames remaining of crashed state.
			self.x = 0					-- skater initial position.
			self.y = 64					-- skater initial position.
			self.braking = false
			self.vx = 0					-- Skater velocity.
			self.vy = 0
			self.framenumber = 1
		end, -- end of skater reinit
		
		update = function(self)
			-- look for collisions between the skater and the obstacles.
			for ob in all(obstacles) do
				if self:check_for_obstacle_collision(ob) and ob.tripped == false then
					-- Do all of my obstacle manipulation
					-- Add velocity, etc.
					-- set the skater crashed to true.
					self.crashed = true
					self.crashed_counter = self.crashed_cooldown_const
					-- ob.x = -8 -- test/debug to just move the object off screen and prune it.
					ob.tripped = true -- set the obstacle you tripped over to true so you won't keep tripping.
				end
								
			end
						
			-- be sure that crashed is always set to disable controlls when gameover.
			if (mode == 'gameover') self.crashed=true
			
			-- disable controls when crashed.
			if btn(0) and not self.crashed then		-- left button check - braking behavior
				self.braking = true
				
				if self.vx > 0 then
					sfx(self.skatesfx[flr(rnd(4)+1)])	-- play a random SFX from the SFX table
					add_brakesparks(self.x, self.y)			-- generate a brakespark
					add_brakesparks(self.x, self.y)			-- generate a brakespark

				end

				-- animation	
				if self.framenumber == #self.skaterframes then	-- check to see if you're at the last frame.
					self.framenumber = 1			-- if so, go back to the beginning
				else
					self.framenumber += 1		-- otherwise, add a frame number
				end
				
				-- motion
				self.vx = self.vx - self.ax_brake	-- add in the accl, right is positive
				
				if self.vx > self.vxmax then		-- check to see if we are at max speed. right is pos
					self.vx = self.vxmax			-- saturate with vymax
				end
			
			else
				self.braking = false
			end -- end of left brake button check.
			
			-- if not self.crashed then  -- if you're crashed, disable controls.
			-- if not self.crashed and btnp(1) then		-- right button check
			if btnp(1) and not btn(0) and not self.crashed then		-- right button check
			
				sfx(self.skatesfx[flr(rnd(4)+1)])	-- play a random SFX from the SFX table
				add_sparks(self.x, self.y)			-- generate a spark
				add_sparks(self.x, self.y)			-- generate a spark

				-- animation	
				if self.framenumber == #self.skaterframes then	-- check to see if you're at the last frame.
					self.framenumber = 1			-- if so, go back to the beginning
				else
					self.framenumber += 1		-- otherwise, add a frame nubmer
				end
				
				-- motion
				self.vx = self.vx + self.ax			-- add in the accl, right is positive
				
					if self.vx > self.vxmax then		-- check to see if we are at max speed. right is pos
						self.vx = self.vxmax			-- saturate with vymax
					end
					
					
			else									-- if right isn't pushed
				self.vx = self.vx + self.ax_decay	-- apply decay acceleration
				if self.vx < 0 then					-- check to see if we are going backwards.
					self.vx = 0						-- saturate to 0.
				end
				
			end -- end of right button check.
						
			---- add to the obstacle table.  Debugging mostly.
			-- if btnp(4) or btnp(5) then
-- --				add_obstacle(obstacle_sprites[1], skater.x, skater.y)
				-- pick_obstacles(2)
				-- -- add_obstacle(rnd(obstacle_sprites), skater.x, skater.y)
			-- end
			
			-- y motion behavior
			if (btn(2) or btn(3)) and not self.crashed then -- y axis behavior
				if btn(2) then			-- up button 
					self.vy -= self.ay
					-- sfx(0)
					if self.vy < -self.vymax then
						self.vy = -self.vymax
					end
				end
												
				if btn(3) then			-- down button 
					self.vy += self.ay
					-- sfx(0)
					if self.vy > self.vymax then
						self.vy = self.vymax
					end
				end
			else	-- if up or down aren't pressed, apply decay physics
				if abs(self.vy) < abs(self.ay_decay) then
					self.vy = 0
				elseif self.vy > 0 then
					self.vy -= self.ay_decay
				elseif self.vy < 0 then
					self.vy += self.ay_decay
				end
			end -- end of y-motion button checks

			-- Update the positions
			self.y += self.vy
			self.x += self.vx
			
			-- -- clamp to the playfield edges based on the barrier locations
			if self.y <= barriertop_y+barrier_offset then
				self.y = barriertop_y+barrier_offset
				-- self.ay = 0  -- Note to future programer, yeah, don't change the acceleration constant.
				self.vy = 0
			end
			if self.y > barrierbottom_y-barrier_offset then
				self.y = barrierbottom_y-barrier_offset
				self.vy = 0
			end
						
			if self.crashed == true and not(mode=='gameover') then  -- crash reset behavior.
				if (self.vx > 0) then 					-- if still moving forward
					add_brakesparks(self.x, self.y)		-- generate a brakespark
				end
				
				-- reset the bonus
				self.bonusfactor = 1
				self.bonusdistance = 0
				
				self.crashed_counter -= 1		-- Reduce the crash counter
				 -- once the crash counter hits 0 stand up, but only if the game1 mode is still running.
				if self.crashed_counter == 0 and mode=='game1' then
					self.crashed = false
				end
			end
		
			-- Scoring and difficulty
			-- Distance for difficulty increasing
			self.distance = self.x/self.scoreconstant
			
			-- check to see if you need to spawn a zamboni
			-- will only add a zamboni if the table is empty.
			if self.level == zamboniarrives and #zamboni == 0 then
				-- spawn a zamboni behind the skater.
				add_enemyzamboni(self.x-100, 64)
				--hahaha(self.x, self.y, 120)	-- add a new hahaha.
				hahaha(2, self.y-8, 120, true)	-- add a new hahaha.
				--queuemusic(24) -- enqueue sinister music
				--queuemusic({24, 5}) -- enqueue sinister music
				add(nextmusic, 24)
				add(nextmusic, 5)
				
			end
			
			-- Accumulate bonus distance by integrating velocity.
			self.bonusdistance = self.bonusdistance + self.vx / self.scoreconstant

			if self.bonusdistance > self.bonusconstant then -- increase the bonus level if you go past the distance without hitting an object.
				self.bonusdistance = 0 -- reset the bonus distance
				
				if (self.bonusfactor < #self.bonustable) self.bonusfactor+=1 -- and increae the factor
			
			end

			-- Scoring
			-- score is accumulated by integrating velocity every tick multiplying by the bonus table, the factor and dividing by the constant
			-- flr() is taken at the display side to show a whole number.
			self.score = self.score + (self.vx * self.bonustable[self.bonusfactor])/self.scoreconstant
			
		end, -- skater update end.
		--
		-- skater collision detection
		check_for_obstacle_collision = function(self, obj)
			return circle_check(self.x, self.y, 6, obj.x, obj.y, 7)
		end, -- end of check_for_obstacle_collision

		draw = function(self)
			set_zm_pal()
			
			-- put in the color mask for cosmetics here.  Clear it below.
			pal (11, self.scarfcolornumber)		-- scarf color pallete swap - swap hardcoded 7 green for the selected one.
			pal (15, self.skincolornumber)		-- skin color pallete swap - swap hardcoded 15 peach for the selected one.
						
			-- spr(n, x, y, w, h, flipx, flipy)
			if not(mode == 'gameover') then
				if self.crashed == true then		-- first see if you crashed.
					spr(self.crashframe, self.x, self.y, 1, 1, false, false)
				elseif self.braking == true then 	-- then see if you're braking.
					spr(self.brakeframe, self.x, self.y, 1, 1, false, false)
				else								-- otherwise, animate.
					-- draw the sprite on the screen, the frame number indexes every time you push right/btn1.
					spr(self.skaterframes[self.framenumber], self.x, self.y, 1, 1, false, false)
				end
			elseif mode == 'gameover' then
				spr(self.crashframe, self.x, self.y, 1, 1, false, false)
			end
			set_zm_pal() -- clear the color palette swaps here.
		end,
		
	}	-- skater close brace
	
	titlescreen = {
		framenumber = 1,		-- animation frame number
		skaterframes = {48, 49, 48, 50},	-- animation frames from sprite sheet.
		backward_prob = 0.35,	-- probability the skater skates backward on the title screen.
		skaterflip = false,		-- flipped state of the title screen skater.
		zamboni_prob = 0.25,	-- probability of a zamboni on the title screen.
		zambonidriver = false,	-- flipped state of the zamboni on title screen.
		-- brakeframe = 51,
		-- skatesfx = {16, 17, 18, 19},
		-- crashframe = 52,
		
		x = -8,
		y = 64,
				
		draw = function(self)
			set_zm_pal()	-- set the standard zamboni pallette
			camera()		-- reset the camera to static screen space
			rectfill(0, 0, 128, 128, 12)	-- icy background
			print(' zamboni mayhem', 0, 1, 8)
			print(' press x or z to start game', 0, 7, 8)
			print('high score: '.. flr(highscore), 40, 121, 7)
			drawbarriers(0,barriertop_y)	-- draw top barriers
			drawbarriers(0+barrier_slide,barrierbottom_y)	-- draw bottom barriers
			
			if self.zambonidriver == true then
				spr(64, self.x, self.y, 4, 4, false, false) -- draw a zamboni
				spr(68, self.x, self.y, 2, 2, false, false) -- draw a head
			else
				pal (11, skater.scarfcolornumber)		-- scarf color pallete swap - swap hardcoded 7 green for the selected one.
				pal (15, skater.skincolornumber)		-- skin color pallete swap - swap hardcoded 15 peach for the selected one.
				spr(self.skaterframes[self.framenumber], self.x, self.y, 1, 1, self.skaterflip, false) -- draw a skater
				pal()
			end
			
			for s in all(sparks) do 
				s:draw()
			end
			
		end,
		
		update = function(self)
			if (stat(24) == -1) music(0) -- if music is not playing, start the music.

			-- skater animation and frames
			if (t()%.5 == 0) and not self.zambonidriver then -- every half second a skater is on the screen...
				self.framenumber+=1			-- increment the frame
				add_sparks(self.x, self.y)	-- add some sparks.
				add_sparks(self.x, self.y)
			elseif self.zambonidriver then		-- if the zamboni is driving
				add_sparks(self.x, self.y+24)	-- offset the zamboni's sparks.
			end
			
			for s in all(sparks) do 
				s:update()
			end
			
			if (self.framenumber > #self.skaterframes) self.framenumber = 1
			
			
			if self.x > 128 then -- reset the skater when it hits the edge of the screen.
				-- make the skater skate backwards a certain percentage of the time.
				if (rnd()<self.zamboni_prob) then
					self.zambonidriver = true
				else
					self.zambonidriver = false
				end				
				
				-- make the skater skate backwards a certain percentage of the time.
				if (rnd()<self.backward_prob) then
					self.skaterflip = true
				else
					self.skaterflip = false
				end
				
				self.y = rnd(64)+32		-- get a new y
				self.x = -32			-- move back off the screen.
				skater.scarfcolornumber = rnd(skater.scarfchoices)	-- pick a random scarf color
				skater.skincolornumber = rnd(skater.skinchoices)	-- pick a random scarf color
			else
				self.x += .5
			end	
			
			if (btnp(4) or btnp(5)) then	-- button check on the main title
				mode = 'game1'	-- shut down the title screen.
--				music(-1, 200)	-- stop the music playing
				music(5)		-- main BKG music
				--hahaha(-38, 30, 60)	-- call the hahaha.
				hahaha(1, 30, 60, true)	-- call the hahaha.
				-- sfx(20)			-- ha ha ha 
				
				pick_obstacles(7)  -- spawn some initial obstacles.
							
				-- for i = 1, 5 do -- spawn some initial obstacles
					-- add_obstacle(rnd(obstacle_sprites), rnd(124), rnd(124))
				-- end
				
				skater.scarfcolornumber = rnd(skater.scarfchoices)	-- pick a random scarf color
				skater.skincolornumber = rnd(skater.skinchoices)	-- pick a random scarf color
				
			end -- end of button check for title screen
			
		end, -- end of update
	} -- title close brace
	
end -- end of _init()

function pick_obstacles(n)
		for i = 1, n do
			add_obstacle(rnd(obstacle_sprites), skater.x+128+rnd(256), rnd(barrierbottom_y-barriertop_y-8)+barriertop_y+8)
		end
--	return obs
end

function circle_check(x1, y1, r1, x2, y2, r2)
	local dx = mid(-50, x1-x2, 50)
	local dy = mid(-50, y1-y2, 50)
	return (dx^2+dy^2 < r1^2+r2^2)
end

function add_enemyzamboni(x, y)
	add(zamboni,{
		vx = {.4, .5, .6, .7, .8, .9, 1, 1.1, 1.2, 1.3},		
		vy = .125,
		x = x,
		y = y,
		yoffset = 16,
		xoffset = 32,
		trucksprite = 64,
		winksprites = {68, 72},
		winkframe = 1,
		winkconstant = 20,
		winktimer = 0,
		r = 16,
		deadband = 10,
		
		draw = function(self)
			set_zm_pal()
			spr(self.trucksprite, self.x, self.y, 4, 4)
			
			if self.x + self.xoffset < skater.x then	-- check to see if you're behind the skater.
				spr(self.winksprites[1], self.x, self.y, 2, 2)	-- draw a regular non-winking head.
			else	-- if you're in front of the skater
				spr(self.winksprites[self.winkframe], self.x, self.y, 2, 2) -- wink the driver
			end
			
		end,	-- end of draw enemyzamboni
		
		update = function(self)
			if (self.y+self.yoffset < skater.y and abs(self.y+self.yoffset - skater.y) > self.deadband) self.y += self.vy	-- zamboni high? go down.
			--if (self.y+self.yoffset > skater.y) self.y -= self.vy	-- zamboni low?  go up.
			if (self.y+self.yoffset > skater.y and abs(self.y+self.yoffset - skater.y) > self.deadband) self.y -= self.vy	-- zamboni low?  go up.
			
			self.x += self.vx[skater.level]	-- go forward no matter what.
			
			add_sparks(self.x, self.y+24)	-- offset the zamboni's sparks.
			
			-- enemy driver frame cycling.
			self.winktimer += 1
			if self.winktimer > self.winkconstant and (self.x+self.xoffset) > skater.x then
				self.winktimer = 0				
				if self.winkframe == #self.winksprites then
					self.winkframe = 1
				else
					self.winkframe += 1
				end
			end
			
			--function zamboni_collision(zam_x, zam_y, skater_x, skater_y)
			if (zamboni_collision(self.x, self.y, skater.x, skater.y)) then
				mode = 'gameover'
				
				if (skater.score > highscore) highscore = skater.score
				
			end
				
		end,	-- end of update enemyzamboni
	
	}	-- end of enemyzamboni table
	)	-- end of add()
end -- end of add enemy zamboni

function add_obstacle(spriteid, x, y)
	add(obstacles,{
		spriteid = spriteid,
		x = x,
		y = y,
		tripped = false, -- bool to make sure you don't get stuck on an obstacle.
		
		draw = function(self)
			set_zm_pal()
			spr(self.spriteid, self.x, self.y)	-- draw the type based on the sprite index.
		end,
		
		update = function(self)
			if (self.x < skater.x-64) then	-- pruning dropped obstacles when the are off the edge of the screen.
				del(obstacles, self)		-- delete the now-passed obstacle from the table.
				pick_obstacles(1)			-- replace it with a new one.
				
				-- check to see if we need to increase the level
				if skater.distance > difficulty[skater.level] and (skater.level ~= #difficulty) then  -- don't go in if you're on the last level.
					pick_obstacles(1)	-- spawn an additional obstacle.
					if (skater.level < #difficulty) skater.level +=1  -- increase the difficulty level
				end
				
				--pick_obstacles(1+flr(skater.score/25)) -- geometrically increasing difficulty.
			end
		end,
			

	} -- table end
	) -- add to table end.

end  -- obstacles function end

showstats = function()
--			print(' bonus dist: '.. skater.bonusdistance, 0, 60, 7)
--			print('bonus level: '.. skater.bonusfactor, 0, 66, 7)

--			print('obs: '.. #obstacles, 0, 105, 4) -- Length of obstacles table
--			print('crash: '.. tostr(skater.crashed), 0, 111, 4) -- crashed status
--			print('  y: '.. skater.y, 0, 111, 4) -- skater y position
--			print('  x: '.. skater.x, 0, 117, 4) -- skater x position
--			print('  y: '.. skater.y, 0, 123, 4) -- skater y position
			-- print('cpu: '.. flr(stat(1)*100), 100, 117, 4)	-- cpu
			-- print('fps: '.. flr(stat(7)), 100, 123, 4) 		-- fps
			-- print(mode, 100, 111, 4)	-- game mode
end -- end of showstats


function add_sparks(x, y)
	add(sparks,{
		name = spark,
		x = x+3,
		y = y+7,
		vx = rnd(1)-1,
		vy = (-rnd(2))+.5,
		ay = .025,
		life = 200,
		cooltimer = 99,
		coolconstant = 10,
		cooled = 0,
		
		draw = function(self)
			if (mode!='title') camera(skater.x+skater.cameraoffset, 0)	-- draw in skater camera space unless you're on the title screen.

			if self.cooled == 0 then
				pset(self.x, self.y, 7)
			elseif self.cooled == 1 then
				pset(self.x, self.y, 1)
			end
		end,
		
		update = function(self)
			self.vy = self.vy+self.ay
			self.x = self.x+self.vx
			self.y = self.y+self.vy
			
			self.cooltimer -=1
			
			if (self.cooltimer % self.coolconstant) == 0 then
				self.cooled += 1
			end
						
			self.life -=1
			
			if (self.life <0) or (self.y > 138) or (self.y > 129) or (self.y < -1) then
				del(sparks, self)
			end
			
		end,
		}
		)
end

function add_brakesparks(x, y)
	add(sparks,{
		name = brake,
		x = x+7,
		y = y+7,
		vx = rnd(1)+1,
		vy = (-rnd(2.5))+1,
		ay = .05,
		life = 200,
		cooltimer = 99,
		coolconstant = 10,
		cooled = 0,
		
		draw = function(self)
			camera(skater.x+skater.cameraoffset, 0)	-- draw in skater camera space
			if self.cooled == 0 then
				pset(self.x, self.y, 7)
			elseif self.cooled == 1 then
				pset(self.x, self.y, 1)
			end
		end,
		
		update = function(self)
			self.vy = self.vy+self.ay
			self.x = self.x+self.vx
			self.y = self.y+self.vy
			
			self.cooltimer -=1
			
			if (self.cooltimer % self.coolconstant) == 0 then
				self.cooled += 1
			end
						
			self.life -=1
			
			if (self.life <0) or (self.y > 138) or (self.y > 129) or (self.y < -1) then
				del(sparks, self)
			end
			
		end,
		}
		)
end



function drawscore()
	print('score: '..flr(skater.score)..' bonus x'..tostr(skater.bonustable[skater.bonusfactor]), 2, 8, 7)	-- score display
	print('\nzamboni gear: '..skater.level)			-- difficulty level
	
	
	-- Original
	--print('skater 1\nscore: '..flr(skater.score), 2, 8, 7)	-- score display
	--print('\n\nzamboni gear: '..skater.level..' bonus x '..tostr(skater.bonustable[skater.bonusfactor]))			-- difficulty level
end

-- called on line 259 to change the music.  Currently bugged.
--[[
function queuemusic(pattern)
	--for p in all(pattern) do
	add(nextmusic,{
		pattern = pattern,
				
		update = function(self)
			if #nextmusic == 0 then	-- if nothing is queued in the next pattern:
			-- do nothing if the table is empty.
			else	-- if the table isn't empty
				--stop()
				if (stat(24) == 5 or stat(24) == 26) and (stat(20) == 31) then
					music(self.pattern)
					--music(self.nextmusic[1])
					del(nextmusic, self)
					--del(nextmusic, self[1])
				else
				end
			end
		end
	}
	)
	--end
end
--]]

--
function updatemusic()
	if #nextmusic == 0 then	-- if nothing is queued in the next pattern:
		-- do nothing if the table is empty.
	else	-- if the table isn't empty
		--stop()
		if (stat(24) == 5 or stat(24) == 26 or stat(24) == 34) and (stat(20) == 31) then
			music(nextmusic[1])
			--music(self.nextmusic[1])
			del(nextmusic, nextmusic[1])
			--del(nextmusic, self[1])
		else
		end
	end
end -- end of update music function.
--]]

function set_zm_pal()	-- configures standard Zamboni Mayhem pallete transparency
		-- Blue transparent, black opaque.
		palt(12, true)
		palt(0, false)
end

function hahaha(x, y, life, static)
	-- number, number, number, bool.
	add(sparks,{
	name = hahaha,
	x = x,	-- x pos
	y = y,	-- y pos
	life = life,	--time to live in frames
	static = static,	-- true/false.  If true, hahaha renders in static screen space instead of zamboni space.
	zam_y_offset = -18,
	t = 0,			-- life timer
	soundplayed = false,	-- SFX bool.
	
	draw = function(self)
		set_zm_pal()	-- standard pallete clear
		
		if (self.static == true) camera()	-- static being true clears the camera and renders it in screen space.
		
		spr(102, self.x, self.y, 2, 2) -- sprite 102 2x2 width
		
	end,
	
	update = function(self)
		if (self.soundplayed == false) then -- play the sfx the first time through the loop
			sfx(20)	-- play the ha ha ha sfx.
			self.soundplayed = true
		end
		
		-- check to see which camera space we're in
		if self.static==false then	-- we're in Zamboni space, so update the values.
			self.x = zamboni[1].x	-- move the x
			self.y = zamboni[1].y - self.zam_y_offset	-- move the y along with an offset.
		end
		
		self.t +=1		
		if (self.t == self.life) del(sparks, self)
		
	end,
	
	}	-- close the table add.
	)	-- end of hahaha's add
end	--end of hahaha

function zamboni_collision(zam_x, zam_y, skater_x, skater_y)
	-- square collision zone.  Takes the zamboni coordinates and the skater's coordinates.
	-- first check x.
	-- then check  that y is in between the width of the zamboni.
	return (zam_x+32 > skater_x) and (skater_y > zam_y) and (skater_y < zam_y+30)
end

function drawbarriers(x, y)
	-- draws some barricades that are assured to span an entire screenwidth
	-- takes x and y as the location to start drawing.
	-- sprite sheet location and width are fixed magic numbers
	set_zm_pal()	-- Standard ZM pallette
	local width = 32			-- sprite width in sprites
	local barrierspriteid = 32	-- sprite sheet location
	
	for i = 0, 4 do
		spr(barrierspriteid, x+width*i, y, 4, 1)
	end

end


-- update and draw loops

function _update60()
		
	if mode == 'title' then		-- check to see if in titlescreen

		titlescreen:update()

	elseif mode == 'game1' then		-- main game loop update
		skater:update()
		for s in all(sparks) do 
			s:update()
		end
		
		for o in all(obstacles) do 
			o:update()
		end
		
		if #zamboni > 0 then	-- draw zambonis if they exist.
			for z in all(zamboni) do
				z:update()
			end
		end
		
		updatemusic()
	
	elseif mode == 'gameover' then
		-- check to see if one of the game over patterns is playing (32, 33, or 34).
		-- if something other than those patterns is playing, enquue the gameover pattern if it's empty.
		if (#nextmusic == 0 and not(stat(24) == 32 or stat(24) == 33 or stat(24) == 34)) add(nextmusic, 32) 
		updatemusic()
		
		if #zamboni > 0 then	-- update zambonis if they exist.
			for z in all(zamboni) do
				z:update()
			end
		end
		
		--hahaha(zamboni[1].x, zamboni[1].y, 120)	-- add a hahaha.		
		-- update sparks
		for s in all(sparks) do 
			s:update()
		end
		
		-- special block for end of game behavior.
		gameover:update()
			
	end

end

function _draw()
	if mode == 'title' then 	-- check to see if in titlescreen
		showstats()		-- enable debugs
		cls()
		titlescreen:draw()
			
	elseif mode == 'game1' or mode == 'gameover' then		-- main game loop draw.	
		set_zm_pal()
		cls()
--		fillp(0b0010000100000000)	--ice surface
--		rectfill(0, 0, 128, 128, 0x51)		-- background - filled
--		fillp(0)
		rectfill(0, 0, 128, 128, 12)		-- background - plain
		

-- main draw for skater and objects
				
		--draw the barriers
	
		-- Fixed barrier code
		-- camera() 	-- do this in screen coordinates
		-- drawbarriers(0, barriertop_y)	
		-- drawbarriers(0+barrier_slide, barrierbottom_y)	-- draw bottom barriers
		
		-- Scrolling barrier code.
		-- mod arithmetic on the X argument goin ginto the draw barriers.
		camera() 	-- do this in screen coordinates
		drawbarriers(-(barrier_top_scroll * skater.x % 32), barriertop_y)	

--		Moved to the bottom
--		drawbarriers(-((barrier_bottom_scroll * skater.x - barrier_slide) % 32), barrierbottom_y)	-- draw bottom barriers
				
		camera(skater.x+skater.cameraoffset, 0)  -- camera offset for centering the skater in frame.		
		for o in all(obstacles) do 
			o:draw()
		end
		
		skater:draw()
		
		for s in all(sparks) do 
			s:draw()
		end
		
		camera(skater.x+skater.cameraoffset, 0)	-- draw in skater camera space
		if #zamboni > 0 then	-- draw zambonis if they exist.
			for z in all(zamboni) do
				z:draw()
			end
		end
		
		camera()
		drawbarriers(-((barrier_bottom_scroll * skater.x - barrier_slide) % 32), barrierbottom_y)	-- draw bottom barriers
		drawscore()

		print(versionstring, 64-#versionstring*2, 1, 8)
		print(instructions, 1, 116, 8)
		--showstats()				-- debugs
		
	end -- end of draw case if checks.
	
	-- special block for end of game behavior.
	if mode == 'gameover' then
		gameover:draw()
	end

end	-- end of _draw
__gfx__
00000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000097f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a777e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc7777ccccccccccccccccccccccccccccccccccc888888ccc8ccccc000000000000000000000000000000000000000000000000000000000000000000000000
c777777cccccccccccccccccccccccccccc77ccc88877888c88ccccc000000000000000000000000000000000000000000000000000000000000000000000000
77766777cccccccccccccccccccaaccccc7aa7cc887aa788c88ccccc000000000000000000000000000000000000000000000000000000000000000000000000
77666677ccccccccccccccccccaaaaccc7aaaa7c87aaaa78c88ccccc000000000000000000000000000000000000000000000000000000000000000000000000
77666677cccccccccc9999ccca9999ac7a9999a77a9999a7cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
77766777ccccccccc999999ca999999aa999999aa999999a88cccccc000000000000000000000000000000000000000000000000000000000000000000000000
c777777cc666666c9666666996666669966666699666666988cccccc000000000000000000000000000000000000000000000000000000000000000000000000
cc7777cc6666666666666666666666666666666666666666cccccccc000000000000000000000000000000000000000000000000000000000000000000000000
cc8888cccccccccccccccccccccccccccc8888cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc88cccccccccccccccccccccccccccccc88ccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa8988aaaaccccccccccccccccccccaacc8988cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc9889ccccaaaaaaaaaaaaaaaaaaaacccc9889cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc8898cccccccccccccccccccccccccccc8898cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc8988cccccccccccccccccccccccccccc8988cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc9889cccccccccccccccccccccccccccc9889cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000cccccccccccccccccccccccccc000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cceeeeecceeeeeccceeeeeccceeeeecccccccccccccccccccc8888cc00000000000000000000000000000000c88cccc8cccccccccccccccc771cc117cc77c7cc
ceeeefeeeeeefeeceeeefeeceeeefeecccccccccccccccccccc88ccc00000000000000000000000000000000cc8cccc8cccccccccccaaccc17711771c711717c
cef1ff1eef1ff1ecef1ff1ecef1ff1eccbcceeec88998899cc8988cc00000000000000000000000000000000998cccc899889988cccaacccc117171cc7171117
ceeffffeeeffffeceeffffeceeffffec5cbeeeee98899889cc9889cc000000000000000000000000000000008998ccc889988998cca99accccc171cc71111717
ceebbbecbebbbecceebbbecceebbbecc5ebe1fee99889988cc8898cc00000000000000000000000000000000889ccc9888998899ca9999ac1177171cc7111117
ccb777cccb777cccbb777cccccb777cc557bfffe89988998cc8988cc000000000000000000000000000000009889cc8998899889ca9999ac777117717117117c
cbce5e5c5eccecccccecce5ccbcce5e5ce7bff1ec0cccccccc9889cc00000000000000000000000000000000cc9acc9ccccaccccca8888ac111cc171c7117717
cc55c55c55cc555cc555c55cccc55c55555efeec0c0cccccc000000c00000000000000000000000000000000ccacacc9ccacacccaaaaaaaacccccc17cc77cc7c
cccccccccccccccccccccccccccccccccccccc444444c44ccccccc444444c44ccccccc444444c44ccccccc444444c44ccccccc444444c44ccccccc444444c4cc
ccccccccccccccccccccccccccccccccccccc44fffff4cccccccc44fffff4cccccccc44fffff4cccccccc44fffff4cccccccc44fffff4cccccccc44fffff4c4c
cccccccccccccccccccccccccccccccccccc4ffffffffccccccc4ff444f4fccccccc4ff444f4fccccccc4ffffffffccccccc4ffffffffccccccc4ffffffffc4c
cccccccccccccccccccccccccccccccccccc4ff444f4fccccccc4ff4ff4f4ccccccc4ff4ff4f4ccccccc4ff444f4fccccccc4ff444f4fccccccc4ffff4f4fccc
cccccccccccccccccccccccccccccccccccc4ff4ff4f4ccccccc4ffffffffccccccc4ffffffffccccccc4ff4ff4f4ccccccc4ff4ff4f4ccccccc4fff4fff4ccc
ccccccccccccccccccc77ccccccccccccccff4fff0f0cccccccff4fff0f0cccccccff4fff0f0cccccccff4fff0f0cccccccff4fff0f0cccccccff4f4f0f0cccc
cccccccccccccccccc7667cccccccccccccfe4fffffffffccccfe4fffffffffccccfe4fffffffffccccfe4fffffffffccccfe4fffffffffccccfe4fffffffffc
ccccccccccccccccc76667ccccccccccccccf4f44444ffffccccf4f44444ffffccccf4ffffffffffccccf4f44444ffffccccf4f44444ffffccccf4ffffffffff
ccccccccccccccccc766667cccccccccccccc44470704ffcccccc44470704ffcccccc44444444ffcccccc44470704ffcccccc44470704ffcccccc44444444ffc
cccccccccccccccc7666667cccccccccccccc44070704cccccccc44070704cccccccc44470704cccccccc44070704cccccccc44070704cccccccc44470704ccc
cccccccccccccccc76666667cccccccccccccc444444cccccccccc444444cccccccccc444444cccccccccc444444cccccccccc444444cccccccccc444444cccc
ccccccc88888888888886667ccccccccccccccc888888888ccccccc888888888ccccccc888888888ccccccc888888888ccccccc888888888ccccccc888888888
ccccc888888888888888888888ccccccccccc88888888888ccccc88888888888ccccc88888888888ccccc88888888888ccccc88888888888ccccc88888888888
ccc8888888888888888888888888ccccccc8888888888888ccc8888888888888ccc8888888888888ccc8888888888888ccc8888888888888ccc8888888888888
cc8888888888888888888888888888cccc88888888888888cc88888888888888cc88888888888888cc88888888888888cc88888888888888cc88888888888888
cc8888888888888888888888aaaaa88ccc88888888888888cc88888888888888cc88888888888888cc88888888888888cc88888888888888cc88888888888888
c8888888888888888888aaaaaaaaaa86cccccccccccccccccccccc77777ccccccccccc444444c44c000000000000000000000000000000000000000000000000
c888888888888888aaaaaaaa99999955cccccccccccccccccccc777777777cccccccc44fffff4ccc000000000000000000000000000000000000000000000000
888888888888aaaaaaaa999999999886ccccccccccccccccccc77777777777cccccc4ff444f4fccc000000000000000000000000000000000000000000000000
88888888aaaaaaaa9999999988888855cccccccccccccccccc7070700070777ccccc4ff4ff4f4ccc000000000000000000000000000000000000000000000000
8888aaaaaaaa99999999888888888886cccccccccccccccccc7070707070777ccccc4ffffffffccc000000000000000000000000000000000000000000000000
8aaaaaaa999999998888888888888855ccccccccccccccccc770007000777777cccff4fff0f0cccc000000000000000000000000000000000000000000000000
aaaa9999999988888888888888888886ccccccccccccccccc770707070707777cccfe4fffffffffc000000000000000000000000000000000000000000000000
99999999888888888888888888888855ccccccccccccccccc777777777777777ccccf4ffffffffff000000000000000000000000000000000000000000000000
89998888888855588888888885558886ccccccccccccccccc777707070007077ccccc44444444ffc000000000000000000000000000000000000000000000000
88888888888500058888888850005555ccccccccccccccc7cc77707070707077ccccc44470704ccc000000000000000000000000000000000000000000000000
c888888888500000588888850000055cccccccccccccccc7ccc770007000777ccccccc444444cccc000000000000000000000000000000000000000000000000
cc8888888500060005888850006000ccccccccc888888888cc7770707070707cccccccc888888888000000000000000000000000000000000000000000000000
ccc666666500666005555550066600ccccccc88888888888cc777777777777ccccccc88888888888000000000000000000000000000000000000000000000000
cc655655660006000cccccc0006000ccccc8888888888888c7777c7777777cccccc8888888888888000000000000000000000000000000000000000000000000
c655655655600000cccccccc00000ccccc88888888888888c77cccc7777ccccccc88888888888888000000000000000000000000000000000000000000000000
666666666666000cccccccccc000cccccc888888888888887ccccccccccccccccc88888888888888000000000000000000000000000000000000000000000000
8888888888888888888888888888888888888ccccccccccccccccccccccc88880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888ccccccccccccccccccccc888880000000000000000000000000000000000000000000000000000000000000000
888888888888888888888888888888888888888ccccccccccccccccccc8888880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccccc8888888888888ccccccccccccccccc88888880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccc888888888888888cccccccccccccccc88888880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccccc888888c888c888888ccccccccccccc8888888880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc888888cc888cc888888ccccccccccc888888c8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccccc888888ccc888ccc888888cccccccc8888888cc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc888888cccc888cccc8888888ccccc8888888ccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccccc888888ccccc888cccccc888888ccc888888ccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccc888888cccccc888ccccccc8888888888888cccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccccc888888ccccccc888cccccccc88888888888ccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccc888888cccccccc888ccccccccc888888888cccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccc888888ccccccccc888ccccccccccc888888ccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccc888888cccccccccc888cccccccccccc8888cccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccc888888ccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc888888cccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc888888ccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccccc888888cccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccccc888888ccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccccc888888cccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccccc888888ccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccccc888888cccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccccc888888ccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccccc888888cccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccccc888888ccccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cccc888888cccccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
ccc888888ccccccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
cc888888cccccccccccccccccccccccc888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888cccccccccccccccccccccccccc8880000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01140020027532d2352d23500003376232d2351e7051e705027532d2052d23500003376232d2351f73300003027532d2352d23500003376232d2350000300003027532d235000030000337623302351f73330235
0114002002753000030000300003376230000300003000030275300003000030000337623000031f733000030275300003000030000337623000031f703000030275300003000030000337623000031f73300003
01140020207351b7351e73522735257351e7351e735207352273522735227352573527735207351b735227351e7351e7351e73522735257351b7351b7351973522735257351e73522735257351b7351b7351b705
01140000207551b7551e75522755257551e7551e755207052275522755227552575527755207551b755227051e7551e7551e75522755257551b7551b7551975522755257551e75522755257551b7551b7551b705
0114002020452204321b4521b4321e4521e432224522243225452254321e4521e4321e4521e432004020040200402004022440226402254022540228402284020040200402004020040200402004020040200402
011400202245222432224522243222452224322545225432274522743220452204321b4521b43200002000022270022700227002570027700207001b700000020000200002000020000200002000020000200002
01100020202151b2151e21522215252151e2151e215202152221522215222152521527215202151b215222151e2151e2151e21522215252151b2151b2151921522215252151e21522215252151b2151b21519215
011000000826208252082420824208232082320822208212032620325203242032420323203232032220321206262062520624206242062320623206222062120a2620a2520a2420a2420a2320a2320a2220a212
011000000d2620d2520d2420d2420d2320d2320d2220d212062620625206242062420623206232062220621206262062520624206242062320623206222062220622206222062220621206202062020620206202
012000000827208262082520824208232082220821208212032720326203252032420323203222032120321206272062620625206242062320622206212062120a2720a2620a2520a2420a2320a2220a2120a212
012000000d2720d2620d2520d2420d2320d2220d2120d212062720626206252062420623206222062120621206272062620626206252062520624206242062320623206222062120621206202062020620206202
011000000826208252082420824208232082320822208212032620325203242032420323203232032220321206262062520624206242062320623206222062120a2620a2520a2420a2420a2320a2320a2220a212
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000166001761017610186201a6201c6201d6301f630226302463026630296302c6302f630346303a6203f6203f6101f60020600216002360026600276002d60000600006000060000600006000060000600
0001000034610346103362032620316302f6302e6302d6302b63029630286302663023630206301e6301b62017610126101f60020600216002360026600276002d60000600006000060000600006000060000600
0001000018610196201c6301d6301e6301f63020630206301f6301e6301d6301c6201b6201a620196201862016620146101f60020600216002360026600276002d60000600006000060000600006000060000600
00020000116101461017620196201b6201d6201e6201c620166301363011630106301163014620176201a62018610146101f60020600216002360026600276002d60000600006000060000600006000060000600
0104000018130181401815018150181501715016140161002d1002c1002b10014130131401215011150101500f1500e1401710014100201001f1001d100101300e1400d1500c1500b1500a1500a1300913008130
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110001021455214552d4552d45521455214552d4552d455213552145521355214552135521455213552145500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000826208252082420824208232082320822208212032620325203242032420323203232032220321206262062520624206242062320623206222062120a2620a2520a2420a2420a2320a2320a2220a212
011000000d2620d2520d2420d2420d2320d2320d2220d212062620625206242062420623206232062220621206262062520624206242062320623206222062220622206222062220621206202062020620206202
012000000827208262082520824208232082220821208212032720326203252032420323203222032120321206272062620625206242062320622206212062120a2720a2620a2520a2420a2320a2220a2120a212
012000000d2720d2620d2520d2420d2320d2220d2120d212062720626206252062420623206222062120621206272062620626206252062520624206242062320623206222062120621206202062020620206202
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
00 01 42 43 44
00 00 42 43 44
01 00 03 43 44
00 00 03 04 44
02 00 03 05 44
03 06 42 43 44
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 06 07 43 44
00 06 08 43 44
02 06 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 06 09 43 44
00 06 0a 43 44
02 06 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
