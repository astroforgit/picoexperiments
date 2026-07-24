pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--CoCo and GoGo
--by Sijiu

function noop() end

local entities={}

local facing_set_entity={
	{1,0,2,3},
	{0,1,2,3},
	{0,1,2,3},
	{0,1,3,2}
}

local test_set_x,test_set_y={-1,1,0,0},{0,0,-1,1}

local level_info_set={
	--level 1
	{
		0,
		--player
		{5,12,{occupies_id=1,update_layer=3}},
		--player reflection
		{5,44,{occupies_id=2,primary_color=14,secondary_color=13,update_layer=4}},
		--barrier
		{3,{0,24},{10,24},{20,24}},
		--dir_change
		{0},
		--ice
		{0},
		--flag1
		{1,{32,8}},
		--flag2
		{1,{32,40}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{0}
	},
	--level 2
	{
		0,
		--player
		{5,12,{occupies_id=1,update_layer=3}},
		--player reflection
		{5,44,{occupies_id=2,primary_color=14,secondary_color=13,update_layer=4}},
		--barrier
		{0},
		--dir_change
		{0},
		--ice
		{0},
		--flag1
		{1,{32,0}},
		--flag2
		{1,{32,8}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{3,{5,28,{rock_num=1}},{15,28,{rock_num=2}},{25,28,{rock_num=3}}}
	},
	--level 3
	{
		0,
		--player
		{5,12,{occupies_id=1,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=3}},
		--player reflection
		{5,52,{occupies_id=2,primary_color=14,secondary_color=13,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=4}},
		--barrier
		{1,{20,8}},
		--dir_change
		{0},
		--ice
		{5,{-10,32},{0,32},{10,32},{20,32},{30,32}},
		--flag1
		{1,{40,24}},
		--flag2
		{1,{40,32}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{3,{15,12,{rock_num=1,mincol=0,maxcol=4,minrow=1,maxrow=8}},{15,52,{rock_num=2,mincol=0,maxcol=4,minrow=1,maxrow=8}},{25,52,{rock_num=3,mincol=0,maxcol=4,minrow=1,maxrow=8}}}
	},
	--level 4
	{
		0,
		--player
		{5,12,{occupies_id=1,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=3}},
		--player reflection
		{5,52,{occupies_id=2,primary_color=14,secondary_color=13,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=4}},
		--barrier
		{2,{20,8},{20,48}},
		--dir_change
		{0},
		--ice
		{8,{-10,32},{0,32},{10,32},{20,32},{30,32},{-10,40},{-10,48},{-10,56}},
		--flag1
		{1,{40,24}},
		--flag2
		{1,{40,32}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{2,{15,4,{rock_num=1,mincol=0,maxcol=4,minrow=1,maxrow=8}},{15,60,{rock_num=2,mincol=0,maxcol=4,minrow=1,maxrow=8}}}
	},
	--level 5
	{
		-6,
		--player
		{-25,12,{occupies_id=1,mincol=-2,maxcol=5,minrow=2,maxrow=6,update_layer=3}},
		--player reflection
		{35,12,{occupies_id=2,primary_color=14,secondary_color=13,mincol=-2,maxcol=5,minrow=2,maxrow=6,update_layer=4}},
		--barrier
		{6,{-10,24,{type=1}},{-10,8,{type=1}},{-10,16,{type=1}},{20,24,{type=1}},{20,8,{type=1}},{20,16,{type=1}}},
		--dir_change
		{0},
		--ice
		{4,{0,32},{0,40},{10,32},{10,40}},
		--flag1
		{1,{0,16}},
		--flag2
		{1,{10,16}},
		--background
		{10,{-20,64},{-30,64},{-40,64},{-40,-24},{-30,16,{type=1}},{40,-16,{type=1}},{40,8,{type=1}},{-50,16},{-50,24},{-50,32},{50,72}},
		--rock
		{6,{-25,20,{rock_num=1,mincol=-2,maxcol=5,minrow=2,maxrow=6}},{-15,20,{rock_num=2,mincol=-2,maxcol=5,minrow=2,maxrow=6}},{-15,44,{rock_num=3,mincol=-2,maxcol=5,minrow=2,maxrow=6}},{35,20,{rock_num=4,mincol=-2,maxcol=5,minrow=2,maxrow=6}},{45,20,{rock_num=5,mincol=-2,maxcol=5,minrow=2,maxrow=6}},{35,44,{rock_num=6,mincol=-2,maxcol=5,minrow=2,maxrow=6}}}
	},
	--level 6
	{
		0,
		--player
		{5,60,{occupies_id=1,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=3}},
		--player reflection
		{25,60,{occupies_id=2,primary_color=14,secondary_color=13,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=4}},
		--barrier
		{0},
		--dir_change
		{0},
		--ice
		{8,{0,32},{0,24},{0,40},{20,40},{20,32},{20,24},{20,16},{20,8}},
		--flag1
		{1,{40,8}},
		--flag2
		{1,{40,56}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{2,{35,28,{rock_num=1,mincol=0,maxcol=4,minrow=1,maxrow=8}},{15,60,{rock_num=2,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button2=1,render_layer=3}}},
		--door
		{0},
		--trap
		{2,{0,16,{change=1}},{20,0,{change=0}}}
	},
	--level 7
	{
		-4,
		--player
		{-15,20,{occupies_id=1,mincol=-1,maxcol=5,minrow=2,maxrow=7,update_layer=3}},
		--player reflection
		{-15,44,{occupies_id=2,primary_color=14,secondary_color=13,mincol=-1,maxcol=5,minrow=2,maxrow=7,update_layer=4}},
		--barrier
		{4,{0,8},{0,48,{type=1}},{20,8},{20,48,{type=1}}},
		--dir_change
		{0},
		--ice
		{2,{-10,32},{10,32}},
		--flag1
		{1,{51,24}},
		--flag2
		{1,{51,32}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-20,16,{type=1}},{50,-16,{type=1}},{-50,16},{-50,24},{-50,32},{50,72}},
		--rock
		{3,{-5,28,{rock_num=1,mincol=-1,maxcol=5,minrow=2,maxrow=7,is_button1=1,render_layer=3}},{35,36,{rock_num=2,mincol=-1,maxcol=5,minrow=2,maxrow=7,is_button2=1,render_layer=3}},{35,28,{rock_num=3,mincol=-1,maxcol=5,minrow=2,maxrow=7,is_button1=1,render_layer=3}}},
		--door
		{0},
		--trap
		{8,{0,32,{change=1}},{0,24,{change=1}},{0,16,{change=1}},{0,40,{change=1}},{20,16},{20,24},{20,32},{20,40}}
	},
	--level 8
	{
		0,
		--player
		{15,4,{occupies_id=1,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=3}},
		--player reflection
		{15,60,{occupies_id=2,primary_color=14,secondary_color=13,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=4}},
		--barrier
		{0},
		--dir_change
		{0},
		--ice
		{0},
		--flag1
		{1,{40,48}},
		--flag2
		{1,{40,8}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{6,{5,12,{rock_num=1,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button1=1}},{25,12,{rock_num=2,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button2=1}},{15,28,{rock_num=3,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button1=1,render_layer=3}},{15,44,{rock_num=4,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button2=1,render_layer=3}},{5,52,{rock_num=5,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button2=1,render_layer=3}},{25,52,{rock_num=6,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button1=1,render_layer=3}}},
		--door
		{0},
		--trap
		{10,{-10,16,{change=1}},{0,16,{change=1}},{10,16,{change=1}},{20,16,{change=1}},{30,16,{change=1}},{-10,32,{change=0}},{0,32,{change=0}},{10,32,{change=0}},{20,32,{change=0}},{30,32,{change=0}}}
	},
	--level 8
	{
		0,
		--player
		{5,60,{occupies_id=1,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=3}},
		--player reflection
		{25,60,{occupies_id=2,primary_color=14,secondary_color=13,mincol=0,maxcol=4,minrow=1,maxrow=8,update_layer=4}},
		--barrier
		{0},
		--dir_change
		{0},
		--ice
		{8,{0,32},{0,24},{0,40},{20,40},{20,32},{20,24},{20,16},{20,8}},
		--flag1
		{1,{40,64}},
		--flag2
		{1,{40,56}},
		--background
		{10,{-20,-24},{-30,-24},{-40,-24},{-40,64},{-30,16,{type=1}},{50,-16,{type=1}},{60,16},{60,24},{60,32},{50,72}},
		--rock
		{2,{35,28,{rock_num=1,mincol=0,maxcol=4,minrow=1,maxrow=8}},{15,60,{rock_num=2,mincol=0,maxcol=4,minrow=1,maxrow=8,is_button2=1}}},
		--door
		{0},
		--trap
		{2,{0,16,{change=1}},{20,0,{change=0}}}
	}
}

local game_over,offset_x,level,prev_level,freeze_frames,screen_shake_frames,scene_frame,direction,player,player_reflection,title,game_over_title=false,0,1,1,0,0,0,0 -- ,nil

local entity_classes={
	{
		--entity 1 player
		-- default_counter=bump frames
		function(self)
			--draw
			local facing=self.facing
			local sx,sy,sh,dx,dy,flipped=0,0,8,3+4*facing,6,facing==0
			if facing==2 then
				sy,sh,dx=8,11,5
			end
			if facing==3 then
				sy,sh,dx,dy=19,11,5,9
			end
			--move between tiles
			if self.step_frames>0 then
				sx=44-11*self.step_frames
			end
			--bump into a wall
			if self.default_counter>0 then
				sx=66
				if facing>1 then
					dy+=13-5*facing
				else
					dx+=4-facing*8
				end
				if self.default_counter<3 then
					sx=55
				end
			end
			pal(7,self.primary_color)
			pal(6,self.secondary_color)
			self:draw_sprite(dx,dy,sx,sy,11,sh,flipped)
		end,
		function(self)
			--update
			decrement_counter_prop(self,"stun_frames")
			self:check_inputs()
			if self.next_step_dir and not self.step_dir then
				self:step(self.next_step_dir)
			end
			-- actually move
			self.prev_col,self.prev_row=self:col(),self:row()
			if self.stun_frames<=0 then
				self.vx,self.vy=0,0
				self:apply_step()
				self:apply_velocity()
				local col,row,occupant=self:col(),self:row(),get_tile_occupant(self)
				if self.prev_col~=col or self.prev_row~=row then
					-- bump into an obstacle or reflection
					if occupant then
						if occupant.occupies_id==1 or occupant.occupies_id==2 or occupant.occupies_id==3 then
							self:bump()
						elseif occupant.occupies_id==11 then
							if occupant.change==1 then
								sfx(17,2)
								level_set(level_info_set[level])
							end
						elseif occupant.occupies_id==10 then
							occupant:change_trap()
						elseif occupant.occupies_id==9 then
							if occupant.open==0 then
								self:bump()
							end
						elseif occupant.occupies_id==8 then
							if occupant.is_button1==1 then
								if self.occupies_id==1 then
									occupant:change_trap()
								elseif occupant:check_collision(rock_tile_occupant(occupant,self.facing),self.facing) then
									self:bump()
								else
									occupant:get_pushed(self.facing)
								end
							elseif occupant.is_button2==1 then
								if self.occupies_id==2 then
									occupant:change_trap()
								elseif occupant:check_collision(rock_tile_occupant(occupant,self.facing),self.facing) then
									self:bump()
								else
									occupant:get_pushed(self.facing)
								end
							else
								if occupant:check_collision(rock_tile_occupant(occupant,self.facing),self.facing) then
									self:bump()
								else
									occupant:get_pushed(self.facing)
								end
							end
						elseif occupant.occupies_id==4 then
							if player.facing_change and player_reflection.facing_change then
								player.facing_change,player_reflection.facing_change=false,false
								player.facing_set,player_reflection.facing_set={0,1,2,3},{0,1,2,3}
							else
								self.facing_set=facing_set_entity[occupant.facing+1]
								self.facing=occupant.facing
								self.facing_change=true
								occupant.finished=true
							end
						elseif occupant.occupies_id==5 then
							self.next_step_dir=self.facing
						elseif occupant.occupies_id==6 then
							self:undo_step()
							if self.occupies_id==1 then
								self.win_flag=true
								self.close_door=true
							end
						elseif occupant.occupies_id==7 then
							self:undo_step()
							if self.occupies_id==2 then
								self.win_flag=true
								self.close_door=true
							end
						end
					end
					if self.close_door then
						if col~=mid(self.mincol,col,self.maxcol) or row~=mid(self.minrow,row,self.maxrow) then
							self:undo_step()
						end
					else
						if col~=mid(self.mincol,col,self.maxcol) or row~=mid(self.minrow,row,self.maxrow) then
							self:bump()
						end
					end
				end
			end
			return true
		end,
		update_layer=3,
		render_layer=5,
		hurtbox_channel=1,
		facing=0,  --0=left 1=right 2=up 3=down
		facing_set={0,1,2,3},
		step_frames=0,
		primary_color=7,
		secondary_color=6,
		occupies_tile=true,
		facing_change=false,
		stun_frames=0,
		win_flag=false,
		close_door=false,
		draw_offset_y=2,
		mincol=1,
		maxcol=3,
		minrow=1,
		maxrow=7,
		check_inputs=function(self)
			for_each_dir(function(dir)
				if btnp(dir) then
					self:queue_step(self.facing_set[dir+1])
				end
			end)
		end,
		bump=function(self)
			sfx(20,2) -- player bump
			self:undo_step()
			self.default_counter=11
		end,
		undo_step=function(self)
			self.x,self.y,self.step_frames,self.step_dir,self.next_step_dir=10*self.prev_col-5,8*self.prev_row-4,0 -- ,nil,nil
		end,
		queue_step=function(self,dir)
			if not self:step(dir) then
				self.next_step_dir=dir
			end
		end,
		step=function(self,dir)
			if not self.step_dir and self.default_counter<=0 and self.stun_frames<=0 then
				self.facing,self.step_dir,self.step_frames,self.next_step_dir=dir,dir,4
				return true
			end
		end,
		apply_step=function(self)
			local dir,dist=self.step_dir,self.step_frames
			if dir then
				if dir>1 then
					self.vy+=(2*dir-5)*ternary(dist>2,dist-1,dist)
				else
					self.vx+=2*dir*dist-dist
				end
				if decrement_counter_prop(self,"step_frames") then
					self.step_dir=nil
					if self.next_step_dir then
						self:step(self.next_step_dir)
						self:apply_step()
					end
				end
			end
		end
	},
	--entity 2 barrier
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=80+self.type*24,8-self.type*8,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		type=0,
		update_layer=6,
		render_layer=2,
		occupies_tile=true,
		occupies_id=3
	},
	--entity 3 dir_change
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=80+self.facing*10,16,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		facing=0,
		update_layer=6,
		finished=false,
		render_layer=2,
		occupies_tile=true,
		occupies_id=4
	},
	--entity 4 ice
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=104,8,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		render_layer=2,
		update_layer=6,
		occupies_tile=true,
		occupies_id=5
	},
	--entity 5 flag1
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=80+flr(scene_frame/30)%2*10,24,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		render_layer=2,
		update_layer=6,
		occupies_tile=true,
		occupies_id=6
	},
	--entity 6 flag2
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=100+flr(scene_frame/30)%2*10,24,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		render_layer=2,
		update_layer=6,
		occupies_tile=true,
		occupies_id=7
	},
	--entity 7 background
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=flr(scene_frame/30)%(2+self.type)*10,48+self.type*8,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		update_layer=6,
		render_layer=2,
		type=0
	},
	--entity 8 rock and key
	-- can be pushed
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=40+self.is_pushed*10-self.is_button1*40-self.is_button2*20,40-self.is_key*8-self.is_button1*8-self.is_button2*8,10,8,5,4
			pal(1,false)
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		function(self)
			self.vx,self.vy=0,0
			self:apply_step()
			self:apply_velocity()
			return true
		end,
		occupies_id=8,
		render_layer=4,
		update_layer=5,
		step_frames=0,
		step_dir=nil,
		is_key=0,
		is_button1=0,
		is_button2=0,
		is_pushed=0,
		occupies_tile=true,
		get_stuck=false,
		rock_num=0,
		pushing=false,
		finished=false,
		mincol=1,
		maxcol=3,
		minrow=1,
		maxrow=7,
		get_pushed=function(self,dir)
			self.step_frames=4
			self.step_dir=dir
			self.pushing=true
		end,
		undo_step=function(self)
			self.vx,self.vy,self.pushing,self.step_frames,self.step_dir=0,0,false,0 -- ,nil
		end,
		apply_step=function(self)
			local dir,dist=self.step_dir,self.step_frames
			if dir then
				if dir>1 then
					self.vy+=(2*dir-5)*ternary(dist>2,dist-1,dist)
				else
					self.vx+=2*dir*dist-dist
				end
				if decrement_counter_prop(self,"step_frames") then
					self.step_dir=nil
					self.pushing=false
				end
			end
		end,
		check_collision=function(self,occupant,facing)
			local col,row=self:col()+test_set_x[facing+1],self:row()+test_set_y[facing+1]
			if occupant then
				if occupant.occupies_id==1 or occupant.occupies_id==2 or occupant.occupies_id==3 or occupant.occupies_id==6 or occupant.occupies_id==7 or occupant.occupies_id==11 then
					self:undo_step()
					return true
				elseif occupant.occupies_id==8 then
					if not (self.is_button1==1 or self.is_button2==1) and (occupant.is_button1==1 or occupant.is_button2==1) then
						occupant:change_trap()
					elseif occupant:check_collision(rock_tile_occupant(occupant,facing),facing) then
						self:undo_step()
						return true
					else
						occupant:get_pushed(facing)
						return false
					end
				elseif occupant.occupies_id==4 or occupant.occupies_id==5 or occupant.occupies_id==6 then
					return false
				elseif occupant.occupies_id==9 then
					if self.is_key==1 then
						self.finished=true
						occupant.open=1
						return false
					elseif occupant.open==0 then
						self:undo_step()
						return true
					elseif occupant.open==1 then
						return false
					end
				end
			end
			if col~=mid(self.mincol,col,self.maxcol) or row~=mid(self.minrow,row,self.maxrow) then
				self:undo_step()
				return true
			else
				return false
			end
		end,
		change_trap=function(self)
			sfx(19,2)
			for i=1,#entities do
				if entities[i].occupies_id==11 then
					entities[i].change=(entities[i].change+1)%2
				end
			end
		end
	},
	--entity 9 door
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=self.open*10,48,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		open=0,
		render_layer=2,
		update_layer=6,
		occupies_tile=true,
		occupies_id=9
	},
	-- entity 10 trap
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=20+self.change*10,40,10,8,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		noop,
		change=0,
		render_layer=2,
		update_layer=4,
		occupies_tile=true,
		occupies_id=11
	},
	--entity 11 game_over
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=0,96,80,32,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		function(self)
			self:apply_velocity()
			if self.first then
				self:move(-125,0,100,linear,{0,0,0,0},true)
				self.first=false
			end
		end,
		x=100,
		y=10,
		first=true,
		update_layer=5,
		render_layer=8,
		finished=false
	},
	--entity 12 title
	{
		--draw
		function(self)
			local sx,sy,sw,sh,dx,dy=0,64,50,32,0,0
			self:draw_sprite(dx,dy,sx,sy,sw,sh)
		end,
		--update
		function(self)
			self:apply_velocity()
			if freeze_frames>90 then
				noop()
			elseif freeze_frames==60 then
				self:move(0,-200,100,linear,{0,0,0,0},true)
			end
		end,
		x=-9,
		y=10,
		update_layer=5,
		render_layer=8,
		finished=false
	}
}

