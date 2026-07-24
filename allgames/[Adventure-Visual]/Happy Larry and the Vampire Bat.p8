pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--happy larry and the vampire bat
--by dollarone
--made for #3cjam 
--october 2017


-- music:
--  0: logo theme
--  2: title theme
-- 15: shop
-- 19: village theme
-- 31 : house theme
-- 37: battle theme end
-- 38: battle theme
-- 51: forest theme

gang_member = {
	_init = function(id, frame,cost)
		local self = {}
		self.id = id
		self.frame = frame
		self.cost = cost or 0
		self.encountered = false
		return self
	end,
}

trade = {
	_init = function(id, character_id, item_want, item_give, cost, dup)
		local self = {}
		self.id = id
		self.character_id = character_id
		self.item_want = item_want
		self.item_give = item_give
		self.active = true
		self.cost = cost or 0
		self.dup = dup or 0
		self._trade = trade._trade
		return self
	end,
	_trade = function(self)
		if self.active then
			if self.item_want == nil then
				if self.id == 12 then
					if  is_in_collection(inventory, 4) and 
						is_in_collection(inventory, 5) and
						is_in_collection(inventory, 6) and
						is_in_collection(inventory, 7) and
						is_in_collection(inventory, 11) then
						return true
					else
						return false
					end
				else
					add(inventory, self.item_give)
					self.active = false	
					return true
				end
			elseif self.item_give == nil then
				if self.cost > 0 then
					if carrots >= self.cost then
						carrots -= self.cost
						self.active = false
						return true
					else
						return false
					end
				else
					del(inventory, self.item_want)
					self.active = false	
					return true
				end
			else
				for v in all(inventory) do
					if v == self.item_want then
						if self.item_want.id == 1 then
							if carrots >= self.cost then
								carrots -= self.cost
								add(inventory, self.item_give)
								self.active = false
								if(self.dup != 0)trades[self.dup].active = false
								return true
							else
								return false
							end
						else
							del(inventory, v)
							add(inventory, self.item_give)
							self.active = false
							if(self.dup != 0)trades[self.dup].active = false
						end
						return true
					end
				end
			end
		end
		return false
 	end, 
}

chat = {
	_init = function(id, character_id, question, answer, chat_required, character_required, party_member_required)
		local self = {}
		self.id = id
		self.character_id = character_id
		self.question = question
		self.answer = answer
		self.character_required = character_required or nil
		self.chat_required = chat_required or nil
		self.party_member_required = party_member_required or nil
		self.active = true
		self._chat = chat._chat
		return self
	end,
	_chat = function(self)
		if self.active then
			if self.id != 11 and self.id != 48 then
				self.active = false
			end
			return self.answer
		end
 	end, 
}

item = {
	_init = function(id, frame, description)
		local self = {}
		self.id = id
		self.frame = frame
		self.description = description
		return self
	end,
}

interaction = {
	_init = function(id, x, y, map_x, map_y, frame1, frame2, inactive_frame, big_frame, active, display_options, description_active, description_inactive, music_track, character_id)
		local self = {}
		self.id = id
		self.active = active
		self.display_options = display_options
		self.x = x
		self.y = y
		self.map_x = map_x
		self.map_y = map_y
		self.frame1 = frame1
		self.frame2 = frame2
		self.inactive_frame = inactive_frame
		self.big_frame = big_frame
		self.description_active = description_active
		self.description_inactive = description_inactive
		self.selected = 4
		self.mus = music_track or 0
		self.deleted = false
		self.character_id = character_id or nil
		self._first_visit = interaction._first_visit
		self._on_map = interaction._on_map
		self._draw = interaction._draw
		self._draw_interaction = interaction._draw_interaction
		self._collision = interaction._collision
		self._button_up = interaction._button_up
		self._button_down = interaction._button_down
		self._button_press = interaction._button_press
		self.col = {7,7,7,7,9}
		self.actioned = false
		self.current_interaction = -1
		self.current_options = 5
		self.answer = ""
		self.departed_duck = false
		self.just_entered = true
		self.cheese_gift = false
		self.gate_opens = false
		return self
	end,
	_draw = function(self)
		local f = self.frame1
		if step%60<30 then
			f = self.frame2
		end
		if not self.active then
			f = self.inactive_frame
		end
		spr(f, self.x, self.y)
		if self.big_frame == 166 or self.big_frame == 194 then
			f = self.frame1+1
			if step%60<30 then
				f = self.frame2+1
			end
			if not self.active then
				f = self.inactive_frame
			end
			spr(f, self.x+8, self.y)
		end
	end,
	_draw_interaction = function(self)
		cls()
		if #gang > 6 then
			draw_portraits(gang, 1, 57)
		else
			draw_portraits(gang, 3, 57)
		end
		rect(0,0,127,83,9)
		rect(0,0,127,127,9)
		local f = self.big_frame
		if not self.active and self.id != 16 then
			f = self.inactive_frame
		end
		if self.id == 21 then
			if self.current_interaction < 2 then
				draw_portraits({{frame=f}}, 101, 3)
			elseif self.current_interaction >= 4 then
				draw_portraits({{frame=f}, {frame=62}, {frame=194}}, 67, 3)
			elseif self.current_interaction >= 2 then
				draw_portraits({{frame=f}, {frame=62}}, 84, 3)
			end

		elseif self.id == 12 then
			draw_portraits({{frame=f}, {frame=36}}, 84, 3)
		else
			draw_portraits({{frame=f}}, 101, 3)
		end
		if self.active then
			if self.id == 21 then
				print(self.description_active, 4, 4, 9)
			else
				print(self.description_active, 10, 10, 7)
			end
		else 
			print(self.description_inactive, 10, 10, 7)
		end

		if self.id == 21 then
			if(self.current_interaction != -1)draw_portraits({{frame=34}, {frame=36}}, 84, 29)
			if self.current_interaction == -1 then
				print("uhh... who is it?", 4, 12, 7)
				print("it's me, happy larry!", 10, 79+40, self.col[5])
			elseif self.current_interaction == 0 then
				print("it's ok ursula,\ni'll explain!", 4, 30, 7)
				print("huh!", 10, 79+40, self.col[5])
			elseif self.current_interaction == 1 then
				print("i know you've been\nstruggling to find\nenough food for\nlittle bobby.", 4, 30, 7)
				print("bobby?", 10, 79+40, self.col[5])
			elseif self.current_interaction == 2 then
				print("yes?", 4, 12, 7)
				print("so i made you a big\nserving of garlic\nand orange juice\nsoup!", 4, 30, 7)
				print("soup?", 10, 79+40, self.col[5])
			elseif self.current_interaction == 3 then
				print("ahh!", 4, 12, 7)
				print("should be enough for\nthe whole family!\nthere's even a spoon\nfor little bobby!", 4, 30, 7)
				print("niiiiice!", 10, 79+40, self.col[5])
			elseif self.current_interaction == 4 then
				print("wow! thanks so\nmuch, tiny tony!", 4, 12, 7)
				print("not a problem -\nhappy larry here\ndid all the work\ncollecting things!", 4, 30, 7)
				print("it's nothing!", 10, 79+40, self.col[5])
			elseif self.current_interaction > 4 then
				print("thank you,\nhappy larry!", 4, 12, 7)
			end
			if self.current_interaction == 5 or self.current_interaction == 7 then
				rectfill(0,0,30,8,0)
				scale_text("the end!", 3,94,4,4,7)
				print(self.description_active, 4, 4, 9)
				rect(0,0,127,83,9)
			elseif self.current_interaction == 6 then
				print("made for the 3 color jam",16,98,9)
				print("october 2017 by dollarone",14,105,9)
			end

		elseif self.current_interaction == -1 then
			if self.display_options and self.active then
				self.current_options = 5
				print("talk", 10,87,self.col[1])
				print("trade", 10,95,self.col[2])
				print("recruit", 10,103,self.col[3])
			end
			if self.big_frame == 146 and not self.actioned then
				print("open", 10,111,self.col[4])	
			end
			print("leave", 10,119,self.col[5])
		elseif self.current_interaction == 0 then
			print(self.answer, 10, 30, 7)
			
			local available_chat = {}
			for v in all(chats) do
				if v.character_id == self.character_id and v.active and
					(v.chat_required == nil or not chats[v.chat_required].active) and
					(v.character_required == nil or creatures[v.character_required].encountered) and
					(v.party_member_required == nil or is_in_collection(gang, v.party_member_required)) then
						add(available_chat, v)
				end
			end
			local i = 1
			for v in all(available_chat) do
				print(v.question, 10, 79+i*8, self.col[i])
				i+=1
			end
			self.current_options = #available_chat + 1

			print("stop talking", 10, 79+i*8, self.col[i])

		elseif self.current_interaction == 1 then
			print(self.answer, 10, 30, 7)
			local available_trades = {}
			for v in all(trades) do
				if v.character_id == self.character_id and v.active then
					if v.id == 9 then
						for x in all(inventory) do
							if x.id == 14 then
								add(available_trades, v)
							end
						end
					else
						add(available_trades, v)
					end

				end
			end
			local i = 1
			for v in all(available_trades) do
				if v.item_want == nil then
					if v.character_id == 2 then
						print("receive " .. v.item_give.description .. " for free!", 10, 79+i*8, self.col[i])
					else
						print("trade all the items for key!", 10, 79+i*8, self.col[i])
					end
				elseif v.item_give == nil and v.cost > 0 then
					print(v.cost .. " carrots to see tony", 10, 79+i*8, self.col[i])
				elseif v.item_give == nil then
					print("fancy some cheese?", 10, 79+i*8, self.col[i])
				elseif v.item_want.id == 1 then
					print(v.cost .. " " .. v.item_want.description .. " for " .. v.item_give.description, 10, 79+i*8, self.col[i])
				else
					print(v.item_want.description .. " for " .. v.item_give.description, 10, 79+i*8, self.col[i])
				end
				i+=1
			end
			self.current_options = #available_trades + 1

			if self.cheese_gift then
				print("no worries!", 10, 79+i*8, self.col[i])
			else
				print("stop trading", 10, 79+i*8, self.col[i])
			end

		elseif self.current_interaction == 2 then
			print(self.answer, 10, 30, 7)
			if self.answer == "" then
				if #gang == 1 then
					print("wanna join me on adventure?", 10, 79+8, self.col[1])
				else	
					print("wanna join us on adventure?", 10, 79+8, self.col[1])
				end
			else
				print("ok!", 10, 79+8, self.col[1])
				if self.current_options > 1 then
					print("no...", 10, 79+16, self.col[2])
				end
			end
		end
		circfill(5,89 + self.selected*8,1,9)
		
	end,
	_on_map = function(self)
		if map_screen_x == self.map_x and 
			map_screen_y == self.map_y then
			return true
		else
			return false
		end
	end,
	_first_visit = function(self)
		if not self.visited then
			self.visited = true
			if self.big_frame == 146 then
				self.selected = 4
				self.col = {7,7,7,7,9}
				self.current_options = 2
			end
		end
		if self.id == 13 then
			for v in all(gang) do
				if v == creatures[3] then
					self.active = false
					break
				end
			end
		end
		if self.id == 8 then
			for v in all(inventory) do
				if v == items[2] then
					self.active = false
					self.gate_opens = true
					break
				end
			end
		end
		if self.character_id != nil then
			for v in all(creatures) do
				if v.id == self.character_id then
					v.encountered = true
					break
				end
			end
		end
	end,
	_collision = function(self)
		if player_x > self.x and player_x < self.x+8 and
			player_y > self.y and player_y < self.y+8 then
			self:_first_visit()
			if self.just_entered then
				self.just_entered = false
				if(self.mus != 0)music(self.mus,20)
			end

			return true
		else
			return false
		end
	end,
	_button_up = function(self)
		self.col[self.selected+1] = 7
		if self.big_frame == 146 and not self.actioned then
			if self.selected == 4 then
				self.selected = 3
			else
				self.selected = 4
			end
			self.col[self.selected+1] = 9
		elseif not self.active or not self.display_options then
			self.selected = 4
		else
			self.selected = (self.selected-1) % self.current_options
			if self.selected == 3 then
				self.selected = 2
			end
		end
		self.col[self.selected+1] = 9
	end,
	_button_down = function(self)
		self.col[self.selected+1] = 7
		if self.big_frame == 146 and not self.actioned then
			if self.selected == 4 then
				self.selected = 3
			else
				self.selected = 4
			end
			self.col[self.selected+1] = 9
		elseif not self.active or not self.display_options then
			self.selected = 4
		else
			self.selected = (self.selected+1) % self.current_options
			if self.selected == 3 then
				self.selected = 4
			end
		end
		self.col[self.selected+1] = 9
	end,
	_button_press = function(self)


		if self.big_frame == 115 then
			self.description_active = "i already opened this chest."
			self.big_frame = 146
		end

		if self.id == 21 then
			self.current_interaction += 1
			if self.current_interaction == 0 then
				self.col[5] = 9
			elseif self.current_interaction == 5 then
				self.selected = 20
				music(2,20)
			elseif self.current_interaction == 7 then
				self.current_interaction = 5
			end
		elseif self.current_interaction == -1 then 
			if self.gate_opens then
				self.deleted = true
				mset(11, 2, 129)
				add(interactions, interaction._init(100, 86, 19,   0,  0, 140, 156, 0, 194, true, true, "it's a big, fierce bat!", "", 38, 13))

			end

			if self.selected == 3 and self.big_frame == 146 and not self.actioned then
				self.description_active = "i found an old cheese.\nit looks nibbled!"
				self.big_frame = items[14].frame
				add(inventory, items[14])
				self.selected = 4
				self.col[self.selected+1] = 9
				self.actioned = true

			elseif self.selected == 4 then
				exit_interaction(self.mus)
				self.just_entered = true

				if (self.id == 12 and self.actioned)self.active = false

				if self.active then
					if self.id == 4 then
						self.active = false
						carrots += 4
					elseif self.id == 7 then
						interactions[7].deleted = true
						add(inventory, items[5])
					elseif self.id == 14 then
						interactions[14].deleted = true
						add(inventory, items[9])
					elseif self.id == 16 then
						self.active = false
						add(inventory, items[10])
						
					elseif self.big_frame == 226 then
						interactions[self.id].deleted = true
						carrots += 1
					elseif self.big_frame == 146 and self.actioned then
						self.active = false
					end
				else
					if self.id == 13 then
						interactions[13].deleted = true
					end
				end
			else
				if self.selected == 2 then
					self.current_options = 1
				elseif self.selected == 3 then
					self.current_options = 2

				end
				self.current_interaction = self.selected
				self.col = {9,7,7,7,7}
				self.selected = 0
				self.answer = ""
			end

		elseif self.current_interaction == 0 then

			if self.current_options == self.selected+1 then
				self.current_interaction = -1
				self.col[self.selected+1] = 7
				self.selected = 0
				self.col[self.selected+1] = 9
				self.answer = ""
			else
				local available_chat = {}
				local i = 0
				for v in all(chats) do
					if (v.character_id == self.character_id and v.active) and
						(v.chat_required == nil or not chats[v.chat_required].active) and
						(v.character_required == nil or creatures[v.character_required].encountered) and
						(v.party_member_required == nil or is_in_collection(gang, v.party_member_required)) then			
						add(available_chat, v)
					end
					i+=1
				end
				self.answer = available_chat[self.selected+1]:_chat()
			end
		elseif self.current_interaction == 1 then


			if self.current_options == self.selected+1 then
				self.current_interaction = -1
				self.col[self.selected+1] = 7
				self.selected = 1
				self.col[self.selected+1] = 9
				self.answer = ""
				if self.cheese_gift then
					self.deleted = true
					exit_interaction(true)
				end
			else
				local available_trades = {}
				for v in all(trades) do
					if v.character_id == self.character_id and v.active then
						if v.id == 9 then
							for x in all(inventory) do
								if x.id == 14 then
									add(available_trades, v)
								end
							end
						else
							add(available_trades, v)
						end
					end
				end
				if available_trades[self.selected+1]:_trade() then
					if self.character_id == 2 then
						self.answer = "bless you son!"
						self.actioned = true
					elseif self.character_id == 12 then
						self.answer = "sunshine: the best\norange juice in town!"
						self.actioned = true
					elseif self.character_id == 7 then
						self.answer = "alright, come inside."
						interactions[13].deleted = true
					elseif self.character_id == 13 then
						self.answer = "my cheese!\ni thought i had lost it\nforever! thank you!"
						self.cheese_gift = true
						music"37"
					else
						if self.character_id == 6 then
							self.answer = "excellent!\n\nmeet me at castle wollaton!"
							self.actioned = true
							del(inventory, items[4])
							del(inventory, items[5])
							del(inventory, items[6])
							del(inventory, items[7])
							del(inventory, items[11])
							add(inventory, items[2])
							trades[12].active = false
						else
							self.answer = "good trading with you!"
						end
					end
					self.selected = 0
					self.col = {9,7,7,7,7}
				else
					if available_trades[self.selected+1].cost > 0 then
						self.answer = "you don't have enough carrots"
					else
						if available_trades[self.selected+1].id == 12 then
							self.answer = "you don't have all the items"
						else 
							self.answer = "you don't have that item"
						end
					end
				end
			end
		elseif self.current_interaction == 2 then

			local hire = nil
			for v in all(creatures) do
				if v.id == self.character_id then
					hire = v
				end
			end

			if self.answer == "" then
				self.current_options = 2
				self.selected = 1
				self.col = {7,9,7,7,7}

				if (self.character_id == 2 or self.character_id==12) and self.actioned then
					self.answer = "sounds like fun! sure!"
				elseif self.character_id == 11 or self.character_id == 6 or self.character_id == 2 or self.character_id == 7 or self.character_id==5 or self.character_id==12 or self.character_id == 4 or self.character_id == 13 then
					self.answer = "no thanks, larry."
					if (self.character_id == 11) self.answer = "no thanks - i'm a house cat!"
					if (self.character_id == 2)self.answer = "can't go right now larry\n- i've got chores to do!"
					if (self.character_id == 7 or self.character_id==13)self.answer = "no."
					if (self.character_id == 12)self.answer = "maybe after my afternoon nap!"
					if (self.character_id == 4)self.answer = "i can't - gotta watch\nthe store!"
					self.current_options = 1
					self.selected = 0
					self.col = {9,7,7,7,7}
				elseif hire.cost > 0 then
					self.answer = "hmm - i'll join if you\ngive me " .. hire.cost .. " carrots"
				else
					self.answer = "sure, i'll join if you'll\nhave me!"
				end

			else
				if self.selected == 0 and self.current_options > 1 then
					if carrots >= hire.cost  then
						carrots -= hire.cost
						add(gang, creatures[self.character_id])
						self.active = false
						exit_interaction(true)
						self.just_entered = true
						self.answer = ""
						self.selected = 4
						self.col = {7,7,7,7,9}
						self.current_interaction = -1
						if self.id == 19 or self.id == 20 then
							self.deleted = true
						end
					else
						self.answer = "you can't afford me"
					end
				else
					self.current_interaction = -1
					self.selected = 2
					self.col = {7,7,9,7,7}
					self.answer = ""
				end
			end
		end
	end,
}

function exit_interaction(restart_music)
	if dir == 1 then
		player_y += 1
	elseif dir == 2 then
		player_x -= 1
	elseif dir == 3 then
		player_y -= 1
	elseif dir == 4 then
		player_x += 1
	end
	if restart_music!=0 then
		if map_screen_y == 0 then
			music(51,20)
		else
			music(19,20)
		end
	end
end

function is_in_collection(coll, id) 
	for v in all(coll) do
		if v.id == id then
			return true
		end
	end
	return false
end

function print_c(s,y,c)
  print(s,64-#s*4/2,y,c)
end

function _init()
	map_x = 130
    palt(14, true) -- pink color as transparency is true
    palt(0, false) -- black color as transparency is false
	player_x = 36
	player_y = 31
	player_sprite = 87
	dir = 3
	frame = 0
	step = 0
	state = 1
	map_screen_x = 128
	map_screen_y = 128
	
	carrots = 0

	char_overlay = false
	inv_overlay = false

	yikes = {"yikes!", "scary!", " ouch!", " yelp!", " gulp!", "waaah!"}

	common_chatlines = {}
	add(common_chatlines, "hello!")
	add(common_chatlines, "how are you?") --2
	add(common_chatlines, "good day!")
	add(common_chatlines, "have you seen the pastor?") --4
	add(common_chatlines, "what's happening?")
	add(common_chatlines, "ok?") --6
	add(common_chatlines, "what's up with this bat?")
	add(common_chatlines, "any news?") --8
	add(common_chatlines, "oh? what happened?")

	common_answers = {}
	add(common_answers, "hi.")
	add(common_answers, "it's always good to see you,\nmrs elsinore!") --2
	add(common_answers, "no, he lives too far away.") --3
	add(common_answers, "oh, hi larry!")
	add(common_answers, "i have no idea.") --5
	add(common_answers, "i dunno!")
	add(common_answers, "i heard mr tyrone the horse\nwoke up feeling dizzy!") -- 7
	add(common_answers, "that's crazy!") -- 9

	chats = {}
	add(chats, chat._init(1, 11, common_chatlines[1], common_answers[1]))
	add(chats, chat._init(2, 11, common_chatlines[2], "miaow.", 1))
	add(chats, chat._init(3, 11, common_chatlines[4], common_answers[3], nil, 2))
	add(chats, chat._init(4, 11, common_chatlines[3], common_answers[2], nil, nil, 3))
	add(chats, chat._init(5, 7, "who lives here?", "this is tony's domain\n- get lost, bozo!"))
	add(chats, chat._init(6, 6, common_chatlines[5], "larry, we have ourselves\na situation.\nmaybe you can help..."))
	add(chats, chat._init(7, 6, common_chatlines[6], "larry - there's a\nvampire bat living\nin castle wollaton!", 6))
	add(chats, chat._init(8, 6, "oh deer!", "don't panic larry.\n\ni've already designed\na solution.", 7))
	add(chats, chat._init(9, 6, "how can i help?", "find me the following:\na garlic, some holy water,\nsomething made of silver,\na wooden stake, and sunshine.", 8))
	add(chats, chat._init(10, 6, common_chatlines[6], "pastor kingpin should be able\nto help with the holy water.\nhe lives far west of here.\ngood luck, larry!", 9))
	add(chats, chat._init(11, 6, "what was i supposed to find?", "find me the following:\na garlic, some holy water,\nsomething made of silver,\na wooden stake, and sunshine.", 10))
	add(chats, chat._init(12, 2, common_chatlines[3], common_answers[4]))
	add(chats, chat._init(13, 2, common_chatlines[5], "ah, just taking a breather!", 12))
	add(chats, chat._init(14, 2, common_chatlines[8], common_answers[7]))
	add(chats, chat._init(15, 2, common_chatlines[93], common_answers[5], 15))
	add(chats, chat._init(16, 3, common_chatlines[1], common_answers[4]))
	add(chats, chat._init(17, 3, common_chatlines[2], "yes, i'm good, thanks,\nbut have you heard?\nthere's a bat in the castle!", 16))
	add(chats, chat._init(18, 3, common_chatlines[6], "well, that's all i know.", 17))
	add(chats, chat._init(19, 3, common_chatlines[8], "someone is stealing my eggs!"))
	add(chats, chat._init(20, 3, common_answers[8], "right? i should go see\nmr tony about it -\nhe always knows what to do!", 19))
	add(chats, chat._init(21, 3, "you know mr tony?", "yes - he lives just\neast of town!\nhe's a nice chap, mr tony!", 20))
	add(chats, chat._init(22, 4, common_chatlines[1], common_answers[4]))
	add(chats, chat._init(23, 4, common_chatlines[2], common_answers[2], 22, nil, 3))
	add(chats, chat._init(24, 4, common_chatlines[8], "well - mr tyrone complained\nabout blood loss\nbefore he left."))
	add(chats, chat._init(25, 4, common_chatlines[9], common_answers[6], 24))
	add(chats, chat._init(26, 11, common_chatlines[8], "miaow.", 2, 4))
	add(chats, chat._init(27, 4, "what's with that mr muffles?", "oh he is just being a cat.", nil, 11))
	add(chats, chat._init(28, 12, "hi mr peeper!", common_answers[4]))
	add(chats, chat._init(29, 12, "how are you today?", "fine, thanks!", 28))
	add(chats, chat._init(30, 12, "heard about the bat?", "ah yes... but i try\nto stay away from\nsuch foul things!", 29, 3))
	add(chats, chat._init(31, 12, "heard about 'sunshine'?", "ooh i have some here...\ncare to trade?", 29, 6))
	add(chats, chat._init(32, 14, "hey frank", common_answers[1]))
	add(chats, chat._init(33, 14, common_chatlines[8], "nope", 32))
	add(chats, chat._init(34, 15, "morning barbie!", "oh, larry. hi..."))
	add(chats, chat._init(35, 15, "what up?", "...not much, larry...", 34))
	add(chats, chat._init(36, 15, "any fun stuff planned?", "not really, larry...", 35))
	add(chats, chat._init(37, 14, common_chatlines[7], "who cares?", 32, 3))
	add(chats, chat._init(38, 15, common_chatlines[7], "...bat? ... larry?", 32, 3))
	add(chats, chat._init(39, 15, "the bat in the castle!", "...oh, i didn't know....", 38))
	add(chats, chat._init(40, 5, "hi, who are you?", "mr orvis at your service!\ni specialise in hard-to-find\ntrinkets and tools!"))
	add(chats, chat._init(41, 5, "whatcha got?", "i have...a ball of yarn!", 40))
	add(chats, chat._init(42, 5, "oh, ok", "it's the perfect plaything\nfor your feline friends!", 41))
	add(chats, chat._init(43, 9, common_chatlines[1], "grrr...what you want?"))
	add(chats, chat._init(44, 9, "just saying hello...", "i'm hangry! grrr!", 43))
	add(chats, chat._init(45, 13, common_answers[1], "get out of here!"))
	add(chats, chat._init(46, 13, "whoa there, i'm a friend!", "then please just leave\nus alone, friend!", 45))
	add(chats, chat._init(47, 13, "us? how many are you?", "nevermind that! shoosh!", 46))
	add(chats, chat._init(48, 13, "can you please let me in?", "no way!", 47))
	add(chats, chat._init(49, 9, "heard about the bat?", "grrr, just leave it alone.", nil, 3))
	add(chats, chat._init(50, 9, "any news?", "no - it's but nice to\nsee you again, barbie!", nil, nil, 15))
	add(chats, chat._init(51, 4, "how's your day?", "it was going well\nuntil you walked in, frank...", nil, nil, 14))
	add(chats, chat._init(52, 5, "what up?", "oh hi barbie - have you\nchanged your mind about\nthat trade offer, hmm?", nil, nil, 15))
	add(chats, chat._init(53, 5, "where are you from?", "nevermind that!\nah - hi, mr peeper!\nare you ready\nto accept my trade offer?", nil, nil, 12))
	add(chats, chat._init(54, 14, "...ah...", "we meet again, barbie...", nil, nil, 15))
	add(chats, chat._init(55, 15, "aha!", "...hello again...frank...", nil, nil, 14))

	gang = {}

	creatures = {}
	add(creatures, gang_member._init(1,200))	-- 1: happy larry
	add(creatures, gang_member._init(2,9))	-- 2: pastor kingpin
	add(creatures, gang_member._init(3,11))	-- 3: mrs elsinore
	add(creatures, gang_member._init(4,30))	-- 4: winnie the shopkeeper
	add(creatures, gang_member._init(5,32))	-- 5: mr fox ?
	add(creatures, gang_member._init(6,34))	-- 6: tiny tony
	add(creatures, gang_member._init(7,36))	-- 7: winston
	add(creatures, gang_member._init(8,38))	-- 8: ursula
	add(creatures, gang_member._init(9,42, 7))	-- 9: panda 
	add(creatures, gang_member._init(10,62))	-- 10: mini bat 
	add(creatures, gang_member._init(11,232))-- 11: cat  
	add(creatures, gang_member._init(12,234))-- 12: owl
	add(creatures, gang_member._init(13,194))-- 13: mr bat
	add(creatures, gang_member._init(14,134, 2))-- 14: rat
	add(creatures, gang_member._init(15,166, 3))-- 15: raven

	add(gang, creatures[1])
	

	items = {}
	add(items, item._init(1,226, "carrots")) 	-- 1: carrots
	add(items, item._init(2,23, "gold key"))  	-- 2: gold key 
	add(items, item._init(3,29, "egg"))			-- 3: egg
	add(items, item._init(4,40, "garlic"))  	-- 4: garlic
	add(items, item._init(5,44, "wooden stakes"))--5: wooden spikes
	add(items, item._init(6,46, "silver spoon"))-- 6: silver spoon
	add(items, item._init(7,107, "holy water")) -- 7: holy water
	add(items, item._init(8,192, "eye patch"))	-- 8: eye patch
	add(items, item._init(9,196, "bone"))		-- 9: bone
	add(items, item._init(10,198, "scarf"))		-- 10: scarf
	add(items, item._init(11,224, "sunshine"))	-- 11: sunshine
	add(items, item._init(12,228, "sword in stone"))-- 12: sword in stone
	add(items, item._init(13,230, "ball of yarn"))	-- 13: ball of yarn
	add(items, item._init(14,115, "cheese"))	-- 14: cheese

	inventory = {}
	add(inventory, items[1])

	trades = {}
	add(trades, trade._init(1, 11, items[13], items[4]))
	add(trades, trade._init(2, 5, items[8], items[13], 0, 3)) -- yarn
	add(trades, trade._init(3, 5, items[1], items[13], 7, 2))
	add(trades, trade._init(4, 2, nil, items[7]))
	add(trades, trade._init(5, 12, items[3], items[11], 0, 6))
	add(trades, trade._init(6, 12, items[10], items[11], 0, 5))
	add(trades, trade._init(7, 4, items[1], items[3], 5))
	add(trades, trade._init(8, 4, items[1], items[6], 10)) -- spoon
	add(trades, trade._init(9, 13, items[14], nil))
	add(trades, trade._init(10, 9, items[9], items[8]))
	add(trades, trade._init(11, 7, items[1], nil, 15))
	add(trades, trade._init(12, 6, nil, items[2]))
		
	interactions = {}
	add(interactions, interaction._init(1,  48, 49, 384,128, 20,20, 20, 20, false, false, "", "there is a sign here.\n\nit says:\nwelcome to laketown!"))
	add(interactions, interaction._init(2,  85, 49, 256,128, 20,20, 20, 20, false, false, "", "there is an old sign\nin front of the house.\n\nit says:\nwinnie's general store"))
	add(interactions, interaction._init(3,  48, 24, 128,128, 20,20, 20, 20, false, false, "", "there is a sign\nin front of the house.\n\nit says:\nhappy larry's house - come\non in!"))
	add(interactions, interaction._init(4,  32, 12, 128,128, 0, 0, 0, 226, true, false, "this is your house!\n\nyou pick up 4 carrots\n- they might come in handy!", "this is your house!", 31))
	add(interactions, interaction._init(5,  48, 84, 128,128, 0, 0, 0,  11, true, true, "mrs elsinore's house", "noone is home", 31, 3))
	add(interactions, interaction._init(6,  47, 58,   0,128, 21, 22, 0,  9, true, true, "you come across\npastor kingpin", "there is noone here", 0, 2))
	add(interactions, interaction._init(7,  94, 112,   0,128, 44, 44, 0, 44, true, false, "the fence here is\nbroken. you figure you\nbetter pick up the\nwooden bits before someone\ngets themselves injured\n- they look pretty sharp!", "nothing here"))
	add(interactions, interaction._init(8,  88, 20,    0,  0,  0,  0, 23,130, true, false, "castle wollaton\n\nthere is a lock on\nthe gate.\n\nyou won't be able to open it\nwithout the appropriate key.", "the key fits!\n\n\nthe gate slowly opens..."))
	add(interactions, interaction._init(9,  40, 20,  128,  0,  0, 0, 0,  42, true, true, "suko's house", "noone is home", 31, 9))
	add(interactions, interaction._init(10, 96, 36, 256,128,  0, 0, 0,  30, true, true, "winnie's general store", "noone's here!", 15, 4))	
	add(interactions, interaction._init(11, 32, 60, 256,128,  0, 0, 0, 232, true, true, "mr muffles' house", "noone is home", 31, 11))
	add(interactions, interaction._init(12, 40, 60, 768,128,  0, 0, 0,  34, true, true, "tiny tony's house", "noone is home", 31, 6))
	add(interactions, interaction._init(13, 40, 70, 768,128, 14, 15, 36, 36, true, true, "winston", "winston\n\ngood to see you again,\nmrs elsinore! come on in!", 0, 7))
	add(interactions, interaction._init(14,102, 10, 896,128,  0, 0, 0,  196, true, false, "huh! someone has left\na perfectly good-\nlooking bone here!\n\nscore!", "nothing here"))
	add(interactions, interaction._init(15, 82, 85, 640,  0,  0, 0, 0,  234, true, true, "peeper's tower", "noone is home", 31, 12))
	add(interactions, interaction._init(16, 36, 27, 256,  0,  0, 0, 0,  228, true, false, "there's a sword stuck\nin a stone. nothing\nof interest to me.\n\nbut what's this? someone has\ntied a cool-looking scarf\nto the sword's handle! ace!", "there's a sword stuck\nin a stone. nothing\nof interest to me,\nreally."))
	add(interactions, interaction._init(17, 97,112, 256,  0,243,243, 0, 226, true, false, "ooh - a carrot!", "nothing here"))
	add(interactions, interaction._init(18, 77, 105, 384,  0,146,146, 146, 146, true, false, "a chest! what's in it,\ni wonder?", "you already opened\nthis chest.", 15))
	add(interactions, interaction._init(19, 98, 100, 896,128, 121, 122, 0, 134, true, true, "hello! it's\nfrank the rat!", "", 0, 14))
	add(interactions, interaction._init(20, 62, 105, 384,  0, 108, 124, 0, 166, true, true, "why, hello there,\nms barbie the crow", "", 0, 15))
	add(interactions, interaction._init(21, 88, 12,   0,  0,   0,   0, 0, 38, true, false, "castle wollaton", "", 0, 8))
	add(interactions, interaction._init(22, 30, 28, 640,  0, 14, 15, 32, 32, true, true, "orvis the trader", "", 0, 5))
	add_carrot(23,16,48,0,0)
	add_carrot(24,40,96,0,0)
	add_carrot(25,106,76,0,128)
	add_carrot(26,32,96,384,128)
	add_carrot(27,8,32,128,0)
	add_carrot(28,16,24,128,0)
	
	add_carrot(29,92,26,256,128)
	add_carrot(30,8,62,512,128)
	add_carrot(31,101,101,896,128)
	add_carrot(32,15,81,896,128)
	add_carrot(33,38,115,896,128)
	add_carrot(34,70,6,896,128)
	add_carrot(35,40,50,768,128)
	add_carrot(36,57,14,768,128)
	add_carrot(37,16,104,640,128)
	add_carrot(38,82,72,640,0)
	add_carrot(39,60,75,640,0)

	add_carrot(40,41,70,768,0)
	add_carrot(41,81,77,768,0)
	add_carrot(42,51,102,768,0)
	add_carrot(43,71,12,384,0)
	add_carrot(44,21,40,384,0)
	add_carrot(45,99,101,384,0)
	add_carrot(46,89,109,512,0)
	add_carrot(47,87,17,512,0)
	add_carrot(48,64,112,384,0)
	add_carrot(49,16,113,640,0)

	add_carrot(50,72,15,256,0)
	add_carrot(51,102,51,128,128)
	add_carrot(52,87,113,512,128)
	add_carrot(53,104,50,0,0)
	add_carrot(54,47,80,0,128)
	add_carrot(55,8,17,128,128)
	add_carrot(56,109,16,640,128)
	add_carrot(57,95,25,768,128)

end
function add_carrot(id,x,y,map_x,map_y)
	add(interactions, interaction._init(id, x, y, map_x, map_y,243,243, 0, 226, true, false, "ooh - a carrot!", "nothing here"))
end
function _update()
	step+=1

	if step==1 then
		music(0,20)
	elseif step==30 then		
		state = 1
	elseif step==220 then
		state = 2
		music"2"
	end
	if state == 1 then
		map_x -= 2
		return
	end

	if state == 3 and btnp(5) then
		state = 5
		music"19"
	end

	oldframe = frame
	frame = (frame + 1) % 8

	for v in all(interactions) do
		if not v.deleted and v:_on_map() then
			if v:_collision() then
				if btnp(2) then 
					v:_button_up()
				elseif btnp(3) then 
					v:_button_down()
				elseif btnp(4) or btnp(5) then 
					v:_button_press()
				end
				return
			end
		end

	end
	if (state < 5) return

	if btn(0) then --left
		if not fget(mget(flr((map_screen_x + player_x-4)/8), flr((map_screen_y + player_y+3)/8)),0) and
			not fget(mget(flr((map_screen_x + player_x-4)/8), flr((map_screen_y + player_y-1)/8)),0) then
			player_x -= 1
		end
		dir = 4
	elseif btn(1) then --right
		if not fget(mget(flr((map_screen_x + player_x+4)/8), flr((map_screen_y + player_y+3)/8)),0) and
			not fget(mget(flr((map_screen_x + player_x+4)/8), flr((map_screen_y + player_y-1)/8)),0) then
			player_x += 1
		end
	 	dir = 2
	elseif btn(2) then --up
		if not fget(mget(flr((map_screen_x + player_x+2)/8), flr((map_screen_y + player_y-4)/8)),0) and
			not fget(mget(flr((map_screen_x + player_x-1)/8), flr((map_screen_y + player_y-4)/8)),0) then
			player_y -= 1
		end
		dir = 1
	elseif btn(3) then --down
		if not fget(mget(flr((map_screen_x + player_x+2)/8), flr((map_screen_y + player_y+4)/8)),0) and
			not fget(mget(flr((map_screen_x + player_x-1)/8), flr((map_screen_y + player_y+4)/8)),0) then
		 	player_y += 1
		 end
	 	dir = 3
	else 
		frame = oldframe
	end
	if btnp(4) then
		char_overlay = not char_overlay
	end
	if btnp(5) then
		inv_overlay = not inv_overlay
	end
	if player_x == 127 then
		map_screen_x += 128
		player_x = 1
	elseif player_x == 0 then
		map_screen_x -= 128
		player_x = 127
	end

	if player_y == 127 then
		map_screen_y += 128
		player_y = 1
	elseif player_y == 0 then
		map_screen_y -= 128
		player_y = 127
	end

end

function _draw() 
	for v in all(interactions) do
		if not v.deleted and v:_on_map() then
			if v:_collision() then
				v:_draw_interaction()
				return
			end
		end
	end

	if state == 0 then
		cls"0"
		return
	elseif state == 1 then
		intro_draw()
		return
	elseif state < 4 then
		main_screen_draw()
		return
	end
	cls"0"
	map(flr(map_screen_x/8),flr(map_screen_y/8), 0,0, 16,16)

	for v in all(interactions) do
		if not v.deleted and v:_on_map() then
			v:_draw()
		end
	end


	if dir==3 then -- down
		spr(71 + frame, player_x-4, player_y-12, 1, 2)
	elseif dir==1 then --up
		spr(71 + frame, player_x-4, player_y-4, 1, 2, false, true)
	elseif dir==2 then --right
		draw_rotated_sprite(71 + frame, player_x-12, player_y-4, 0.25)
		draw_rotated_sprite(87 + frame , player_x-4, player_y-4, 0.25)
	elseif dir==4 then --left
		draw_rotated_sprite(87 + frame, player_x-4, player_y-4, 0.75)
		draw_rotated_sprite(71 + frame, player_x+4, player_y-4, 0.75)
	end
	map(flr(map_screen_x/8),flr(map_screen_y/8), 0,0, 16, 16,2)

	if map_screen_x == 256 and map_screen_y == 0 then
		spr(205, 80, 8)
		spr(205, 88, 8)
		spr(205, 72, 32)
		spr(205, 80, 32)
		spr(205, 88, 32)
		spr(205, 96, 32)
	elseif map_screen_x == 256 and map_screen_y == 128 then
		pset(92,72,7)
		pset(100,72,7)
	elseif map_screen_x == 0 and map_screen_y == 128 then
		spr(172, 48, 48)
	elseif map_screen_x == 128 and map_screen_y == 128 then
		spr(67, 48, 80)
	elseif map_screen_x == 384 and map_screen_y == 0 then
		spr(136, 80, 72)
		spr(137, 88, 72)
		spr(138, 96, 72)
		spr(139, 104, 72)
		spr(133, 56, 8)
		spr(133, 96, 8)
	elseif map_screen_x == 384 and map_screen_y == 128 then
		spr(139, 24, 96)
	elseif map_screen_x == 512 and map_screen_y == 0 then
		rect(55,79,55,103,0)
		spr(181, 52, 72)
		spr(181, 52, 80)
		spr(181, 52, 88)
		spr(181, 52, 96)
		spr(181, 52, 104)
		spr(181, 80, 80)
		spr(181, 80, 88)
		spr(181, 80, 96)
		spr(181, 80, 104)
		spr(136, 96, 104)
		spr(139, 104, 104)
		spr(139, 112, 104)
	elseif map_screen_x == 640 and map_screen_y == 0 then
		spr(132, 80, 56)
		spr(133, 88, 56)
		spr(149, 88, 64)
	elseif map_screen_x == 640 and map_screen_y == 128 then
		spr(205, 40, 64)
		spr(205, 48, 64)
		spr(205, 56, 64)
		spr(205, 32, 88)
		spr(205, 40, 88)
		spr(205, 48, 88)
		spr(205, 56, 88)
		spr(205, 64, 88)
	elseif map_screen_x == 896 and map_screen_y == 128 then
		spr(136, 120, 40)
	end



	if char_overlay then
		draw_portraits(gang, 1, 104)
	end

	if inv_overlay then
		if #inventory > 7 then
			local inv1 = {}
			local inv2 = {}
			local i = 1
			for v in all(inventory) do
				if i<8 then
					add(inv1, v)
				else
					add(inv2, v)
				end
				i+=1
			end
			draw_portraits(inv1, 1, 0)
			draw_portraits(inv2, 1, 25)
		else
			draw_portraits(inventory, 1, 0)
		end
		if carrots > 999 then
			print("x\n" .. carrots, 6,9,7)
		elseif carrots > 99 then
			print("x" .. carrots, 6,15,7)
		else
			print("x" .. carrots, 10,15,7)
		end

	end
end

function draw_portraits(coll, top_left_x, top_left_y)

	rectfill(top_left_x-1, top_left_y-1, top_left_x+8 + #coll*17, top_left_y+24, 0)
	rectfill(top_left_x+1,top_left_y+1, top_left_x+5 + #coll*17,top_left_y+22, 9)
	rectfill(top_left_x,top_left_y, top_left_x+3, top_left_y+3, 9)
	rectfill(top_left_x, top_left_y+20, top_left_x+3,top_left_y+23, 9)
	rectfill(top_left_x+3 + #coll*17,top_left_y, top_left_x+ 6 + #coll*17, top_left_y+3, 9)
	rectfill(top_left_x+3 + #coll*17,top_left_y+20, top_left_x+ 6  + #coll*17,top_left_y+ 23, 9)
	rectfill(top_left_x+ 3, top_left_y+3, top_left_x+ 3 + #coll*17, top_left_y+ 20, 0)
	if (coll[1].frame == 0) return
	local off_x = 0
	for v in all(coll) do
		if v.frame==107 then
			spr(v.frame, top_left_x+8+off_x, top_left_y+4, 1, 2)
		elseif v.frame==115 then
			pal(0,9)
			pal(7,0)
			spr(115, top_left_x+8+off_x, top_left_y+8)
			pal(0,0)
			pal(7,7)
		elseif v.frame==20 then
			spr(v.frame, top_left_x+8+off_x, top_left_y+8)
		elseif v.frame==23 or v.frame == 46 then
			spr(v.frame, top_left_x+4+off_x, top_left_y+6, 2, 1)
		elseif v.frame==29 or v.frame==130 or v.frame == 146 then
			spr(v.frame, top_left_x+8+off_x, top_left_y+8)
		elseif v.frame==30 or v.frame==62 then
			spr(v.frame, top_left_x+4+off_x, top_left_y+12, 2, 1)
		elseif v.frame==192 then
			spr(v.frame, top_left_x+4+off_x, top_left_y+4, 2, 2)
			rectfill(top_left_x+4+off_x, top_left_y+12, top_left_x+11+off_x, top_left_y+19, 7)
		else
			spr(v.frame, top_left_x+4+off_x, top_left_y+4, 2, 2)
		end
		if v.frame==226 then
			rectfill(top_left_x+off_x+12, top_left_y+12, top_left_x+off_x+20, top_left_y+20, 0)
		elseif v.frame==62 then
			rectfill(top_left_x+off_x+4, top_left_y+4, top_left_x+off_x+19, top_left_y+11, 7)
		end
		if v.frame == 200 then
			if is_in_collection(inventory, 8) then
				spr(202, top_left_x+4+off_x, top_left_y+4, 2, 1)
			end
			if is_in_collection(inventory, 10) then
				spr(218, top_left_x+4+off_x, top_left_y+12, 2, 1)
			end
		end

		off_x+=17

	end

end


function draw_rotated_sprite(spr, spr_x, spr_y, spr_ang)
  r=flr(spr_ang*20)/20
  s,c=sin(r),cos(r)
  b=s*s+c*c
  for y=-6,5 do 
    for x=-6,5 do
      ox,oy=( s*y+c*x)/b, (-s*x+c*y)/b

      ax,ay,
      colr=ox+4,oy+4,
        sget(spr%16*8+ox+4,flr(spr/16)*8+oy+4)

      if ax>=0 and ax<8 and ay>=0 and ay<8 and colr!=14 then 
        pset(spr_x+4+x,spr_y+4+y,colr)
        --color(7)
      end
    end
  end
end

--scales some text, used for title
function scale_text(text,tlx,tly,sx,sy,col)

 print(text,0,0,col)
    for y=0,7 do
     for x=0,#text*8-1 do
      local col=pget(x,y)
      if col!=0 then
      local nx=x*sx+tlx
      local ny=y*sy+tly
      rectfill(nx,ny,nx+sx,ny+sy,col)
      end
     end
    end
    print(text,0,0,0)

end
function main_screen_draw()
	cls(0)
	boxcol = 0
	offset = step % 400
	if step == 400 then
		state = 3
	end

	if offset == 390 then
		sfx(3)
	end
	if offset < 10 then
		cls(7)
		boxcol = 7
		
		-- bat
		if step % 6 < 3 then
			spr(140, 70 - offset, 60 - offset/2, 2, 1)
		else
			spr(156, 70 - offset, 60 - offset/2, 2, 1)
		end

	end
	map(112,0, 0, 40, 16, 10)
	scale_text("happy", 0,9,3,3,7)
	scale_text("happy", 1,10,3,3,9)
	scale_text("larry", 69,9,3,3,7)
	scale_text("larry", 70,10,3,3,9)
	--rectfill(0,0,20,5,boxcol)
	if offset < 10 then
		rectfill(73,16,73,18,7)
	end
	print("and the vampire bat",53,29,9)
	--spr(140, 100, 60)
	rectfill(0,0,20,5,boxcol)
	if offset < 30 then
		local s = 17
		if (step % 2 == 0)s = 0
		spr(s, 113, 34)
		spr(s, 112, 42)
		spr(s, 111, 50)
		spr(s, 110, 58)
		spr(s, 110, 64)
	end
	--just cutting off  the top lightning
	rectfill(113,34, 116, 34, boxcol)
	if step % 20 < 10 then
		spr(204,16,96)
	else
		spr(236,16,96)
	end
	if offset > 30 then
		spr(200, 31, 80, 2, 2)
	else
		spr(207, 40, 80)
	end
	--blinking eyes
	if offset > 113 and offset < 120 then
		rectfill(35, 85, 42, 87, 9)
	end

	spr(18,75,104)
	spr(19,82,97)

	spr(18,94,97,1,1,false,true)
	spr(19,100,104,1,1,false,true)
	-- white box at bottom
	rect(0, 112, 127, 127, 7)
	print("made for the 3 color jam",16,114,9)
	print("october 2017 by dollarone",14,121,9)
	if state == 3 then
		c = 0
		if step % 80 < 40 then
			c = 7
		end
		print_c("press — to start",64,c)
	end
end
function intro_draw()
	cls(0)
	map_y = 24
	spr(1, map_x+48, map_y)
	spr(1, map_x+80, map_y)
	spr(1, map_x+96, map_y)

	map_y += 8
	spr(5, map_x+32, map_y)
	spr(7, map_x+40, map_y)
	spr(1, map_x+48, map_y)

	spr(5, map_x+56, map_y)
	spr(7, map_x+64, map_y)
	spr(3, map_x+72, map_y)

	spr(1, map_x+80, map_y)

	spr(1, map_x+96, map_y)

	spr(5, map_x+112, map_y)
	spr(7, map_x+120, map_y)
	spr(1, map_x+128, map_y)

	spr(5, map_x+136, map_y)
	spr(1, map_x+144, map_y)

	spr(5, map_x+152, map_y)
	spr(7, map_x+160, map_y)
	spr(3, map_x+168, map_y)

	spr(5, map_x+176, map_y)
	spr(7, map_x+184, map_y)
	spr(1, map_x+192, map_y)

	spr(5, map_x+200, map_y)
	spr(7, map_x+208, map_y)
	spr(3, map_x+216, map_y)

	map_y += 8
	spr(1, map_x+32, map_y)
	spr(1, map_x+48, map_y)

	spr(1, map_x+56, map_y)
	spr(1, map_x+72, map_y)

	spr(1, map_x+80, map_y)

	spr(1, map_x+96, map_y)

	spr(1, map_x+112, map_y)
	spr(1, map_x+128, map_y)

	spr(1, map_x+136, map_y)

	spr(1, map_x+152, map_y)
	spr(1, map_x+168, map_y)

	spr(1, map_x+176, map_y)
	spr(1, map_x+192, map_y)

	spr(1, map_x+200, map_y)
	spr(6, map_x+216, map_y)

	map_y += 8
	spr(2, map_x+32, map_y)
	spr(7, map_x+40, map_y)
	spr(1, map_x+48, map_y)

	spr(2, map_x+56, map_y)
	spr(7, map_x+64, map_y)
	spr(6, map_x+72, map_y)

	spr(2, map_x+80, map_y)
	spr(1, map_x+88, map_y)

	spr(2, map_x+96, map_y)
	spr(1, map_x+104, map_y)

	spr(2, map_x+112, map_y)
	spr(7, map_x+120, map_y)
	spr(1, map_x+128, map_y)

	spr(1, map_x+136, map_y)

	spr(2, map_x+152, map_y)
	spr(7, map_x+160, map_y)
	spr(6, map_x+168, map_y)

	spr(1, map_x+176, map_y)
	spr(1, map_x+192, map_y)

	spr(2, map_x+200, map_y)
	spr(7, map_x+208, map_y)
	spr(6, map_x+216, map_y)

	map_y += 8
	spr(4, map_x+168, map_y)

	map_y += 8
	spr(1, map_x+104, map_y)
	spr(1, map_x+152, map_y)
	spr(8, map_x+168, map_y)

	map_y += 8

	spr(7, map_x+24, map_y)
	spr(7, map_x+32, map_y)
	spr(3, map_x+40, map_y)

	spr(5, map_x+48, map_y)
	spr(1, map_x+56, map_y)

	spr(5, map_x+64, map_y)
	spr(7, map_x+72, map_y)
	spr(3, map_x+80, map_y)
	
	spr(5, map_x+88, map_y)
	spr(7, map_x+96, map_y)
	spr(1, map_x+104, map_y)

	spr(1, map_x+112, map_y)
	
	spr(1, map_x+128, map_y)

	spr(5, map_x+136, map_y)
	spr(1, map_x+144, map_y)

	spr(7, map_x+152, map_y)
	spr(1, map_x+160, map_y)

	spr(1, map_x+168, map_y)

	spr(5, map_x+176, map_y)
	spr(7, map_x+184, map_y)
	spr(3, map_x+192, map_y)

	spr(7, map_x+200, map_y)
	spr(7, map_x+208, map_y)
	spr(3, map_x+216, map_y)

	spr(5, map_x+224, map_y)
	spr(1, map_x+232, map_y)

	map_y += 8

	spr(1, map_x+24, map_y)
	spr(1, map_x+40, map_y)

	spr(1, map_x+48, map_y)

	spr(1, map_x+64, map_y)
	spr(1, map_x+80, map_y)
	
	spr(1, map_x+88, map_y)
	spr(1, map_x+104, map_y)

	spr(1, map_x+112, map_y)
	
	spr(1, map_x+128, map_y)

	spr(1, map_x+136, map_y)

	spr(1, map_x+152, map_y)

	spr(1, map_x+168, map_y)

	spr(1, map_x+176, map_y)
	spr(1, map_x+192, map_y)

	spr(1, map_x+200, map_y)
	spr(1, map_x+216, map_y)

	spr(2, map_x+224, map_y)
	spr(3, map_x+232, map_y)

	map_y += 8

	spr(7, map_x+24, map_y)
	spr(7, map_x+32, map_y)
	spr(6, map_x+40, map_y)

	spr(1, map_x+48, map_y)

	spr(2, map_x+64, map_y)
	spr(7, map_x+72, map_y)
	spr(6, map_x+80, map_y)
	
	spr(2, map_x+88, map_y)
	spr(7, map_x+96, map_y)
	spr(1, map_x+104, map_y)

	spr(2, map_x+112, map_y)
	spr(7, map_x+120, map_y)
	spr(6, map_x+128, map_y)

	spr(2, map_x+136, map_y)
	spr(1, map_x+144, map_y)

	spr(2, map_x+152, map_y)
	spr(1, map_x+160, map_y)

	spr(1, map_x+168, map_y)

	spr(2, map_x+176, map_y)
	spr(7, map_x+184, map_y)
	spr(6, map_x+192, map_y)

	spr(1, map_x+200, map_y)
	spr(1, map_x+216, map_y)

	spr(7, map_x+224, map_y)
	spr(6, map_x+232, map_y)

	map_y += 8

	spr(1, map_x+24, map_y)

end
__gfx__
eeeeeeee999999909999999999000000000000000000099999999990999999999999999077777000777777770000000000000000eeeeeeeeeeeeeeee9eee9eee
eeeeeeee999999909999999999990000000000000009999999999990999999999999999077700000007777770000000077700000eeeeeeee9eee9eee99999eee
eeeeeeee999999900999999999999000000000000099999999999900999999999999999077000070000009990000000777770000eeeeeeee99999eee90909eee
eeeeeeee999999900999999999999900000000000999999999999900999999990000000077000000000999070000007707070000ee9eee9e90909e7ee999eee7
eeeeeeee999999900099999999999900999999900999999999999000999999990000000077000000099900770000007777770000e9e9e9e9e9999e9ee7079ee9
eeeeeeee9999999000099999999999909999999099999999999900009999999900000000777000000000777700000077799900009ee9eeeee707eee9e77779e9
eeeeeeee999999900000099999999990999999909999999999000000999999990000000077700000007777770000007799999000eeeeeeeee7779979e7777779
eeeeeeee000000000000000000000000000000000000000000000000000000000000000077000000000777770000000799999900eeeeeeeee9797779e9797779
79999997ee99999eeeeeeeeeeee9eeeeeeee9999ee000eeeee0000ee000000000000000070077700770077770000000779999900000077000000000000077000
99777799eeee9999eeeeee9eee9eeeeee9999999e07099eeee07099e000000000000000070777777777077770000000777999000000777700000009977997000
97777779eee9999eeeeee9eeee9eeeee9999999ee000999eee000999000000000000000070777777777077770000077777770000007777770000099997999900
97777779ee9999eeeeeee9eee9eeeeee99999eeeee000eeeee000eee009990000000000070777777777077770007777777777000007777770077799999990900
97777779e9999eeeeeee9eeee9eeeeee99e99eeee07070eee07070ee099099999999900007777777777077777777777777777000007777770070009999099900
97777779eee999eeeeee9eeee9eeeeeeeee99eee0777770e0777770e090009000990990007777777777707777777777777777000007777770700007999999900
97777779ee999eeeeee9eeee9eeeeeeeeee99eee0777770e0777770e099099000090090007777777777707777777777777777700000777700700000079999900
97777779e999eeeeeee9eeee9eeeeeeeeee99eee0777770e0777770e009990000090090007777777777707777777777777777700000000000077000070070000
000000000000000000000000000000000000000000000000777777777777000000000000000000000000000000000000eeeeeeee00000000eeeeeeeeeeeeeeee
009900000000099000000000000000000990000000000990777777777770000000000000000000000000000000000000eeeeeeee90000000eeeeeeeeeeeeeeee
009799000000979000000000000000009779000000099779007777777700990000000007700000000000000000000000eeeeeeee90000000eeeeeeeeeee7777e
000979000009979000000000000000009777990000997779000077777709900000000007700000000000000000000000eeeeeeee99000000e7777eee77777777
000999999999999000000000999900009977999999997790099007700099900000000077770000000000000000000770eeeeeee99900090070000777eee7777e
000999999999990000000009990990000999900999009990009900009999990000000777777000000770099000997970eee9eee999000900700007eeeeeeeeee
000999999999990000000999999977000099977090779990000990999999990000077777777770000797999999999970eee9eee999000990e7777eeeeeeeeeee
009999079907990000009999999977000099970797079999000999999977999000777777777777000799997799779970eee9eee999000990eeeeeeeeeeeeeeee
00999999999999000099999999990700099999999999999900099779997099990777777777777700009999999999990000090009999099907777777777777777
00999999999999000999999999900000097099999999907900999709999999990777777777777770099997779777999000090009999099907777777777999777
00977999999977000999999999000000997709990999077900999999990999990777777777777770999977079707799900990009999099907777999779997777
00077799999770000999999999000000997770900090777900999999099990990777777777777770999777997997779900990009999099907777799999097777
00077779999770000999999990000000997707777777077900999999999007990077777777777700799779970799779909990009999099907777779090990077
00077779009770000099999990000000097077700077707900099990700097990007777707777000979999777779999009990009999099907770009999990000
00977777007799000007999700000000099777077707779070000999799999990000000000000000997999700079990009990009999099900000009900090000
00997777777799900077000770000000099977777777799077099999999999990000000000000000999799977799900009990009999099900000000999900000
eeeeeeee99999eeeeeeeeeeeeee77eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeee7eeeeee7eeeeee7eeeeee7eeeeee7eeeeeeee7eeeeeeee7eeeeeeeeeee
eeee99990000999eeeeeeeeee777777eeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeee7eeeeeee7eeeeee7eeeeeee7eeeeee7eeeeeee7eeeeeeee7eeeeeeeeeee
ee99970007000099eeeeeee7770770777eeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeeeeeee
e990000000000709ee77777700077000777777eeeeeee777777eeeeeeee99eeeeee99eeeeee99eeeeee99eeeeee99eeeeee99eeeeee99eeeeee99eee77777777
e900700700700009ee70000099977999000007eeeeeee700007eeeeeee9999eeee99997eee9999eee79999eeee9999eeee99997eee9999eee79999ee00000000
9970000000007009ee79999977777777999997eeeeee77999977eeeee799997eee99997ee799997ee79999eee799997eee99997ee799997ee79999ee99999999
9000000000000009ee79997770077007779997eeeeee79999997eeeee799997ee799999ee799997eee99997ee799997ee799999ee799997eee99997e99999999
9000700070070009e7777770009779000777777eeee7777777777eeeee99999ee799999eee99999eee99997eee99999ee799999eee99999eee99997e77777777
0007000099999999e7000009999779999000007eeee7000000007eeeee99999eee99999eee99999eee99999eee99999eee99999eee99999eee99999e00000000
0000007000000070e7999999777777779999997eee779999999977eeee79997eee79997eee79997eee79997eee79997eee79997eee79997eee79997e99999999
0000000007000000e7999777700770077779997eee799999999997eeee97779eee977797ee97779ee797779eee97779eee977797ee97779ee797779e99999999
0700000000007000777777000097790000777777e77777777777777ee7999997e7999997e7999997e799999ee7999997e7999997e7999997e799999e77777777
0000070000000007700000999997799999000007e70000000000007ee7909097e7909097e7909097e7909097e7909097e7909097e7909097e790909700000000
00000000007000007999999977777777999999977799999999999977e7e999e7e7e999eee7e999e7eee999e7e7e999e7e7e999eee7e999e7eee999e799999999
00700007000007007999999700000000799999977999999999999997eee707eee7e707eeeee707eeeee707e7eee707eee7e707eeeee707eeeee707e799999999
99999999000000007777777700999900777777777777777777777777eeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eee77777777
90070000000000090000700099999999000700007000070000700007eeeeeeeeeeeeeeeeee700007700007ee00000000eeeeeeeee99eeeeeeeeeeeeeeeeeeeee
900000000070070909907009999ee999900709907099070990709907eeeeeeeeeeeeeeeeee709907709907ee00000000e999eeee90077eeeeeeeeeeeeeeeeeee
9000007000000009099070999eeeeee9990709907099070990709907eeee799999997eeeee709907709907ee0009900090009999009777eeeeeeeee77eeeeeee
907000000700000909907999eeeeeeee999709907099070990709907eee79999999799eeee709907709907ee00099000e90000000007eeee7777777777777777
900070000000700909907999eeeeeeee999709907099070990709907eee79999999799eeee709907709907ee00099000ee9000000009eeee0000000000000000
900000000000000900007990eeeeeeee099700007000070000700007eeee7eeeeeee7eeeee700007700007ee00077000eee990000009eeee9999999999999999
900700700700000977777990eeeeeeee099777777777777777777777eeee7eeeeeee7eeeee777777777777ee00077000eeeee900009eeeee9999997777999999
9000000000070009eeeee990eeeeeeee099eeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeeeeeeeeeeeeeee00777700eeeeee9799eeeeee7777777007777777
90000000000000790000000770000000000000009997799999eeeeeeeee99999999999ee000990000000990007777770ee9eeeeee99eeeee0000000990000000
9700070000000009000070000070000007007000777777770999eeeeee990000000099ee009099900009099907777770e9099e777009eeee9999999999999999
90000000007000990700007000000700000000707007700707099eeeee999999999909ee009999000099999007777770e900099779009eee9999977777799999
990000070000009e00000000070000000007000000977900000099eeee900990099099ee099970000999970009999990ee90000070009eee7777770000777777
e90700000000799e00007000000000700000000099977999000709eeee999009900909ee999990009999900009999990eee900000009eeee0000009999000000
e9900070070099ee000000007007000000000007977777797000099eee90099009909eee999900009999000009999990eeee90000009eeee9999999779999999
ee99999009999eee00700070000007000070000077eeee7700070099eee9999999999eee077777000777000000999900eeeee900009eeeee9999777777779999
eeeeee9999eeeeee700000000000000700000700eeeeeeee07000709eeeeeeeeeeeeeeee000000000000770000000000eeeeee9799eeeeee7777700000077777
eeeeeeee0999999009999990e9e9e9e9eeeeeeeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeee777eeeeeeeeeeeeeeeeee
eeeeeeee99eeee9999070799e9999999eeeeeeeeeeeeeeee0000000000090000eeeeeeeeeeee9eeeeeeee9eeeeee9eeee700077ee770007eeeeeeeeeeeeeeeee
eeeeeeee9eeeeee997777779e9000009eee77e77eeeeeeee0099999990979000eeeee9eeeee909ee9eee909eeee909eee70000077000007eeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee07070707e900000977e77e77e77eeeee0999990099779000eeee909eee9009e909ee909eee9009eeee777000000777eeeeeeeeeeeeeeeeee
9e9e9eeeeeeeeeee77777777e999999977777777777eeeee0099999999990000eeee9009ee90009000990009e900009eeeeee770077eeeeeeeeeeeeeeeeeeeee
99999eeeeeeeeeee07070707ee90009e79999999997eeeee0000077799900000eee90009e9000090000900099000009eeeeeeee77eeeeeeeeeeeeeeeeeeeeeee
90009eeeeeeeeeee77777777ee90909e77977977977eeeee0000000099900900eee90000900000900090000090000009eeeeeeeeeeeeeeeeeeeeeeee99999999
99999eeeeeeeeeee07070707ee90909e77977977977eeeee0009000099990900ee900000900000090090000090000009eeeeeeeeeeeeeeee9999999900000000
90009eeeeeeeeeee007777700090009e77777777777eeeee0009007799999900ee900000900090090909000009000009eeeeeeeeeeeeeeee0007000090000009
90009e999e999e99070990779090009e79977977797eeeee0000999999999000e9000000090909099009000009000009eeeeeeeeeeeeeeee0077770090000009
90909e909e909e90709907079090909e77777799777eeeee0000999999990070e9000000009009090000900009009009eeeee77ee77eeeee0007077090000009
9090999099909990709907799990909e79779977997eeeee00099999999900079000090000900090000009000099099eeee7700770077eee0007007090000009
9000900000000000777777090090009e77977777777eeeee0009999999900007900090900900009000009090009009eeee700000000007ee0007000099000099
9000900000000000909909090090009e77700797797eeeee0009999999970070e999000909000009000900090900009ee70007700770007e00070999e999999e
9090999999999999900009909990909e79700777977eeeee0000999999007700eee9000990000000909000090900009eee707ee77ee707ee00070999eee99eee
9090900000000000099999000090909e77977997797eeeee0099900009990000ee900000900000000990000090000009eee7eeeeeeee7eee00777999eeeeeeee
9000900009000000000000900090009e79777777777eeeee9999999999999999ee900000900090000900000090000009eeeeeeeee777777e9000000909000000
9000900090900009900009090090009e77997777977eeeee9999999999999999e9000000090090000900090090000009eeeeeeee777777770900000909000000
9090900090900009900009090090909e77779997797eeeee9999990099997779e9000000090909009000909009000009eeeeeeeee700007e0999999e90000000
9090900099900099990009990090909e77777770077eeeee999990000777779990000000009009090900909009090009eeeeeeeee777777e09e99eee90000900
9000900000000099990000000090009e79979970077eeeee99990090777779999000099000900090009900090090999e977977977799997e09eeeeee90009090
9000900000000099990000000090009e77777797797eeeee0990000777799999900090090900009000090009090009ee799799799799997e9eeeeeee90090009
9000900000000099990000000090009970077779777eeeee0900000779999999e999000090000090009000009000009e997997997799997eeeeeeeee09900009
9999999999999999999999999999999070079997797eeeee0000000077777799ee90000090000009009000009000009e777777777777777e9eeeeeee00900009
ee999999999999999999999e9090090977777777777eeeee0000000007777999e900000009000009009000000900000979999997eeeeeeeeeeeeeeeeeeeeeeee
e900000900900900090000999990090977997799797eeeee0000000009999999e900000009000009090000000900000999eeee99eee77eeeeeeeeeeeeeeeeeee
9999999999999999999999099099999979777777777eeeee0000000099999999900000000900000909000000009000099eeeeee9ee7777eeeeee77eeeeeeeeee
9000009009009000900009099090090977700000777eeeee00000000999999999000000000900009900000000099999e9eeeeee9ee7777eeeee7777eeeeeeeee
9000009009009000900009999990099977700000777eeeee0000000099999999900000000099999990000000009e99ee9eeeeee9ee7777eeeee7777eeeeeee77
9999999999999999999999099099990979700000797eeeee0000000999999999e999000099e99eee90000000009eeeee9eeeeee9e97777eeeee7777eeee79799
9000900990000900900009099090090977700000777eeeee0000009999999999eeee9999eee99eeee999999999eeeeee9eeeeee99ee9e99eee977779e7797997
9999999999999999999999909990090907700000770eeeee0000099999999999eeee999eeeeeeeeeeeeee99eeeeeeeee9eeeeee9eeeeeeeee9e9ee9e77777777
7777777777777777777777777777777700000000000000007777777777777777eee999eeeeee999ee99eeeeeeeee99ee00000000eeeeeeeeeeeeeeeeeeeee99e
7777777777777777007777777777777000000000000077007777777777777777ee97799eeee9779e9779eeeeeee9779e00000000eeeeeeeeee99eeeeeeee9779
7777777777777777000977777779990000000000000777707700777777707777ee97779eeee9779e97779eeeee97779e00099990eeeeeeeee9999eeeeee97779
7777007770007777009999777799099000000000000777707777077770077777ee9779999999979ee9779999999979ee0099777977777777e99799999999979e
7700777777770777099099077090099000000000000777707777077707777777ee99999999999999e00999999999900e09970777e7eee7eee99999999999999e
7077777777777077099009000090990000000000007777007770077700777777e999997799779999999000000000099e09970077e7eee7eee99997099709999e
7700000777777077009909900999990000000000077700007700777770007777e999970797079999999970790000999e09977000e7eee7ee9999777977799999
7777777000000777009999999970790000000000777000007000777777000777e999999999999999999999999009999e00997700e7eee7ee9999999999999999
999999990000777700097079999999000000000777000000700007777000007799977799999977790009999999999990eeeeeeeeeeeeeee99997799999977999
977997790000777700099990909990000000007770000000700000000000007799777777007777779000000000000000eeeeeeeeeeeeeee99977777007777799
999777997007777700099999999990000000077700000000700000000000007799777777777777779900000000000007eeeeeeeeeeeeeee99777777777777779
99777999777777770000907070709000000777700000000077000000000007779977707777770777997000000000007777777777eeeeee999777777777777779
977977997777777700009970007900000077777000000000777000000000777799777700000077799977000000000779e9eee9eeeeeee9799777700000077779
979997797777777700000979997000000077777000000000777700000007777799977777777777799977700000007799e9eee9eeeeeee9799777077777707799
999999997777777700000000000000000007770000000000777770000777777779997777777777997997777000777799e9eee9ee999999979977777777777999
000000007777777700000000000000000000000000000000777777777777777777999777777779997799777777777999e9eee9ee000099977997777777779990
00777000000000000000000000000000eeeeeee99eeeeeee00000000000000000000000000000000000000000000000000099990000999977799999999999970
00000700000000000000000000777000eeeeeee99eeeeeee00099900000000000000000000000000000000000000000000997777000999997779999999999770
00000799999999000000009997700000eeeeeee99eeeeeee00000099900000000000000000009000000000000000000000977777009999997777777777777700
00009700000009900000099997000000eeeee999999eeeee00000000090000000099900000097000000000000000000009970000009999999777777777777700
00099999999990900000999999000000eeeee9e77e9eeeee00000000009000000007799999977000000000007777000009977000009999999777777777777700
00900007000090900000999999000000eeeeeee77eeeeeee00009797077900000000999999999000000000777777700009997000099999999977777777777700
00907009007090900009999990000000eeeeeee77eeeeeee00097079790990000009999999999000000007777777700000997000099999999977777777777700
00900909090090900009999900000000eeeeeee77eeeeeee00079779779090000009990999099900000007909790970000997700999999999997777777777000
009000999000909000999990eeeee7eeeeeeeee77eeeeeee00797997970790000099999999999900000077909790970000999700999999999997777777777000
009799999997909000999900eeeee77eeeeee9977999eeee00909709090797000099997707799900000077777777770000099979999999999997777777777000
009000999000909009999000eeee99eeeee9999799999eee00799097979799000099979999979900000077777077770000099999999999999999777777779000
009009090900909009990000eee999eeeee99999999999ee00797797709097000009999009999000000777777007770000009999999999997999777777779000
009070090070909099900000eee99eeeee999999999999ee00090990779790000007999999997000000777777707770000009999999999997999777777779000
009000070000909099000000ee99eeeeee99999999999eee00099799979970000009779999779000000777777777770000009999999999997999777777799900
009000000000990090000000ee9eeeeeeee999999999eeee00009970097000000009997777999900007777777777770000099999799999997999777777799900
009999999999900000000000eeeeeeeeeeeeeeeeeeeeeeee00000077970000000099999999999900007777777777770000099997799999999799977777799900
__gff__
0000000001000000000000000000000000000000010202000000000000000000000000000000000000000000010000000000000000000000000000000000000001010202020202000000000000000002010103030303030000000000000000010101030203030302020303000000020201010001010301010100000000000303
0002010002020000020202020000010000010000020300000303030300000103010101010202000003030303030300030101010101010000030303030100000300000000010000000000000000000000000000000000000000000000010000000000000002020000000000000000000000000000010100000000000000000000
__map__
000000000000000000800000008300000000000000000000000088898a8988898a8b8b8bb8b9b8b9babb60619f88898a8b888b8b8b88898a898a8b8b888b888b8b888b88898a898a8b88898a8b8b88898a8ba8a9a8a9a9898a8b8ba8a988898a00a9a8a9a8a988898a8b8ba89b8889aa00000000000000000000000000000000
00000000000000000090919191930000888b00456e436f4600009899999998999a9ba99f0000000000cd6061cdb8b9babbb8af9b9fb8b9bab9babb9fbab9b8bb9fbabbb8b9a8ab98999a9b9f9bab98999a9bb8b9b89b9b999a9bb9b89b98999a889bb8b9b89b98999a9b9fb89b98999a00000000000000000000000000000000
0088898a8b888b8b8ba0a182a2a3888a989bdc557e537f56dcdca8a9a9a9a8a9aaab9f0000000d00003d3d3d3d0000000000b8ae0000009500000000950000000000000000baae98999a9b009faea8a9aaab0d00009fafa9aaab405151419faaa8ab0000009fa8a9aaab00009fb8aeaa00000000000000000000000000000000
88af999a9bb8999b9f001200130098af9abb00696263646a9e0098ae9999b8b9ba9b0000e4e50000003d3d3d3d000000000000000085000000008500000000000000000d000000a8a9aaab000000b8b9babb00000000a8a9aa9b6073747241aa989b00000000a8a9af9b00000000889b00000000000000000000000000000000
b8afa9aaab00b8ab000013120000a89a9b0000000000000000009899a9a9aa898aab0000f4f50000003d3d3d3d00000000000d00009500000000950000000d0000000000000000b8b9babb8b000088898a8b0000000098aeafab6074737461afa8ab008b000098aeafab00000000a8ab00000000000000000080000000830000
88ab9fbabb00009f001200130000af9bab000000000000000000a8a9aa999a999a9b00000000000000006061000000000000000000000000000000000000000000000000000000000000009f000098999a9b8b00008b98999a9b7050505071afa8ae009f8b00afafaf9b00000000989b00000000ce0000000090919191930000
98ae00000000000000131200008898afab000d0000000040410098999aaea9a9aaab8b000000000d00006072515151515151515151515151515151515151515151517600888b000000000d000088afa9af9baa8a8b9fb8b9999a8b8888888b9b98af00009b00a8afaf9b00888b00afab008e8fdddedf8f8f8fa0a182a2a38f8e
b8a98b00000000001200130d00b8bababb000000000000707100a89999a9aa999b9b9b8b0000000000007050505050727473737373747474747474747373747473747276b8998b000000000088afaf999aaba999ab8b8889a9aa9baaa9aa99abb89b8b009b00b8b9baae00989b00989bc4c4c4edeeefc4c4c4c4c4c4c4c4c4c4
00b8ab0077780d001312000000888b888b00898a898b88898a8b98af9fb9babb9fb8b99f0000000000000000000000705050505050727474747373737373737374727472769fb90000000000b8bbb8a9b8b99fa9aa9b98999bb894bbb8b9afae00aa9b009b898a8b88898aa8ab00a8abc4c4fcfdfeffc4c4c4c4c4c4c4c4c4c4
8b009b00000000000000000000989b98ab8899ab9f999aaeaf999a9b0d88898a8b000000000000000000000000000000000000000070505050505050505050505050507272768e3d3d3db5000000405151515176b8aeaf9fb900a4a50000a8af00baab009faebabbafb9babb9f00989b00000000000000000000000000000000
ae00ab898a8b00000000000000989ba8aeaa99998bb8b98baaa9aaab0098999a9b00000000008b88898a8b000000000000000000000000000000a8a9aabb0000000000707272743d3d3d515151517473737374727688afa98b00b4b50000989b888b9f00000000009b0000000000a8abc4000000000000000000000000000000
888b9fb9ba9f8b000000000000a8999aa9baaeb8b900009fbabbba9b00a8a9aaab00000000009fb8b9babb000000000000000000000000000000a8ab9b000000000000007072743d3d3d727474747474747473746198bb99ab0000000000a8999a9b000d0000888b9b000000888b989bc4000000000000000000000000000000
a8ab000000009b000000000000a8999a9b888b000000000088898aab00a8a99aab8b000000000000000000000000000000000000000000000000b89b9f8b0000000000000070503d3d3d7374747373737473747461b899afab8b0000000098a9aaab00000000b8999b000000b8b9a8abc4000000000000000000000000000000
b8bb000000009b000000008889b8afafabb89f8b8b00000098999a9b0098999a9b9b00000000000000000000000000000000000000000000000000ab009f0000000000000000c43d3d3d705050505050505050747241b8bbafab00000000b8b9ba9b8b00008889aaab0000008b00a8abc4000000000000000000000000000000
4100000000009f0000000098bb89aa999b8889a999a98a8ba8a9aaab00a8a9aaab998a8b898a8b00000000008b000088898a8b0088898a8b00888b9b8a8b000000898a898a898b0000008889989bab00888b007072618889989b0d0000000000009fb9000098999a9b000d009f00989bc4000000000000000000000000000000
61008b0000000000000000a8a99b9a99ab98b99fb99fbaa9ab99a99b00a8a99899a99a9b999a9b88898a8b88998b8b98999a998b98999a9b88af9b999a998b0088999a999a99ab00000098999a9b9b009899898b606198999a9b88898a8b000000000000009899aaab0000000000a8abc4000000000000000000000000000000
61009f0000000000000000b8b9b9989999ab456e436f46b8ae9fb99faeb89fa8a9a9aaaba9aaab98999a9ba8a9afaba8a9aaaaaba8a9aaabb8baaeafa9aaab00a8a9aaa9aaa99f000000b8a9aaab9faea8a9aaab6061a8a9aaab98999a9b88898a8b00000098999a9b8b00000000b8bbbaa99aa9a99aaaa9b9bab0b1b1b1b1b2
610000000000000000000000000098999b9f557e537f560000000000000000b8b9b9babb9fbabbb8aeb8aeb8b9b89fb8b9babaabb8b9989b000000b8b9babb00b8b9bab9b8ae00000000009fbabb0000b8b9babb6061b8b9a8a9a8a9aaabb8b9ba9f00888b9899bbaaab0000000088898baeb8b99fb9babb0000b3bdbe00bdb3
7276000000000000000000000000a8a9ab00696263646a000000000000000000000000000000000000000000000000000000009f0000baae000000000000000000000000000000000000000000000000000d004073725176bab9b8b9babb000000000098999a9b00baab00000000a8a99b88898a8b0000000000b3bebdbe00b3
7461000000000000000000000000b8b9bb00000000000000000000000d00000000000000000000000000456e436f4600000000b0b200000000000000000000000000000000000000000000000000000000000060747474725151515151515151515141a8a9aaab000099898a8b8b989999a9999a998b00000000b3bdbe00beb3
726100000000000000000000000000000000000000000000000000000000000000000000000000000000557e537f5600000000000000000000000000000000000000000000000000000000000000000000000070727473737474735050505050505071b8b9babb0000a99999a999a8a9a9aaa9aaa99f00000000b300000000b3
727376000000000000000000000000000000000000000000000000000000000000000000000000000000696263646a0000000000000d000000000000000000000000000000000000000000000000000000000000707274747350710000000000000000000000000000b8bb9fa8a9aaa9aaab9fbabb0000000000b0b20000b0b2
7474727600bfacad0000000000000000000000000000000000000088898a8b88898a8b42434400000000000000000000000000b0b200000000000d00000000000000000000000000000000000000000000000d000060737371000000000000000000454f6e436f4f46000000bab9b8b9babb000000000d000000000000000098
70747461dcbc10bcdcdc00000000000000000000000d000000008baf999a999a999a9b52755400000000000000000000000000b300000000000000000000000000000000000000000000000d0000000000000000006074610000000000000000008b555f7e537f5f568b000000000000000000000000000000000000000000a8
8b7072724100000000000000000088898a8b0000000000000088a9aaa9aaa9aaa9aaab69006a00000000006768000000000000b3000000000000000000000000000d000000000000000000000000000000000000cd607461cd00000000000000009f65666263646566ae0000000088898a898a898a8b000000000000000000a8
ae8b6074610d00000000008b000098999a9b00000000000000b8b9babbbab9b8b9babb0000000000000d007778000000000000b300000000000000000000000000000000000000888b00000000000000000000003d3d3d3d3d000000000000000000000000000000000000000000b8b9bab9bab9babb00000000000000000098
8a9b70747276000d0000009f0088afa9aaab0000456e046f464051515151515151515176000000000000000000000000000000b30000000000888b000000000000000000000000b8bb00000000000000000000003d3d3d3d3d0000000000000000000000000000000000000d00888b888b8b8b888b00000000008b8b000d00a8
9a9b8b70727476000000000000b8b8b9baae0000696263646a60737474747274737474725141000000000000000d0000000000b30000000000b8bb00000000000000000000000000000000000000008b000000003d3d3d3d3d0000000000000000000000000000000000000000a899a9aaa99fba9f00000000009fae00000098
98aeab007072727600000000000000000000000000000000006074747274747474747473747251760000000000000000000088b38b00000000000000000000000000000000000088898a8b000000009f000000888b6074610000000000008b0000000000000000000000000000b8b9b9b8b900000000000000000000000000af
bb009f0d00707272760000000000000000000000000000004073747474747474737474747474747251515151410000000088af99ab00000000000000000000000000000000000098999a9b00008b0000000000b8bb6073725151515151769f0000000d000000000000000000000000000000000000000000000000000000009b
8b0000008b0070727276dcdc0000dcdcdcdcdcdcdcdcdc4073747474737474747474747472747474747274747251515176b8bab99f00000000008b88898a8b8b00000000000000a8a9aaab8b8899a989405151515173747474737474727251760000000000000000000000000000000088898a898a898a898a898a898a898aab
ae0000009f00007072725151515151515151515151515173737374747474747474727474747474727472747474727474725151515151515151419fb8b9babb9fb0b1b1b1b1b1b2b8aebabb9fb8bbb8bb607273747374737274727474747472725151515151515151515151515151514198999a999a999a999a999a999a999aab
__sfx__
010500000e2300d3400a4500825006250062500525004250022500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000000133001430c6320062100611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000715000000001400715000000051500510004150021000214004150000000015000100000000015500150000000214004150101000414005150000000715000000091400000007140001310010100101
011000000015000000001400715000000051500510004150021000214004150000000015000000001350013500150000000414005150101000514006150000000715000000091400000007150001000514005141
011000000c053000130c0530b053326150b0130c0530b0530c053326150c053326150901307013326150b0130c053000130c0530b053326150b0130b053326150b053326150c053326150b01302053000530b053
010800000b0130b0130b0230b0230b0330b0330b0430b0430b0530b0530b0530b0530b0530b0530b0530b05300000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c053000130c0530b053326150b0130c0530b0530c053326150c053326150901307013326150b0130c053000130c0530b053326150b0130c0530b0530c053326150c0530b0530b0130b0133261532615
0102000000110001110011100111001210012100121001210013000131021310213103131031310413104131051310513106131061310713107131081310813109131091310a1310a1310b1310b1310c1310c131
011000000c313003220c313003200c312003230c310003220c313003200c312003230c310003220c313003200c312003230c310003220c313003200c312003230c310003220c313003200c312003230c31000322
0110000024437244310c43130530284372843110431347302b4302443118431305302453124435244311843129430244302843024430184311841126430284312843124421214113053024437244311843118531
011000001532309322153130932015312093231531009322153130932015312093231531009322153130932015312093231531009322153130932015312093231531009322153130932015312093231531009322
011000002143023431214303952021435214301f431374102143021430234312143021430234312143021430214301f431214303953021435214301f431374102943030410214302843034410234302443037410
0110000028430284312643034530284372843110431284302b43026430284302b4301f4312b4302643126430294302643028430294302643126430284302b43029430264302843029431294311d4313553026414
011000000c053000130c0530b053326150b0130c0530b053326150b0130b013326150901307013326150b0130c053000130c0530b05332615326150b0530b0530c0533261532615326150b0130e0530c0530b053
011000000c053000130c0530b05332615326150c0530b0530c0530b0130b0130b05332615326150b0150b0130c053000130c0533261532615326150c0533261532615326150b0133261532615326150c0530b053
01100000103230432210313043201031204323103100432210313043201031204323103100432210313043200e312023230e310023220e313023200e312023230e310023220e313023200e312023230e31002322
011000000c313003220c313003200c312003230c310003220c313003200c312003230c310003220c3130032013312073231331007322133130732013312073231331007322133130732013312073231331007322
01100000244302443128430305302643024432244312443126431264312843030530294302b4322b4321f4312b4352b4322943529432284352843229435294322b4352b4322d432375302f4322f4323043224431
011000001705018050180501800121000210012100121001180501a0501a0501a001000000000000000210001a0501c0501c0501c001000000000000000210001300015000150012400021000210011a0501a051
0110000000150001500510005100001500710000150000000215002150021000000002150000000215000000041500415004000051000415004100041500710007150071500b0000000007150170000715005101
011000002b1351b202291350000028135281002613526100281350000026135000002813500000241350000026135000002413500000231350000024135000002613500000000000000000000000002313500000
011000002413500000231350000024135000002613500000261350000024135000002613500000271350000028135000002613500000281350000029135000002b13500000000000000000000000002913500000
011000000705307000051000700132615000000503300000070530000002100000003261500000000000000007053000000010000000326150000005033000000705300000001000000032615000000000000000
011000000c05300000306071a605303050c60530305306070c00300000306070000030305000000b0030b0030c053000003060700000303050000000000000000c00300000306170000018615000000b0030b003
011000000c05300000306071a605186150c60518615306070c00300000306070000030305000000c0230c0030c053000003060700000186150000018615000000c0030000030607000001860500000186050c003
01100000180400000015000000001b0400000018002180421d040000001b040000001804000000160400000014040140001600000000160400000011040000001100000000000000000000000000001304000000
01100000140400000014000000001604000000110401600211000000001100000000180000000013040000001404014000140000000016040000001b0401c0001b00000000000000000000000000000000000000
011000000015018105000000000000000000000015500000051550000000000000000000000000071550000008155000000000000000000000000004155000000515500000000000000000000000000715500100
0110000008145185050000000000000000000004145000000514500000000000000000000000000714500000081452c5050000000000051420510203145000002950500000000000000003145000000214500000
0110000005155181050000000000000000000005155000000815500000081550000000000000000a155000000c155000000000000000000000000008155000000a15500000000000000000000000000815500100
011000000a1451850500000000000000000000081450000005145000000000000000000000000008145000000a1452c5050c000000010c1320512105120000002950500000000000000003145000000114500000
011000001d0400000015000000001f04000000180021b0421d040000001f040000002004000000220400000024040140001b0000000020040000002204018000110001a000180000000000000000002004000000
011000002204000000140000000020040000001d0401600211000000001100000000180000000020040000002204014000140000000024040000001d0401c0001b00000000000000000000000000000000000000
011000000c05300000306071a605186150c60530305306070c053000000c053000001861500000000000c0030c05300000306070000018615000000b043000000c0530000030617000001861500000186050c003
011000001f05021051210511f000210012100121001210012100121001000000000000000000000000021000210012100100000000000000000000000002100021050230512305124000240501f0001f0501d051
011000001d0501d0511e3001e3021e3021e3021d0011d0011c3001a3001730000000173000000000000000001c300000011e3001e3021e3021e30200001000011c3000e000130001f30000000000001a0501a051
011000000415004150051000510005150071000715000000051500000004150000000000000000000000000004150041500000005100051500410007150071000415005100051500000000000000000000004100
011000000515005150051000510005150071000415000000021500000002150000000000000000000000000005150051500000005100051500410004150051000215005100041500000000000000000000004100
0110000018625070300603006051050310403103031000310002100012000020000200000030010600200000040300703006030090000600004000000000900001000000000e000000000f00004000110000f000
011000002f015300152d01528015300152d01529015280152d0152b0152d015290152d015280152b0152d0152f015300152d015340152f015320152d015300152b0152d015280152901526015280152401526015
011000002301524015210151c01524015210151d0151c0151f0151c015210151d015230151c0151f0152301524012240121800118001210051d00523005210052400523005260052400528005260052b00528005
011000000705307003070530700318625186050705307003070530700307053070031862507003186250700307053070030705307003186250700307053070030705307003186250700318625186251862507003
011000000700307003070030700307003070030700307003240032e5002c500240042400524005155002400600003000030000300003000030000300003000030704307023186250703318625186151862518625
011000000705307003070530700318625070030705307003070530700307053070031862507003070530700307053070030705307003186250700307053070030705307003070530700318625070031862507003
0102000000000000000000000000000000000000000000000b0000b0020b0020b0020b0020b0020b0020b0020b0300b0320b0320b0320b0320b0320b0320b0320b0000b0010b0010b0010b001000000b00000000
011000001c320230001e3201e3221e3221e3221d0001d0001c3201a3201732000000173000000000000000001c320000001e3201e3221e3221e32200000000001c320213201e3201f30000000000000000000000
011000001c320230001e3201e3221e3221e3221d0001d0001c3201a320173200000017300000000000000000153201a320173201e3021e3021e30200001000011c300213001e3001f30000000000000000000000
0110000009030090310b030090000b030090300b030090000b030090300b030090000b030090300b030090000b030090300b030090000b030090300b030090000b030090300b030090000b030090300b03009000
011000000703007031060300900006030040300603009000060300403006030090000603004030060300900006030040300603009000060300403006030090000603004030060300900006030040300603009000
011000001f320177001e3201e3221e3221e3221d0001d0001c3201d3201e32000000173000000000000000001f320000001e3201e3221e3221e32200000000001c320213201e3201f30000000000000000000000
011000001f320230001e3201e3221e3221e3221d0001d0001c3201d3201e32000000173000000000000000001c3201f3201e3201e3021e3021e30200001000011c300213001e3001f30000000000000000000000
011000002a3202d3202f3202f3222f3222f3222f32223321000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000009030090310b0300b0320b0320b0320b03200021060000400006000090000600004000060000900006000040000600009000060000400006000090000600004000060000900006000040000600009000
011000002e0222e0222e020001002b0200010027020001002e020001002900000100270000010029020001002b020001002e0200010030020001002e020001002b0200010029020001002702000100260200c000
011000000c04324500245002450028615245000c043286150c003286150c003000002861500000000000b0230c04324500245002450028615245000c043286150c003286150c0032450028615245002861524500
011000000015000151001510015100121001010010200150001510010100150001510012102701007010015500150001510015100152001210010100102001500015100101001500015100121007010a1400a141
011000000315003151031510315103121001010010203150031510010103150031510312102701007010315503150031510315103152031210010100102031500315100101031500315103121007010714007141
011000000e5500f5520f5520000011550000001355000000135500000011550000000f5500f5020f502000000f550000001155000000135500000011550000000f550000000e550000000f550000000c55000000
011000000e5500f5520f552000000f550000000c550000000f55000000115000000011500000001155211552135500000011550000000f550000000e550000000c550000000a550000000c550000000e55000000
__music__
01 2c 42 43 44
04 2d 42 43 44
00 0c 0a 43 44
01 0b 0e 0d 44
00 09 0e 0d 44
00 0b 11 14 44
00 09 11 14 44
00 13 16 15 44
00 0b 0e 0d 44
00 09 0e 0d 44
00 12 10 0f 44
00 0b 0e 0d 44
00 09 11 14 44
00 0b 11 14 44
02 13 16 15 44
01 19 1b 43 07
00 1a 1b 43 08
00 19 1b 43 07
02 1a 1b 2f 08
01 1e 1c 20 44
00 1f 1c 21 44
01 1e 1d 20 44
00 1f 1d 21 44
01 1e 26 20 44
00 1f 26 21 44
00 1e 26 20 44
00 1f 26 21 44
00 24 26 22 44
00 25 26 23 44
00 24 26 22 44
02 25 26 23 44
01 3b 29 27 44
00 3b 2a 28 44
00 3b 29 27 44
00 3b 2a 28 44
00 3b 18 17 44
02 3b 18 17 44
04 38 39 43 44
00 31 42 43 44
01 32 34 43 44
00 33 34 2f 44
00 36 35 30 44
00 37 35 30 44
01 32 34 30 44
00 33 34 30 44
00 36 35 30 44
00 37 35 2e 44
00 32 34 30 44
00 33 34 30 44
00 36 35 30 44
02 37 2b 2f 44
01 3c 42 3e 44
00 3d 42 3f 44
00 3c 3b 3e 44
00 3d 3b 3f 44
00 3c 42 3e 3a
00 3d 42 3f 3a
00 3c 3b 3e 3a
00 3d 3b 3f 3a
00 3f 42 3e 3a
00 3c 3b 43 44
00 3d 3b 43 44
00 3c 3b 43 44
02 3d 3b 43 44