function _init()
	freeze_and_shake_screen(110,0)
	title=spawn_entity(12)
end

function _update()
	if freeze_frames>1 then
		freeze_frames=decrement_counter(freeze_frames)
		title:update()
	elseif freeze_frames==1 then
		freeze_frames=decrement_counter(freeze_frames)
		if title.y<-20 then
			title.finished=true
		end
		level_set(level_info_set[level])
	elseif game_over then
		game_over_title:update()
	else
		if btnp(4) then
			sfx(17)
			level_set(level_info_set[level])
		else
			if prev_level!=level then
				prev_level=level
				level_set(level_info_set[level])
			end
			screen_shake_frames,scene_frame=decrement_counter(screen_shake_frames),increment_counter(scene_frame)
		    check_input()
		    update_sort()
		    if update_layer_set(player,direction) then
		    	noop()
		    elseif update_layer_set(player_reflection,direction) then
		    	noop()
		    elseif close_to_button(player,direction) then
		    	player_reflection.update_layer=3
		    elseif close_to_button(player_reflection,direction) then
		    	player.update_layer=3
			end
			update_sort()
			local num_entities=#entities
			for i=1,min(#entities,num_entities) do
				local entity=entities[i]
				if not entity:update(decrement_counter_prop(entity,"default_counter")) then
					entity:apply_velocity()
				end
			end
			filter_out_finished(entities)
			level_up_check()
		end
	end
end

function _draw()
	local shake_x,map_level=0,0
	if screen_shake_frames>0 then
		shake_x=ceil(screen_shake_frames/3)*(scene_frame%2*2-1)
	end
	cls()
	camera(shake_x,0)
	if level<9 then
		map_level=level
	else
		map_level=level+1
	end
	map((map_level%9)*16-16,flr(map_level/9)*16,0,0,16,16)
	camera(shake_x-48+offset_x,-32)
	for i=1,#entities do
		local j=i
		while j>1 and is_rendered_on_top_of(entities[j-1],entities[j]) do
			entities[j],entities[j-1]=entities[j-1],entities[j]
			j-=1
		end
	end
	foreach(entities,function(entity)
		entity:draw2()
	end)
	--[[print("mem:      "..flr(100*(stat(0)/1024)).."%",0,-16,7)
	print("cpu:      "..flr(100*stat(1)).."%",0,-24,7)
	print("entities: "..#entities,0,-32,7)--]]
end

function spawn_entity(class_id,x,y,args)
	local k,v,entity
	local the_class=entity_classes[class_id]
	--create default entity
	entity={
		default_counter=0,
		frames_alive=0,
		hurtbox_channel=0,
		invincibility_frames=0,
		-- spatial props
		x=x or 0,
		y=y or 0,
		vx=0,
		vy=0,
		--entity methods
		init=noop,
		update=noop,
		draw=noop,
		draw2=function(self)
			self:draw(self.x,self.y,self.frames_alive,self.frames_to_death)
			pal()
		end,
		draw_offset_x=0,
		draw_offset_y=0,
		draw_sprite=function(self,dx,dy,...)
			draw_sprite(self.x+self.draw_offset_x-dx,self.y+self.draw_offset_y-dy,...)
		end,
		die=function(self)
			if not self.finished then
				self:on_death()
				self.finished=true
			end
		end,
		on_death=noop,
		col=function(self)
			return 1+flr(self.x/10)
		end,
		row=function(self)
			return 1+flr(self.y/8)
		end,
		-- hit methods
		is_hitting=function(self,entity)
			return self:row()==entity:row() and self:col()==entity:col()
		end,
		on_hurt=function(self)
			self:die()
		end,
		apply_velocity=function(self)
			local move=self.movement
			if move then
				move.frames+=1
				local t=move.easing(move.frames/move.duration)
				local i
				self.vx,self.vy=-self.x,-self.y
				for i=0,3 do
					local m=ternary(i%3>0,3,1)*t^i*(1-t)^(3-i)
					self.vx+=m*move.bezier[2*i+1]
					self.vy+=m*move.bezier[2*i+2]
				end
				if move.frames>=move.duration then
					self.x,self.y,self.vx,self.vy,self.movement=move.final_x,move.final_y,0,0 -- ,nil
				end
			end
			self.x+=self.vx
			self.y+=self.vy
		end,
		move=function(self,x,y,dur,easing,anchors,is_relative)
			local start_x,start_y,end_x,end_y=self.x,self.y,x,y
			if is_relative then
				end_x+=start_x
				end_y+=start_y
			end
			local dx,dy=end_x-start_x,end_y-start_y
			anchors=anchors or {dx/4,dy/4,-dx/4,-dy/4}
			self.movement={
				frames=0,
				duration=dur,
				final_x=end_x,
				final_y=end_y,
				easing=easing or linear,
				bezier={start_x,start_y,
					start_x+anchors[1],start_y+anchors[2],
					end_x+anchors[3],end_y+anchors[4],
					end_x,end_y}
			}
			return dur-1
		end,
		cancel_move=function(self)
			self.vx,self,vy,self.movement=0,0 -- ,nil
		end
	}
	for k,v in pairs(the_class) do
		entity[k]=v
	end
	entity.draw,entity.update=the_class[1] or entity.draw,the_class[2] or entity.update
	-- add properties onto it from the arguments
	for k,v in pairs(args or {}) do
		entity[k]=v
	end
	-- initialize it
	entity:init()
	add(entities,entity)
	-- return it
	return entity
end

function check_input()
	for_each_dir(function(dir)
		if btnp(dir) then
			sfx(15,2)
			direction=dir
		end
	end)
end

function update_layer_set(pl,facing)
	local occupant=rock_tile_occupant(pl,facing)
	if occupant then
		if occupant.occupies_id==1 or occupant.occupies_id==2 then
			pl.update_layer=4
			occupant.update_layer=3
			return true
		else
			return false
		end
	end
	return false
end

function update_sort()
	for i=1,#entities do
		local j=i
		while j>1 and is_run_on_top_of(entities[j-1],entities[j]) do
			entities[j],entities[j-1]=entities[j-1],entities[j]
			j-=1
		end
	end
end

function level_set(level_info)
	entities={}
	offset_x=level_info[1]
	player=spawn_entity(1,level_info[2][1],level_info[2][2],level_info[2][3])
	player_reflection=spawn_entity(1,level_info[3][1],level_info[3][2],level_info[3][3])
	for i=4,#level_info do
		for j=1,level_info[i][1] do
			spawn_entity(i-2,level_info[i][j+1][1],level_info[i][j+1][2],level_info[i][j+1][3])
		end
	end
	freeze_and_shake_screen(0,5)
end

function level_up_check()
	if player.win_flag and player_reflection.win_flag and level<=7 then
		sfx(18)
		level+=1
		freeze_and_shake_screen(0,5)
	elseif player.win_flag and player_reflection.win_flag and level==8 then
		game_over_title=spawn_entity(11)
		game_over=true
	else
		player.win_flag,player_reflection.win_flag,player.close_door,player_reflection.close_door=false,false,false,false
	end
end

function for_each_dir(fn)
	-- dir,dx,dy
	fn(0,-1,0) -- left
	fn(1,1,0) -- right
	fn(2,0,-1) -- up
	fn(3,0,1) -- down
end

-- drawing functions
function print_centered(text,x,...)
	print(text,x-2*#text,...)
end

function is_rendered_on_top_of(a,b)
	return ternary(a.render_layer==b.render_layer,a.y>b.y,a.render_layer>b.render_layer)
end

function is_run_on_top_of(a,b)
	return ternary(a.update_layer==b.update_layer,a.y>b.y,a.update_layer>b.update_layer)
end

-- easing functions
function linear(percent)
	return percent
end

function ease_in(percent)
	return 1-ease_out(1-percent)
end

function ease_out(percent)
	return percent^2
end

function ease_out_in(percent)
	return ternary(percent<0.5,ease_out(2*percent),1+ease_in(2*percent-1))/2
end

function copy_props(source,target,props)
	local p
	for p in all(props) do
		target[p]=source[p]
	end
end

function draw_sprite(x,y,sx,sy,sw,sh,...)
	sspr(sx,sy,sw,sh,x,y,sw,sh,...)
end

-- helper functions
function freeze_and_shake_screen(f,s)
	freeze_frames,screen_shake_frames=max(f,freeze_frames),max(s,screen_shake_frames)
end

-- if condition is true return the second argument, otherwise the third
function ternary(condition,if_true,if_false)
	return condition and if_true or if_false
end

-- increment a counter, wrapping to 20000 if it risks overflowing
function increment_counter(n)
	return n+ternary(n>32000,-12000,1)
end

-- decrement a counter but not below 0
function decrement_counter(n)
	return max(0,n-1)
end

-- decrement_counter on a property of an object, returns true when it reaches 0
function decrement_counter_prop(obj,k)
	if obj[k]>0 then
		obj[k]=decrement_counter(obj[k])
		return obj[k]<=0
	end
end

function get_tile_occupant(entity)
	local entity2
	for entity2 in all(entities) do
		if entity2.occupies_tile and entity2:col()==entity:col() and entity2:row()==entity:row() then
			if entity.occupies_id==8 and entity2.occupies_id==8 and entity.rock_num~=entity2.rock_num then
				return entity2
			elseif entity2.occupies_id~=entity.occupies_id then
				return entity2
			end
		end
	end
end

function rock_tile_occupant(entity,facing)
	local entity2
	for entity2 in all(entities) do
		if entity2.occupies_tile and entity2:col()==entity:col()+test_set_x[facing+1] and entity2:row()==entity:row()+test_set_y[facing+1] then
			if entity.occupies_id==8 and entity2.occupies_id==8 and entity.rock_num~=entity2.rock_num then
				return entity2
			elseif entity2.occupies_id~=entity.occupies_id then
				return entity2
			end
		end
	end
end

function close_to_button(pl,facing)
	local occupant=rock_tile_occupant(pl,facing)
	if occupant then
		if occupant.occupies_id==8 and (occupant.is_button1==1 or occupant.is_button2==1) then
			if pl.occupies_id==1 and occupant.is_button1==1 then
				pl.update_layer=2
				return true
			elseif pl.occupies_id==2 and occupant.is_button2==1 then
				pl.update_layer=2
				return true
			else
				return false
			end
		end
	end
	return false
end

-- filter out anything in list with finished=true
function filter_out_finished(list)
	local item
	for item in all(list) do
		if item.finished then
			del(list,item)
		end
	end
end



__gfx__
00000077770077000000000000000777000000077770000900cc0000000000000000000077700000111111111111111111111111bbbbbbbbb1111111bb1b11b1
000007777777777777770000000077777000007777770008dccccc000000000000000000777000001111111111111111111111111bbbbbbbbb111111bbbbbbbb
000007771717777111171700000777171000007771710000cccccc00007117777000000771700000111111111111111111111111bbbbbbbbb1111111bbbbbbbb
00000777171766611117170000777717100007777171000dcc1c1cc07771111177000007717000001111111111111111111111111bbbbbbbb11111113333bbbb
0070077ee7e777777ee7e70700777ee7e0070777ee7e00ddcc1c1cc07766777777000007777000001111111111111111111111111bbbbbbbbb1111113333bbbb
00070777777667666600000067777777700066677777000ddccccc06677777766000070677700000111111111111111111111111bbbbbbbbbb1111113333bbbb
000777677776666000000000066677770000066666600000ddcccd066666660000000077666000001111111111111111111111111bbbbbbbb1111111b33bbbbb
0000660677706000000000000000000000000000000000000d000980000000000000000000000000111111111111111111111111bbbbbbbbbb1111111bb11bbb
00077777000000007000000007777700000077777000000ccccc00000000000000000000000000001b1b1bbbb1bbb1b1bb1b11b11cccccccc11111111111bb11
0077777770000007770000000777770000077777770090cc00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb1c1111111c11111111bbbbbb
007777777000000777000000777777700007777777000dcc00000000000000006000077777000000bbbbbbbbbbbbbbbbbbbbbbbbc1c11c11cc111111111bbbbb
0077777770000007770000007777777000077777770080cd00000000000777776006777777760000b3b3bb3b3bb3b33b333b3b3bcc11c11c1c11111111bbbbbb
0077777770000077777000006777776000077777770000dd00000000000777776007777777770000b3333333333333333333333bc1111111c111111111bbbbbb
0077777770000067776000006766676000076676670000dd00000000000666667006667666660000b3333333333333333333333bc1c11c11cc111111111bbbbb
00766766700000677760000066666660000606670600000d00000000000666666000070000000000b3333b3b33b33b3bb33bb33b1c11c11c1c11111111bbbbbb
006066706000007666700000606760600000000070000000000000000006666600000000000000001b33b1b1b11bb1b11bb11b1b1cccccccc111111111bbbbbb
000000070000066676660000000070000000000000000000000000000000000000000000000000001111111111111111111111111111111111111111b1bbb1b1
000000000000066667660000000070000000000000000000000000000000000000000000000000001111111111111111111111111111111111111111bbbbbbbb
000000000000000000700000000007000000000000000000000000000000000000000000000000001111711111111117111111177611111111611111bbbbbbbb
000000000000007777700000000000000000000000000000000000000000000000000000000000001116777711117777611111177611111116661111bbb3b33b
000000000000077777770000000700000000000000000000000000000000000000000000000000001166777711117777661111777661111166777111bbb33333
000000000000077171770000007707000000000000000000000000000000000000000000000000001116666611116666611111166611111116771111bbb33333
000777770000007171700000077777000000777770000000000000000007770000000000000000001111611111111116111111116111111116771111bbb33b3b
00777777700000717170000077171770000777777700000ccccc00000071717000000000000000001111111111111111111111111111111111111111bbbbb1b1
0077171770000071717000007717177000077171770090ccccccc096007171700000000000000000111111111111111111111111111111111111111111111111
007717177000006171700000771717700007717177000dcccccccd0066717176006007777700000011177711711117771111111eee11e1111eee111111111111
007ee7ee700000ee7ee000006ee7ee700007ee7ee70080ccccccc08067717176600677777776000011177777111117777711111eeeee11111eeeee1111111111
0077777770000006660000006777777000077777770000cc1c1cc00077717177600771171177000011166611111116661171111ddd1111111ddd11e111111111
0067777760000006660000006666666000067777760000cc1c1cc00077717177700777777777000011161111111116111111111d111111111d11111111111111
00607770600000007000000007000000000607770600000ccccc000000666666000000000000000011161111111116111111111d111111111d11111111111111
000000000000000000000000000000000000000000000000000000000000000000000000000000001166711111116671111111dde1111111dde1111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111111111111111111
00000000001111111111000000000011111111111111111111111111111111111111111111111111ccccccccc11111111111111bbbbbbbb1bb1b1bbbbbbbbbbb
00077770001111111111000eeee000111111111111aa11111111eeeeeee111222222211111111111cccccccccc111111111111bbbbbbbbbbbbbbbbbbbbbbbbbb
0077777700111111111100eeeeee0011111111111a11a1111111e22222e1112eeeee2111111111111ccccccccc1111111111111bbbbbbbbbbbbbbbbbbbbbbbbb
0077777700111666611100eeeeee00111dddd1111a11aaaaa111e2eee2e1112e222e211111111111ccccccccc1111111111111bbbbbbbbb1bbbbbbbbbbbbbbbb
0567777650156666665105deeeed5015dddddd511a11a9a9a111e2e2e2e1112e2e2e2111111111111ccccccccc111111111111bbbbbbbbbbbbbbbbbbbbbbbbbb
05566665501556666551055dddd550155dddd55119aa91919111e2e222e1112e2eee211111111111cccccccccc1111111111111bbbbbbbb1bbbbbbbbbbbbbbbb
0055555500115555551100555555001155555511119911111111e2eeeee1112e2222211111111111ccccccccc1111111111111bbbbbbbbbbbbbbbbbbbbbbbbbb
000000000011111111110000000000111111111111111111111111111111111111111111111111111ccccccccc1111111111111bbbbbbbb1bbbbbbbbbbbbbbbb
111111111111111111111111111111111711171100000000001111111111111111111111111111111111111ccccccccc1bbbbbbbb1111111bbbbbbbb11111111
11177771111117777111111611161111171117110009999000117777777111222222211111111111111111ccccccccccbbbbbbbbbb111111bbbbbbbb11111661
117111171111711117111165616561116761676100499994001172222271112777772111111111111111111ccccccccc1bbbbbbbb1111111bbbbbbbb11661661
17167771711711111171111611161111161116110994994990117277727111272227211111111111111111ccccccccccbbbbbbbbbb111111bbbbbbbb11661111
17167771711711111171111111111111171117110499999490117272727111272727211111111111111111cccccccccc1bbbbbbbbb111111bbbbbbbb11111661
17167171711711111171111611161111171117110949994490117272227111272777211111111111111111ccccccccccbbbbbbbbb1111111bbbbbbbb11661661
171677717117111111711165616561116761676104944999401172777771112722222111111111111111111cccccccccbbbbbbbbbb111111bbbbbbbb11661111
17167771711711111171111611161111161116110049999400111111111111111111111111111111111111cccccccccc1bbbbbbbb1111111bb11bb1b11111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111cccccccc1cc1c1c1b1bbb1b1bbbbbbbbbbbb111111111111
111111b1111111111b11111111b11111111111111111111111111111111111111111111111111111ccccccccccccccccbbbbbbbbbbbbbbbbbbbbb11111111111
111111b1111111111b11111111b11111111111111111111111111111111111111111111111111111ccccccccccccccccbbbbbbbbbbbbbbbbbbbbb11111661661
111b111b1111b111b111111b111b1111111111111111111111111111111111111111111111111111cccccccccccccccc3bb3b33b3bb3b33bbbbb111111661661
111b111b1111b111b111111b111b1111111111111111111111111111111111111111111111111111cccccccccccccccc3333333333333333bbbbb11111111111
11b1111111111b11111111b111111111111111111111111111111111111111111111111111111111cccccccccccccccc3333333333333333bbbb111116616611
11b1111111111b11111111b111111111111111111111111111111111111111111111111111111111cccccccccccccccc33b33b3b33b33b3bbbbbb11116616611
11111111111111111111111111111111111111111111111111111111111111111111111111111111cc1c1cc1ccccccccbbbbbbbbb11bb1b1bbbb111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111116111111116661111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11161111111161611111116161111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111116111116116661116661111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111161611111116161111111161111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111116111111116661111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111000011111000011110000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001777777100177777100177771001777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000017777777711677777711677777116777777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000017777177111670016711670000016700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000117777177111670016711670000016700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100177777177111670016711670000016700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0171117777ee77e11670016711670000016700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177177777777711670016711670001116700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017777777777777670016777670007776700167100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001776667777617677777717677777176777777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000166167771611177777111177771011777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011111111110111111100011110000111171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111000011111000011111000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001eeeee1001eeeee1001eeeee1001eeeeee10000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001deeeeee11deeeeee01deeeeee11eeeeeeee1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001de0000001de001de01de00000011ee1eeee1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001de0000001de001de01de00000011ee1eeee1000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001001de0000001de001de01de00000011ee1eeeee000100000000000000000000000000000000000000000000000000000000000000000000000000000000
0001e111de00ee101de001de01de00ee001eeeeeeeee011e10000000000000000000000000000000000000000000000000000000000000000000000000000000
00001ee1de000de11de001de01de000de01eeeeeeeee1ee100000000000000000000000000000000000000000000000000000000000000000000000000000000
000001eede000deeede001deeede000deeeeeeeeeeeeee1000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001edeeeeee1edeeeeee1edeeeeeee1deeeedddee10000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000011eeeee1011eeeee1011eeeee110d1eeed1dd100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111000011111000011111000101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000088600000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000088600000000000000000000000000000000000000000000000000
00000ddddddd00000000000000000000000000000000000000000000000000000dd0000000088600000000000000000000000000000000000000000000000000
00000eeeeee500000000000000000000000000000000000000000000000000000aa0000000088600000000000000000000000000000000000000000000000000
000ddeeeeee5d0000000000000000000000000000000000000000000000000000aa0000000088600000000000000000000000000000000000000000000000000
000ee500000eed0000000000dddddd000000dddddd00dd00dddd000dddd000000aa0000000088600000000000000000000000000000000000000000000000000
000ee500000eed0006660000ccccccd00000bbbbbbd09900999900044440000ddaadddd000088600000000000000000000000000000000000000000000000000
000ee5000000000007770000ccccccdd00ddbbbbbbd099dd99990004444dd00aaaaaaaa000088600000000000000000000000000000000000000000000000000
000ee5000000000667776600cc5000ccd0bb5000bbd09999000000000004400aaaaaaaa000088600000000000000000000000000000000000000000000000000
000ee500000000077d007760cc5000ccd0bb5000bbd099990000000dddd440000aa5000000088600000000000000000000000000000000000000000000000000
000ee500000000077d007760cc5000ccd0bb5000bbd0995000000004444440000aa5000000088600000000000000000000000000000000000000000000000000
000ee500000dd0077d007760cc5000ccd0bb5dddbbd0995000000dd4444440000aa5000000088600000000000000000000000000000000000000000000000000
000ee500000eed077d007760cc5000ccd000bbbbbbd0995000000445000440000aa5000000088600000000000000000000000000000000000000000000000000
000ee5dddddeed077d667760cc5000ccd000bbbbbbd0995000000445ddd440000aa5000000000000000000000000000000000000000000000000000000000000
00000eeeeeed000007776000cc5000ccd0000000bbd0995000000004444440000aa5ddd000066000000000000000000000000000000000000000000000000000
00000eeeeeed000007776000cc5000ccd0000000bbd099500000000444444000000aaaa000088600000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000bbd000000000000000000000000aaaa000088600000000000000000000000000000000000000000000000000
000000000000000000000000000000000000ddddbbd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000bbbbdd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000bbbbd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0500000000000978010000000000000000000e00020000001200000000000000020500001200020500001200020500001200020500001100020000000500000002000d00020000000d0000000000050a000000000300010000000500000b020b0b64010001000400010000000000010000000407000001000b80000000000700
000000000500011600000500000000000a1001000100059600000000090c000000000c03000000000a200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a4c4e1b1b1b1b4f5d0a0a0a0a0a0a0a0a4c4e1b1b1b1b4f5d0a0a0a0a0a0a0a4c4e1a1b1b1b1b1c4f5d0a0a0a0a0a0a4c4e1a1b1b1b1b1c4f5d0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c4e1a1b1b1b1b1c4f5d0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c4e1a1b1b1b1b1c4f5d0a0a0a
0a0a0a0a4c4d0a0b0c0c5c5d0a0a0a0a0a0a0a0a4c4d0a0b0c5f5c0a0a0a0a0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a0a4c4e1a1b0f6e0a0a1f2f1b1c4e5d0a0a0a0a4c4d0a0a0b0c0a0a5c0e0a0a0a0a0a4c4e1a1b6c6c1b6c6c1b1c4e5d0a0a0a0a4c4d0a0a0b0c0a0a5c0e0a0a0a
0a0a0a0a4c4d6f6f6f6f5c0c0a0a0a0a0a0a0a0a4c4d0a0a0a5f5c0a0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a5c0a0a0a0a0a0a4c4d0a0a0a0b0c0a0a0a0a5c0e0a0a0a0a4c4d0a0a0a0a0a0a5c0e0a0a0a
0a0a0a0a4c4d0a0b0c0c5c5d0a0a0a0a0a0a0a0a4c4d0a0b0c5f5c5d0a0a0a0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a0a0a4c4d0a0a0a0b0c0a0a0a0a5c5d0a0a0a0a4c4d0a0a0b0c0a0a5c5d0a0a0a
0a0a0a0a4c4f1b1b1b1b4f5d0a0a0a0a0a0a0a0a4c4d0a0a0a0a5c5d0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c0a0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a5c0e0a0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a5c0a0a0a0a0a4c4d0a0a0a0a0a0a5c0e0a0a0a
0a0a0a0a4c4d0a0b0c0c5c5d0a0a0a0a0a0a0a0a4c4d5f0b0c0c5c5d0a0a0a0a0a0a0a4c4d0a0a0b0c0c0a5c0a0a0a0a0a0a0a4c4d0a0a0b0c0c0a5c0a0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0b0c0c0a5c0e0a0a0a0a0a4c4d0a0a0a0b0c0c0a0a0a5c0a0a0a0a0a4c4d0a0a0b0c0c0a5c0e0a0a0a
0a0a0a0a4c4d6f6f6f6f5c0c0a0a0a0a0a0a0a0a4c4d5f0a0a0a5c5d0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a0a4c4d0a0a0a0a0c0a0a0a0a5c5d0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a
0a0a0a0a4c4d0a0b0c0c5c5d0a0a0a0a0a0a0a0a4c4d5f0b0c0c5c5d0a0a0a0a0a0a0a4c4d0a0a0a0c0c0a5c5d0a0a0a0a0a0a4c4d0a0a0a0c0c0a5c5d0a0a0a0a4c5e1a1b1b1b1b1b1b1b1b1c5e5d0a0a0a0a4c4d0a0a0a0c0c0a5c5d0a0a0a0a0a4c4d0a0a0a0a0a0a0a0a0a5c0e0a0a0a0a4c4d0a0a0a0c0c0a5c5d0a0a0a
0a0a0a0a4c5e1b1b1b1b5e5d0a0a0a0a0a0a0a0a4c5e1b1b1b1b5e5d0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c5d0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c4d0a0a0a0a0a0a5c0a0a0a0a0a0a4c5e1a1b6d6d1b6d6d1b1c5e5d0a0a0a0a4c4d0a0a0a0a0a0a5c0e0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c5e1a1b1b1b1b1c5e5d0a0a0a0a0a0a4c5e1a1b1b1b1b1c5e5d0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c5e1a1b1b1b1b1c5e5d0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a4c5e1a1b1b1b1b1c5e5d0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a
__sfx__
00240020187101c7201c730217001a7201d7301d7201d7001c7201f7301f720000001f7301d7201d720000000c7300e7400e730000000e7201073010720000001072013730137200000013720117301172000000
002400001a7101c7101c700000001d7101d7101c7101f500217101f7101d7201d7200000021710217101d7101f7201f5001f5000000000000000001f5001f5001f5001f5001f5003000000000000000000000000
0012000000000000000000026520245302452124521225202453024531245211d5301d5311d5211d5211d5111f5301f5211f5110050000500005001f5301f5311f5211f5211f5113050000500005000000000000
001200001d2301f2211f2211f2211f2221f2221f2221f2211f2110000000000000001a2301a2211a2211a2111d2301f2211f2211f2211f2221f2221f2211f2211f21100000000000000000000000000000000000
01100000240452400528000280452b0450c005280450000529042240162d04500005307553c5252d000130052b0451f006260352b026260420c0052404500005230450c00521045230461f0450c0051c0421c025
01100000187451a7001c7001c7451d745187001c7451f7001a745247001d7451d70021745277002470023745217451f7001d7001d7451a7451b7001c7451f7001a745227001c7451b70018745187001f7451f700
01100000305453c52500600006003e625006000c30318600355250050000600006003e625006000060018600295263251529515006003e625006000060018600305250050018600006003e625246040060000600
000b00000020008040080510805107051060610605106061060510606106051070410705107031070410702107031070110702107011070110701107011070110701106011060110601105011050500000000000
000500002173021751217611f7701e1701c1721a17218172151720965009620217022170200700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c0000215702d5502d5512d5412d5322d5222d5001f502215000950021502005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000
001000002155500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000106400e6400c6300763000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001c6601a650186501364007620006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000010560105611c5701c57109500095000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000b000000200095400c1510d1510f151282612825128261282512826128251231310020000200002000020000200002000000000000000000000000000000000000000000000000000000000000000000000000
000800001a72502720037000070000700007002070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00080000287612d7712d7612d7512d741007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000000000000000000000
000700001b0301a04107041080510c0011100014001110010f0010c0010a001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001006010051140601405123060230512807028071280712807128071280612805128041280312802100000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001603016031210012300123001220010000104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001304013031070400704107031070310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00002d5502d5312d5210050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000000000000
000e00001556015531000001556015531155210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600003462034631346213427132274342143221434224322243422432224342243222434214322140020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000a00002855028531285210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000106401c13122141281512815128151271412613124131201211d121161111111100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000a00001f02120021250312b0412e0512f0512e0512d0512b0412803125031210211d02100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002d7512d751287412873100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c7301f7511f7521f73100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001f7601f7711f7721f7721f7721f7621f7421f7511f7311f72100700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000000000000
000800200861012611227110060018615006001860518615186101861100611006001861500600186051861524610186110c611006001861500600186051861518610186110c6110060018615006001860518615
0008000024610186110c6110060018615006001860518615186101861100611006001861500600186051861524610186110c61100600186150060018605186151861524625306353c63530640246210c61100000
0008000024610186110c611006001861500600186051861518610186110c6110060018615006001860518615000000060000000000003062024621186110c6113c63030631246210c6113062024621186110c611
011000000413004131041210411107130071210713007121091300913109121091110a1300a1310a1210a1110b1300b1210b1300b121091300912109130091210713007131071210711103130031310312103111
011000000413004131041210411100000000000000000000000000000000000000000000000000000000000004130041310412104111041110000004130041310412104111041110000000000000000000000000
011000000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000000000000000000000000000000000000000000000000
011000002f5302f5212f5212f511285302853128521285002e5302e5212e5212d5302d5212d5212b5302b5212f5302f5212f5212f511285302852128521285002e5302d5202b5302d5302d5212d5212b5302b521
011000002f5302f5212f5212f511285302853128521285002e5302e5212e5212d5302d5252d5352b5302b52128530285212852128511285002850026500265002653027530275212853028521285212851128500
011000001c2301c2211c22118221152311523115221152111b2301b2211b2211a2301a2221a22218230182211c2301c2111c2301c211152201521115220152111b230182201b230182111a2211c2211f23123231
011000002f5302f5212853028521285212851100000000002e5372f5272e5202f5302f5212f5212f5112f5112f5302f52128530285212b530285302b5302e5302d5302d5212b5302853028531285212852128511
01100000265302652128530005000050000500005000050028530285212b53000500005000050000500005002d5302b52028530285212d5302b52028530285212b5302b5212b5402b5312d5402d5312e5402e531
011000000050000000000000050010230102211023010221005000050000500005001f2301f2211f2301f221000000000000000000000000000000000000000000000000001f2301f22121230212212222122221
01100000091300913109121091110c1300c1210c1300c1210e1300e1310e1210e1110f1300f1310f1210f111101301012110130101210f1300f1210f1300f1210e1300e1310e1210e1110c1300c1310c1210c111
0108000018620186210c611246051862500600006003062500503005031860524615306153c6253c62530620246212461100600186150060000600306253c5000050300503306253c5000050300503005033c500
0108000018620186210c611006001862500600006001861500615006150c625186251862524625306253062524620246211861100503306203061100503186253452034511345113451134625005030060030625
011800001c2401c2321c2221c2111c2401c2321c2221c2111c2401c2311c2211a2411524015231152211624017240172321723215221132401323113231132211321112211102401023210232102320e2320e222
01180000186350000000000000001863500000000001863524630186210c6210000000000000000000000000000001864518635186251864518635000000000024630186210c6210000000000000000000000000
011000000b1300b1310b1210b1110e1300e1210e1300e1211013010131101211011111130111311112111111101301012110130101210f1300f1210f1300f1210e1300e1310e1210e1110c1300c1310c1210c111
011000001e2301e22117230172111a2301c2301c2221c2211e2301e22117230172111a2301b2321b2221b221285302852121530215211f5302153021521215211f5301c5201b5301a5301a5311a5311a5211a521
011000002e5302e5212f5302f5312f5312f5212f5212f52123500235002350023500225002250021500235002e5302d5202b5302e5302e5212e5112b5302b5312853028521285212852128511225001b5001c500
011000002823028231282312822128211000002b2202b231282312823228222282110020000200262200020026230222302123021221232302322126230262212823028231282312822128222282122821100000
001000002823028231282312822128211000002b2202b23128231282322822228211002000020026220002002623021231222300000022230212211f2301f2201a2301c2301f230212201f221212202222023220
01100000161701615116141161211516015151151411513113160131511312116170161511614116121151601515115141151311316013151131210e1500e1501015010150000001315013150131501315000000
01140000041600414104121071500916009141091210e1300b1600b1410b1110a150091600914109121071500a1600a1410a1210915007160071410712109150091600914109121091110b1600b1410b1210b111
01100000041600415104141071600916009151091410e16010150101500e160101501315013150131501315000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000041600415104141071600916009151091410e1600b1600b1510b1410a160091600915109141101601316013151101600e1601316013151101600e1601016010150101401014010130101201012000000
011000000e2220c221102311023110211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b5402b5412b5312b5312d5402d5412d5312d5312e5402e5412e5312e531
01120000186350000018635186300c62100621186350000018635186300c62100621006350c6350c63518635186352463524630186210c621000000000000000000000000000000000000000000000000000b120
011200000e1300e1210b1200912009121091110c1300c121091200612006121061110012002120041200213004130061300713007131071310713107121071210712107111071110711100100001000010000100
010900000461500000046150000004615000001061500000106150000010615000001c615000001c615000001c625000001c625046351c635106351c6351c635286351c635286351c63528645286453464534645
011200001a2301a2111a2301a2211a2111a2301823018211182301822118211182302623026221262112923029230292212b2302b2312b2312b2212b2212b2212b2212b2112b2112b21100000000000000000000
__music__
01 00 42 43 44
02 00 01 43 44
00 04 02 43 44
02 05 04 43 44
01 23 42 20 44
00 41 42 20 44
00 41 42 20 44
02 24 42 20 44
00 41 42 20 44
00 29 42 20 44
00 2a 2b 20 44
01 26 23 20 44
00 27 23 20 44
00 28 2c 20 44
00 27 23 20 44
00 32 31 20 44
00 23 42 20 44
00 2d 42 43 44
02 2e 42 43 44
00 35 23 20 44
00 35 23 20 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 3b 42 20 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 2f 42 30 44
04 3a 42 43 44
01 41 00 43 44
00 41 00 43 44
00 01 00 43 44
00 02 00 43 44
00 41 00 43 44
02 03 00 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 3e 42 43 44
02 3f 3d 3c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
