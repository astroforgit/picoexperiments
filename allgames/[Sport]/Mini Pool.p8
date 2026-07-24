pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- mini pool
-- by shaylin chetty

function _init()
	init_title()
	scene=scenes.title
end

function _update60()
	if scene==scenes.title then
 	update_title()
 elseif scene==scenes.characters then
  update_characters()
 elseif scene==scenes.pool then
  update_pool()
 elseif scene==scenes.summary then
  update_summary()
 end
end

function _draw()
 cls()
 if scene==scenes.title then
 	draw_title()
 elseif scene==scenes.characters then
  draw_characters()
 elseif scene==scenes.pool then
  draw_pool()
 elseif scene==scenes.summary then
  draw_summary()
 end
end

scenes={
	title="title",
 characters="characters",
	pool="pool",
	summary="summary"
}
        
pool_states={
	start="start",
	turn="turn"
}

turn_states={
	enter="enter",
	aim="aim",
	power="power",
	wait="wait",
	exit="exit"
}

colour_names={
	black="black",
	white="white",
	orange="orange",
	blue="blue"
}

colours={
	black=0,
	white=7,
	orange=9,
	blue=1
}

highlights={
	black=6,
	white=7,
	orange=10,
	blue=12
}

friction_factor = -0.02

characters={
	{
		name="the architect",
		power=2,
		finesse=5,
		luck=1,
		skill="second wind\ngives cue ball \nsecondary\nmotion",
		track=53,
		sprite=1,
		power_sprite=64,
		win_msg="*pushes up glasses*\njust as i planned.",
		lose_msg="this is impossible!\nhow could this be?"
	},
	{
	 name="the gambler",
	 power=5,
	 finesse=1,
	 luck=2,
	 power_sprite=66,
	 skill="would smash\nincreases shot\npower",
	 track=13,
	 sprite=3,
	 win_msg="valiant effort, lad.",
		lose_msg="this is what happens when\nyou don't smash."
	},
	{
	 name="the fear",
	 power=4,
	 finesse=3,
	 luck=2,
	 power_sprite=68,
	 skill="disorient\nreduces\nopponent's shot\npower",
	 track=37,
	 sprite=5,
	 win_msg="what's the matter?\ndo you feel your life\nebbing away?",
		lose_msg="darkness claims us\nall eventually..."
	},
	{
	 name="the virtuous",
	 power=3,
	 finesse=3,
	 luck=3,
	 power_sprite=69,
	 skill="holy diver\nsinks the first\nball the cue\ntouches",
	 track=21,
	 sprite=7,
	 win_msg="looks like you were\nno match for the power\nof my holy diver.",
		lose_msg="what's becoming of me..."
	},
	{
	 name="the lost",
	 power=3,
	 finesse=4,
	 luck=1,
	 power_sprite=65,
	 skill="winds of change\ninfluences \nmotion of all\nballs",
	 track=45,
	 sprite=9,
	 win_msg="do you hear that?\nthat's the sound of\na new champion.",
		lose_msg="ridiculous.\ni demand a rematch!"
	},
	{
	 name="the trickster",
	 power=3,
	 finesse=2,
	 luck=5,
	 power_sprite=67,
	 skill="chaser\nblack ball\nintercepts\nopponent's shot",
	 track=29,
	 sprite=11,
	 win_msg="you thought you were\nfacing an ordinary\nopponent. but it was me!\nthe trickster!",
		lose_msg="look again!\nyou sunk the wrong ball!"
	}
}
-->8
function init_title()
	show_prompt=true
	prompt_time=time()
	create_light_scroll()
	music(0, 200)
end
 
function draw_title()
 draw_lights()
 
	spr(208,16,32,12,3)
	if show_prompt then
	 print("press — to start",30,90, 7)
	end
end

function update_title()
  update_lights()
  
		if (btnp(5)) then 
		 scene=scenes.characters
		 sfx(62)
		 init_characters()
		end
		
		if time() - prompt_time > 0.75 then
			prompt_time=time()
			show_prompt = not show_prompt
		end
end

function create_light_scroll()
	lights={}
	
	for i=1,200 do
		create_light(rnd(128),rnd(128))
	end
end

function create_light(x,y)
	local ting=rnd()
	local colour=3
	
	if ting > 0.5 then
	 colour=4
	end
	
	add(lights, {
		x=x,
		y=y,
		colour=colour
	})
end

function update_lights()
	for light in all(lights) do
		light.y-=1
		if light.y<0 then
			light.y=130
			light.x=rnd(128)
		end
	end
end

function draw_lights()
	for light in all(lights) do
		line(light.x,light.y,
		     light.x,light.y-1,
		     light.colour)
	end
end
-->8
selection_states={
	player1="player1",
	player2="player2",
	confirm="confirm"
}

function init_characters()
 player1={
	 character=1,
	 ball_colour=nil,
	 balls_sunk=0,
	 won=false,
	 turns_left=1,
	 power=true
 }

 player2={
	 character=3,
	 ball_colour=nil,
	 balls_sunk=0,
	 won=false,
	 turns_left=1,
	 power=true
 }

 current_player=1
 selection_state=selection_states.player1
end

function draw_characters()
 if selection_state==selection_states.player1 then
		print("select player 1",36,2,12)
		draw_selection(player1, 12)
		draw_player1_info()
	elseif selection_state==selection_states.player2 then
	 print("select player 2",36,2,9)
		draw_selection(player2, 9)
		draw_player1_info()
		draw_player2_info()
	else
		print("press — to start",32,2,7)
	 draw_player1_info()
		draw_player2_info()
	end	
 
 draw_portraits()
end

function update_characters()
 if selection_state==selection_states.player1 then
		if btnp(5) then 
			selection_state=selection_states.player2
			sfx(62)
		end
		move_character_selection(player1)
	elseif selection_state==selection_states.player2 then
	 if btnp(5) then 
	  selection_state=selection_states.confirm
			sfx(62)
		end
		if btnp(4) then 
			selection_state=selection_states.player1
			sfx(62)
		end
		move_character_selection(player2)
	else
		if btnp(5) then
			init_pool()
		 sfx(62)
		end
		if btnp(4) then 
			selection_state=selection_states.player2
			sfx(63)
		end
	end	
end

function move_character_selection(player)
 if btnp(0) then
 	if player.character==1 then return end
		player.character-=1
		selection_move_sound()
	elseif btnp(1) then
	 if player.character==6 then return end
	 player.character+=1
	 selection_move_sound()
	elseif btnp(2) then
	 if player.character<=3 then return end
		player.character-=3
		selection_move_sound()
	elseif btnp(3) then
	if player.character>=4 then return end
		player.character+=3
		selection_move_sound()
	end
end

function selection_move_sound()
 if selection_state!=selection_states.confirm then
		sfx(28)
	end
end

function draw_portraits()
	spr(1,20,16,2,2)
	spr(3,56,16,2,2)
	spr(5,92,16,2,2)
	spr(7,20,40,2,2)
	spr(9,56,40,2,2)
	spr(11,92,40,2,2)
end

function draw_selection(player, col)
	if player.character == 1 then
	 draw_selection_rect(20,16,col)
	elseif player.character == 2 then
	 draw_selection_rect(56,16,col)
	elseif player.character == 3 then
	 draw_selection_rect(92,16,col)
	elseif player.character == 4 then
	 draw_selection_rect(20,40,col)
	elseif player.character == 5 then
	 draw_selection_rect(56,40,col)
	elseif player.character == 6 then
	 draw_selection_rect(92,40,col)
	end
end

function draw_selection_rect(x,y,col)
 	rect(x-1,y-1,x+16,y+16,col)
end

function draw_player1_info()
	print(characters[player1.character].name,
	      0,64,12)
	print("power:", 0,72,12)
	draw_stat_rect(32,72,
	               characters[player1.character].power)
	print("finesse:", 0,80, 12)
	draw_stat_rect(32,80,
	               characters[player1.character].finesse)
	print("luck:", 0,88, 12)
	draw_stat_rect(32,88,
	               characters[player1.character].luck)
	
	print("skill:",0,96,6)
	print(characters[player1.character].skill, 0,104, 12)
end

function draw_player2_info()
 print(characters[player2.character].name,
	      64,64,9)
	print("power:", 64,72,9)
	draw_stat_rect(96,72,
	               characters[player2.character].power)
	print("finesse:", 64,80, 9)
	draw_stat_rect(96,80,
	               characters[player2.character].finesse)
	print("luck:", 64,88, 9)
	draw_stat_rect(96,88,
	               characters[player2.character].luck)
	
	print("skill:",64,96,6)
	print(characters[player2.character].skill, 64,104, 9)

end

function draw_stat_rect(x,y,width)
	if width==1 then
		rectfill(x,y,x+width*5,y+4,8) 
	elseif width==2 then
	 rectfill(x,y,x+width*5,y+4,14)
	elseif width==3 then
	 rectfill(x,y,x+width*5,y+4,9)
	elseif width==4 then
	 rectfill(x,y,x+width*5,y+4,10)
	elseif width==5 then
	 rectfill(x,y,x+width*5,y+4,11)
	end
end
-->8
function draw_summary()
	draw_player1()
	draw_player2()
end

function draw_player1()
 local c1=characters[player1.character]
 spr(c1.sprite,16,16,2,2)
 
 local msg="loser"
 local text=c1.lose_msg
 if player1.won then
 	msg="winner"
 	text=c1.win_msg
 end
 
 print(msg,38,16,7)
 print(text,16,36,6)
 
 if player1.balls_sunk > 0 then
	 for i=1,player1.balls_sunk do
	  circ(32 + i*8, 27, 3, get_player_line_colour(player1))
	 end
 end
end

function draw_player2()
 local c2=characters[player2.character]
 spr(c2.sprite,16,80,2,2)
 
 local msg="loser"
 local text=c2.lose_msg
 if player2.won then
 	msg="winner"
 	text=c2.win_msg
 end
 
 print(msg,38,80,7)
 print(text,16,100,6)
 
 if player2.balls_sunk > 0 then
	 for i=1,player2.balls_sunk do
	  circ(32 + i*8, 91, 3, get_player_line_colour(player2))
	 end
 end
end

function update_summary()
 if btnp(5) then
 	 init_title()
 		scene=scenes.title
 end
end
-->8
--pool flow

function init_pool()
	balls={}
	sunk_balls={}
	turn_sunk_balls={}
	current_track=0
	
	create_ball(64,96,4,2,colour_names.white)
	
	create_ball(64,40,4,2,colour_names.black)
	
	white_ball=balls[1]
	black_ball=balls[2]
	
	create_ball(64,24,4,2,colour_names.orange)
	create_ball(60,32,4,2,colour_names.blue)
	create_ball(68,32,4,2,colour_names.blue)
	create_ball(56,40,4,2,colour_names.orange)
	create_ball(72,40,4,2,colour_names.blue)
	create_ball(60,48,4,2,colour_names.orange)
	create_ball(68,48,4,2,colour_names.orange)
	create_ball(64,56,4,2,colour_names.blue)
	
	fade_out_time=time()
	fade_int_time=time()
	
	switching=false
	
	scene=scenes.pool
	
	modal_start_time=time()
 modal_message="start"
	
	power_active=false
	
	chaser=false
	would_smash=false
	second_wind=false
	disorient=false
	winds_of_change=false
	holy_diver=false
	
	pool_state=pool_states.start	
	current_player=1
end

function update_pool()
	update_balls()
	update_particles()

	if pool_state==pool_states.start then
		update_start()	
	elseif pool_state==pool_states.turn then
	 update_turn()
	end
end

function update_start()
	local elapsed = time() - modal_start_time
	if elapsed > 1.3 then
	 current_player=1
  pool_state=pool_states.turn
	 turn_state=turn_states.enter
	end
end

function draw_pool()
 map(0,0,0,0,128,128)
 draw_balls()
 draw_player_panels()
 
 if pool_state==pool_states.start then
	
	elseif pool_state==pool_states.turn then
	 draw_turn() 
	
	end
	
	draw_particles()
	
	draw_modal(modal_start_time)
end

function draw_modal(start_time)
	local elapsed = time() - start_time
	
	if elapsed < 0.5 then
		rectfill(0, 50, elapsed*256, 70, 0)
		rectfill((0.5-elapsed)*256, 55, 128, 65, 5)
	elseif elapsed < 1.3 then
		rectfill(0, 50, 128, 70, 0)
		rectfill(0, 55, 128, 65, 5)
		print(modal_message, 64-#modal_message*2, 58, 7)
	else
	
	end
end

function draw_player_panels()
 rectfill(1,0,126,7,get_player_colour(player1))
 line(1,7,126,7,get_player_line_colour(player1))
 print("p1-", 2, 1, 7);
 print(characters[player1.character].name, 14, 1, 7)
 
 if player1.power then
 spr(characters[player1.character].power_sprite,
  118, 1, 1, 1);
	end

 if player1.balls_sunk > 0 then
	 for i=1,player1.balls_sunk do
	  circ(110 - i*8, 3, 2, get_player_line_colour(player1))
	 end
 end
 
 rectfill(1,120,126,127,get_player_colour(player2))
 line(1,120,126,120,get_player_line_colour(player2))
 print("p2-", 2, 122, 7);
 print(characters[player2.character].name, 14, 122, 7)
	
	if player2.power then
  spr(characters[player2.character].power_sprite,
  118, 122, 1, 1);	
	end

	if player2.balls_sunk > 0 then
	 for i=1,player2.balls_sunk do
	  circ(110 - i*8, 124, 2, get_player_line_colour(player2))
	 end
	end
end

function get_player_colour(player)
	if player.ball_colour==nil then
		return 5
	elseif player.ball_colour==colour_names.orange then
		return 9
	elseif player.ball_colour==colour_names.blue then
		return 1
	end
end

function get_player_line_colour(player)
 if player.ball_colour==nil then
		return 6
	elseif player.ball_colour==colour_names.orange then
		return 10
	elseif player.ball_colour==colour_names.blue then
		return 12
	end
end
-->8
--turn flow

function get_current_player()
 if current_player==1 then
		return player1
	elseif current_player==2 then
		return player2
	end
end

function get_other_player()
 if current_player==1 then
		return player2
	elseif current_player==2 then
		return player1
	end
end

function toggle_current_player()
	if current_player==1 then
		current_player=2
	elseif current_player==2 then
		current_player=1
	end 
end

function get_current_character() 	
	return characters[get_current_player().character]
end

function update_turn()
 if turn_state==turn_states.enter then
  update_enter()
	elseif turn_state==turn_states.aim then
	 update_aim()
	elseif turn_state==turn_states.power then
	 update_power()
	elseif turn_state==turn_states.wait then
	 update_wait()
	elseif turn_state==turn_states.exit then
	 update_exit()
	end
	
	local char=get_current_character()
	
	if switching then
	 if time()-fade_out_time > 0.75 then
	  music(current_track, 700)
	  switching=false
	 end
	else
	 if current_track!=char.track then
		 switching=true
		 music(-1, 700)
		 current_track=char.track
		 fade_out_time=time()
	 end
	end
end

function update_aim()
	if aim_angle > 1.0 then
		aim_angle=0
	elseif aim_angle < 0.0 then
		aim_angle=1.0
	end
	
	if btn(0) then
		aim_angle+=0.005
	end
	
	if btn(1) then
		aim_angle-=0.005
	end
	
	local p=get_current_player()
	
	if btnp(4) and btnp(5) and p.power then
	 p.power=false
	 local y_pos=2 + (current_player-1)*116 
	 create_particle_bloom(120, y_pos, colour_names.white)
  activate_character_power()
	elseif btnp(5) then
		turn_state=turn_states.power
	end
end

function activate_character_power()
local c=get_current_character()
	sfx(62)
	set_by_player=current_player
	if c.name=="the architect" then
	 second_wind=true 
	 printh("activating second wind")
	elseif c.name=="the gambler" then
	 would_smash=true
	elseif c.name=="the fear" then
	 disorient=true
	elseif c.name=="the virtuous" then
	 holy_diver=true
	elseif c.name=="the lost" then
	 winds_of_change=true
	elseif c.name=="the trickster" then
	 chaser=true
	end
end

function deactivate_character_power()
 printh("deactivate power")
 local c=get_current_character()
 //deactivates at end of turn
 second_wind=false
	would_smash=false
	holy_diver=false
	winds_of_change=false
	
	if current_player!=set_by_player then
	 disorient=false
	 chase=false
	end

end

function update_power()
	if power > 1.0 then
		power=1.0
	elseif power < 0.0 then
		power=0.0
	end
	
	if btn(0) then
		power-=0.01
	end
	
	if btn(1) then
		power+=0.01
	end

	if btnp(4) then
		turn_state=turn_states.aim
	end
	
	if btnp(5) then
		local shot_pow=power*get_current_character().power + 0.2
	
		if would_smash then
			shot_pow*=2
			would_smash=false
		end
		
		//todo: sheet - cant base it on name
		local c=get_current_character()
		if current_player!=set_by_player and disorient then
	  printh("disorient")
	  shot_pow*=0.2
	  disorient=false
	 end
	 
	 if current_player!=set_by_player and chaser then
	  printh("chaser")
	  chaser=false
	 	black_ball.vx=(white_ball.x - black_ball.x) * 0.1
	 	black_ball.vy=(white_ball.y - black_ball.y) * 0.1
	 end
	 
	 if winds_of_change then
	 	for ball in all(balls) do
	 		ball.vx=shot_pow*cos(aim_angle)*0.1
	 		ball.vy=shot_pow*sin(aim_angle)*0.1
	 	end
	 	winds_of_change=false
	 end
	
		white_ball.vx=shot_pow*cos(aim_angle)
		white_ball.vy=shot_pow*sin(aim_angle) 
		
		turn_time=time()
		turn_state=turn_states.wait
	end
end

function update_wait()
	if time()-turn_time < 3.0 then
	 if second_wind then
	 	if btnp(0) then
	 		white_ball.vx=-power*2
	 		white_ball.vy=0
	 		second_wind=false
	 	elseif btnp(2) then
	 	 white_ball.vx=0
	 		white_ball.vy=-power*2
	 		second_wind=false
	 	elseif btnp(1) then
	 	 white_ball.vx=power*2
	 		white_ball.vy=0
	 		second_wind=false
	 	elseif btnp(3) then
	 	 white_ball.vx=0
	 		white_ball.vy=power*2
	 		second_wind=false
	 	end 
	 end
	 
	 if holy_diver then
	 	if first_collision!=nil then
	 		create_particle_bloom(first_collision.x, first_collision.y, first_collision.colourname)
	 		
	 		white_ball.vx=0
	 		white_ball.vy=0
	 		
	 		add(turn_sunk_balls, first_collision)
	 		del(balls, first_collision)
	 		turn_time-=2.0
	 		holy_diver=false
	 	end
	 end
	 
	 return
	end

	for ball in all(balls) do
		if ball.vx > 0 then
			return
		end
		if ball.vy > 0 then
			return
		end
	end
	
	turn_state=turn_states.exit
end

function update_enter()
		modal_start_time=time()
  modal_message=get_current_character().name
  
  if white_was_sunk() then
	 	white_ball.x=64
	 	white_ball.y=96
	 	add(balls, white_ball)
	 	del(turn_sunk_balls, white_ball)
  end
  
  for ball in all(turn_sunk_balls) do
	 	add(sunk_balls, ball)
	 	
	 	if ball.colourname==get_current_player().ball_colour then
    local p=get_current_player()
	 	 p.balls_sunk+=1
	 	else
	 	 local p=get_other_player()
	 	 p.balls_sunk+=1
	 	end
	 	
	 	del(turn_sunk_balls, ball)
  end
  
  printh("enter")
  first_collision=nil
  turn_state=turn_states.aim
		aim_angle=0.25
		power=0.5
end

function update_exit()
 if game_was_won() then
  get_current_player().won=true
  printh("game was won")
  music(0, 1000)
  scene=scenes.summary
  return
 elseif game_was_lost() then
  get_other_player().won=true
  printh("game was lost")
  scene=scenes.summary
  music(0, 1000)
  return
 else
 
 end
 
 deactivate_character_power()
 
 set_next_player()
 
	allocate_colours()
	
	turn_state=turn_states.enter
	pool_state=pool_states.turn
end

function allocate_colours()
	if player1.ball_colour!=nil then
		return
	end

	for ball in all(turn_sunk_balls) do
 	if ball.colourname==colour_names.blue then
 	 printh("player is blue")
 	 local curr_p = get_current_player()
 	 local other_p = get_other_player()
 	 curr_p.ball_colour=colour_names.blue
 	 other_p.ball_colour=colour_names.orange
 	 return
 	elseif ball.colourname==colour_names.orange then
   printh("player is orange")
 	 local curr_p = get_current_player()
 	 local other_p = get_other_player()
 	 curr_p.ball_colour=colour_names.orange
 	 other_p.ball_colour=colour_names.blue
 	 return
 	end	
 end
end

function set_next_player() 
	if white_was_sunk() then
	 other_player_gets_two_turns()
	elseif was_invalid_collision() then
	 other_player_gets_two_turns()
	elseif sunk_opponents_ball() then
		other_player_gets_two_turns()
	elseif sunk_valid_ball() then
		player_gets_one_more_turn()
	elseif had_two_turns() then
	 player_gets_one_more_turn()
	else
		other_player_gets_one_turn()
	end
end

function had_two_turns()
	if get_current_player().turns_left==2 then
				printh("had two turns")
		return true
	end
		return false
end

function sunk_valid_ball()
 for ball in all(turn_sunk_balls) do
 	if ball.colourname==get_current_player().ball_colour or get_current_player().ball_colour==nil  then
 		printh("sunk valid ball")
 		return true
 	end
 end
 return false
end

function sunk_opponents_ball()
	for ball in all(turn_sunk_balls) do
 	if ball.colourname==get_other_player().ball_colour then
 		printh("sunk opponents ball")
 		return true
 	end
 end
 return false
end

function was_invalid_collision()
	if get_current_player().ball_colour==nil then
		return false
	elseif first_collision==nil then
		printh("no ball hit")
		return true
	elseif first_collision.colourname!=get_current_player().ball_colour and get_current_player().balls_sunk<4 then
		printh("hit wrong ball")
		printh("first_collision")
		printh(first_collision.colourname)
		printh("plauyer colour")
		printh(get_current_player().ball_colour)
		return true
	end
	
	return false
end

function other_player_gets_two_turns()
 printh("other player gets 2")
 get_other_player().turns_left=2
	get_current_player().turns_left=1
	toggle_current_player()
end

function other_player_gets_one_turn()
 printh("other player gets 1")
 get_other_player().turns_left=1
	get_current_player().turns_left=1
	toggle_current_player()
end

function player_gets_one_more_turn()
 printh("player gets 1 more")
 get_other_player().turns_left=1
	get_current_player().turns_left=1
end

function game_was_won()
 local curr_player=get_current_player()
 if curr_player.balls_sunk==4 and black_was_sunk() and #turn_sunk_balls==1 then
 	return true
 end
 return false
end

function game_was_lost()
 local curr_player=get_current_player()
 if curr_player.balls_sunk<4 and black_was_sunk() then
 	return true
 elseif white_was_sunk() and black_was_sunk() then
 	return true
 end
 return false
end

function black_was_sunk()
 for ball in all(turn_sunk_balls) do
 	if ball.colourname==colour_names.black then
 		return true
 	end
 end
 return false
end

function white_was_sunk()
 for ball in all(turn_sunk_balls) do
 	if ball.colourname==colour_names.white then
 		return true
 	end
 end
 return false
end

function draw_turn()
 if turn_state==turn_states.enter then
	 draw_enter()
	elseif turn_state==turn_states.aim then
	 draw_aim()
	elseif turn_state==turn_states.power then
	 draw_aim()
	 draw_power()
	elseif turn_state==turn_states.wait then
	 draw_wait()
	elseif turn_state==turn_states.exit then
	 draw_exit()
	end
end

function draw_enter()
 
end

function draw_aim()
	local character=get_current_character()
	
	local radius=character.finesse * 6 - 2

 local start_x = white_ball.x
 local start_y = white_ball.y
 local end_x = start_x + (radius * cos(aim_angle))
 local end_y = start_y + (radius * sin(aim_angle))

	local col=get_player_line_colour(get_current_player()) 

	line(start_x, start_y, end_x, end_y, col)
end

function draw_power()
 local character=get_current_character()
	local max_pow=character.power
	
	if max_pow==1 then
	 spr(62,55,80,2,1)
	 rectfill(57+power*13,81,70,86,5)
	elseif max_pow==2 then
	 spr(59,51,80,3,1)
	 rectfill(53+power*21,81,74,86,5)
	elseif max_pow==3 then
	 spr(44,47,80,4,1)
	 rectfill(49+power*29,81,78,86,5)
	elseif max_pow==4 then
	 spr(54,43,80,5,1)
	 rectfill(45+power*37,81,82,86,5)
	elseif max_pow==5 then
	 spr(38,39,80,6,1) 
	 rectfill(41+power*45,81,86,86,5)
	end
	
end

function draw_wait()

end

function draw_exit()

end
-->8
--pool simulation

collidingpairs = {}

function create_ball(x, y, radius, mass, colourname)
 add(balls, {
  id=#balls,
  radius=radius,
  x=x,
  y=y,
  vx=0.0,
  vy=0.0,
  ax=0.0,
  ay=0.0,
  mass=mass,
  colourname=colourname,
  sunk=false
  })
end

function docirclesoverlap(ball1,ball2)
 return abs((ball1.x - ball2.x)*(ball1.x - ball2.x) + 
        (ball1.y - ball2.y)*(ball1.y - ball2.y))
        <= ((ball1.radius + ball2.radius) * (ball1.radius + ball2.radius))  
end

function ispointincircle(ball, x, y)
 return abs((ball.x - x)*(ball.x - x) + (ball.y - y)*(ball.y - y) ) < (ball.radius*ball.radius)
end
    
function update_balls()
 collidingpairs = {}

 for ball in all(balls) do
  
  handle_motion(ball)

  handle_cush_bounce(ball)

  if (abs(ball.vx *ball.vx + ball.vy*ball.vy) < 0.0001) then
      ball.vx = 0
      ball.vy = 0 
  end

	 determine_collisions(ball)
 end

 handle_collisions()
end

function handle_motion(ball)
 ball.ax = ball.vx * friction_factor
 ball.ay = ball.vy * friction_factor

 ball.vx = ball.vx + ball.ax
 ball.vy = ball.vy + ball.ay

 ball.x = ball.x + ball.vx
 ball.y = ball.y + ball.vy
end

function handle_cush_bounce(ball)
 if ball.x > 116 then
  	ball.x = 116
   ball.vx *= get_cush_factor(ball.vx)
 elseif ball.x < 11 then
   ball.x = 11
   ball.vx *= get_cush_factor(ball.vx)
 end

 if ball.y > 108 then
   ball.y = 108
   ball.vy *= get_cush_factor(ball.vy)
 elseif ball.y < 20 then
   ball.y = 20
   ball.vy *= get_cush_factor(ball.vy)
 end
end

function get_cush_factor(v)
 local c=get_current_character()
	local luck_factor=c.luck/-3.8

	//return abs(v/(abs(v)+1))*-1
	return abs(v/(abs(v)+1))*luck_factor
end

function determine_collisions(ball)
for ball_t in all(balls) do
   if ball.id != ball_t.id then
    if docirclesoverlap(ball,ball_t) then
     
     if ball.vx==0 and ball.vy==0 and ball_t.vx==0 and ball_t.vy ==0 then
     	return
    	end
    	
    	if first_collision==nil then
    	 if ball.colourname==colour_names.white then
    	  first_collision=ball_t
    	 elseif ball_t.colourname==colour_names.white then
    	  first_collision=ball
    	 end
    	end
        
	    add(collidingpairs, { ball, ball_t })
					
	    --distance between ball centers
	    local dist = sqrt( (ball.x - ball_t.x)*(ball.x - ball_t.x) + (ball.y - ball_t.y)*(ball.y - ball_t.y) )
	
	    local overlap = (dist - (ball.radius+ball_t.radius)) / 2
	    
	    --displace the current ball
	    ball.x -= overlap * ((ball.x - ball_t.x) / dist)
	    ball.y -= overlap * ((ball.y - ball_t.y) / dist)
	    
	    --displace the target ball
	    ball_t.x += overlap * ((ball.x - ball_t.x) / dist)
	    ball_t.y += overlap * ((ball.y - ball_t.y) / dist)
    end
   end
	 end
end

function handle_collisions()
 for pair in all(collidingpairs) do
  local b1 = pair[1]
  local b2 = pair[2]

  local dist = sqrt( (b1.x - b2.x)*(b1.x - b2.x) + (b1.y - b2.y)*(b1.y - b2.y) )

  --normal vector
  local nx = (b2.x - b1.x) / dist
  local ny = (b2.y - b1.y) / dist

  --tangent vector
  local tx = -ny
  local ty = nx

  -- dot product tangent
  local dpT1 = b1.vx * tx + b1.vy * ty
  local dpT2 = b2.vx * tx + b2.vy * ty

  -- dot product normal
  local dpN1 = b1.vx * nx + b1.vy * ny
  local dpN2 = b2.vx * nx + b2.vy * ny

  local m1 = ( dpN1 * (b1.mass - b2.mass ) + 2.0 * b2.mass * dpN2 ) / ( b1.mass + b2.mass)
  local m2 = ( dpN2 * (b2.mass - b1.mass ) + 2.0 * b1.mass * dpN1 ) / ( b2.mass + b1.mass)
  
  //todo: make the random modifier luck based
  b1.vx = tx * dpT1 + nx * m1
  b1.vy = ty * dpT1 + ny * m1
  b2.vx = tx * dpT2 + nx * m2
  b2.vy = ty * dpT2 + ny * m2
 end
end

function draw_balls()
 for ball in all(balls) do
 
	 if was_ball_sunk(ball) then
	  ball.vx=0
	  ball.vy=0
	  ball.ax=0
	  ball.ay=0
	  add(turn_sunk_balls, ball)
	  del(balls, ball)
	  create_particle_bloom(ball.x, ball.y, ball.colourname)
	 	screen_shake(1)
	 	sfx(62, 3)
	 end
	 
	 for pair in all(collidingpairs) do
	  local b1 = pair[1]
	  local b2 = pair[2]
   circ(b1.x,
	     b1.y,
					 4,6)
			circ(b2.x,
	     b2.y,
					 4,6)
  end
 
  draw_ball(ball)
 end
end

function was_ball_sunk(ball)
 if ball.x < 15 and ball.y < 21 then
 	return true
 elseif ball.x < 15 and ball.y > 106 then
  return true
 elseif ball.x > 113 and ball.y < 21 then
  return true
 elseif ball.x > 113 and ball.y > 106 then
 	return true
 else 
 	return false
 end
end

function draw_ball(ball)
	circ(ball.x,
	     ball.y,
					 4,0)
	     
	circfill(ball.x,
										ball.y,
										3, 
										colours[ball.colourname])
	     
	gx=ball.x - 80
	gx=gx/42.0
	
	gy=ball.y - 80
	gy=gy/42.0     
	     
	circfill(ball.x-gx,
										ball.y-gy,
										1,
										highlights[ball.colourname])
end
-->8
--pool effects

particles={}
shake_amount=0.0;

function create_particle(x,y,
																									speed,
                         colour)
	spawn_angle=rnd()
	random_speed=(rnd()+0.2) * speed
	
	add(particles,{
		x=x,
		y=y,
		vx=random_speed * cos(spawn_angle),
		vy=random_speed * sin(spawn_angle),
	 colour=colour,
	 ax=0.00,
	 ay=0.05,
	 creation_time=time()+rnd(0.1)
	})                      
end

function create_particle_bloom(x,y,colour)
 for i=1,30 do
 	create_particle(x,y,1,colour)
 end
end

function draw_particles()
	for particle in all(particles) do
	 line(particle.x,
	      particle.y,
	      particle.x+particle.vx*2,
	      particle.y+particle.vy*2,
	      get_particle_colour(particle))
	      
	 if time() - particle.creation_time > 0.2 then
			del(particles, particle)	
		end
	end
	
	draw_screen_shake()
end

function get_particle_colour(particle)
	particle_age = time() - particle.creation_time
	
	if particle.colour==colour_names.orange then
		return get_orange_shade(particle_age)
	elseif particle.colour==colour_names.blue then
		return get_blue_shade(particle_age)
	elseif particle.colour==colour_names.black then
		return get_black_shade(particle_age)
	else
	 return get_white_shade(particle_age)
	end
end

function get_orange_shade(age)
	if age < 0.06 then
		return 10
	elseif age < 0.12 then
		return 9
	else
		return 8
	end
end

function get_blue_shade(age)
 if age < 0.06 then
		return 7
	elseif age < 0.12 then
		return 12
	else
		return 1
	end
end

function get_black_shade(age)
 if age < 0.06 then
		return 6
	elseif age < 0.12 then
		return 5
	else
		return 0
	end
end

function get_white_shade(age)
 if age < 0.06 then
		return 7
	elseif age < 0.12 then
		return 6
	else
		return 6
	end
end

function update_particles()
	for particle in all(particles) do
		
		particle.vx += particle.ax
 	particle.vy += particle.ay

  particle.vx *= 0.95
 	particle.vy *= 0.95

 	particle.x += particle.vx
 	particle.y += particle.vy
	end
end

function screen_shake(intensity)
	shake_amount=intensity;
end

function draw_screen_shake()
	if shake_amount < 0.05 then 
	 camera(0,0)
		return
	end
	
	local offset_x=shake_amount-rnd(shake_amount*2);
	local offset_y=shake_amount-rnd(shake_amount*2);
	camera(offset_x,offset_y)
	shake_amount*=0.7;
end
__gfx__
000000001166000000000611228000000000082233bbb0000000bb3322dd00000000dd22dd770000000077dd44f0000000000f44000000000000000004444440
00000000166055555555506128056655555550823bb0055555550bb32dd0566565550dd2d77055555555077d4f055555555550f4000444444444444404444440
0070070066055555555555068056555555550508bb055665555550bbdd055555555550dd7705577555555077f05577555555550f004444444444444404444440
0007700060556555555555508055555555555550b0556555555550bbdd0500000555550d7055755555555507f05755555555550f044444000000444404444440
0007700005565550000555500550000000055550b05655000005550bdd50bbbbb00000dd7057550000055507f05500555550050f044440000505044404444440
007007000555550aaaa00550050dddddddd00008b05550999990550bdd5bbbbbbbbbb5dd7055506666605550f000cc05500cc00f044400005050504404444440
00000000055550aaaaaaa00680dddddddddddd08b05509999999050bdd5b000b000b05dd7055066666660550f0ccccc00ccccc0f044000050555550404444440
000000006055055aa5555a5680dd07ddd07ddd08b05509799799050bdd5006000600b5dd0550666666660507f0cc77cccc77cc0f044000505055550004444440
33333333605507555567555680dd00ddd00ddd08b0550909909050bbdd5b000b000bb5dd0550607660760507f0cc07cccc07cc0f044005055555550300000000
333333336505055aa5555a5680dd00ddd00ddd08bb050999999905bbdd5bbbbbbbbbb5dd0550607660760507f0cccccccccccc0f044050505555550344444444
3333333365a0aaaaaaaaaa5680dddddddddddd08bb055099999995bbdd5bbbbbbbbbb5dd7050666666660550f0cccccccccccc0f044005555555550344444444
33333333665aaaaaaa0aa56680dd5555555ddd08bbb00999999995bbdd5bbb000bbbb5dd7050666666660550f0ccc0cccc0ccc0f044050555555550344444444
33333333665aaa0000aaa56680d5d00000d5dd08bbb59990009995bbdd5bbb000bbbb5dd0550666006660507ff0ccc0000ccc0ff044405555555503344444444
333333336665aaaaaaaa566688055ddddd5d5088bbbb599999995bbbddd5bbbbbbbb5ddd0505666666665077ff05cccccccc50ff044440555555033344444444
3333333316665aaaaaa5666128805555555508823bbbb5999995bbb32ddd5bbbbbb5ddd2d07756666665777d4ff0555555550ff4044444000000333344444444
333333331166655555566611228800000000882233bbbb55555bbb3322ddd555555ddd22dd777555555777dd44ff00000000ff44044444403333333300000000
00000000000000000444444033333333333333330444444033555555555555555555555555555555555555555555553333555555555555555555555555555533
444444444444400004444400000033333333000000444440351111c1cccccc6c666666a6aaaaaa9a9999998988888853351111c1cccccc6c666666a6aaaaaa53
4444444444444400044440555555033333305555550444405111111cccccccc66666666aaaaaaaa999999998888888855111111cccccccc66666666aaaaaaaa5
444400000044444004440555555550333305555555504440511111c1cccccc6c666666a6aaaaaa9a9999998988888885511111c1cccccc6c666666a6aaaaaaa5
4440505000044440044050555555550330555555550504405111111cccccccc66666666aaaaaaaa999999998888888855111111cccccccc66666666aaaaaaaa5
440505050000444004400555555555033055555555500440511111c1cccccc6c666666a6aaaaaa9a9999998988888885511111c1cccccc6c666666a6aaaaaaa5
4055555050000440044050505555550330555555050504403511111cccccccc66666666aaaaaaaa999999998888888533511111cccccccc66666666aaaaaaa53
00555505050004400440050555555503305555555050044033555555555555555555555555555555555555555555553333555555555555555555555555555533
30555555505004400440005050555500005555050500044033555555555555555555555555555555555555333355555555555555555555333355555555555533
305555550505044004400005055555044055555050000440351111c1cccccc6c666666a6aaaaaa9a99999953351111c1cccccc6c666666533511111c1ccccc53
3055555555500440044400005050504444050505000044405111111cccccccc66666666aaaaaaaa9999999955111111cccccccc66666666551111111ccccccc5
305555555505044004444000050504444440505000044440511111c1cccccc6c666666a6aaaaaa9a99999995511111c1cccccc6c666666655111111c1cccccc5
3305555555504440044444000000444444440000004444405111111cccccccc66666666aaaaaaaa9999999955111111cccccccc66666666551111111ccccccc5
333055555504444000444444444444444444444444444400511111c1cccccc6c666666a6aaaaaa9a99999995511111c1cccccc6c666666655111111c1cccccc5
3333000000444440000444444444444444444444444440003511111cccccccc66666666aaaaaaaa9999999533511111cccccccc66666665335111111cccccc53
33333333044444400000000000000000000000000000000033555555555555555555555555555555555555333355555555555555555555333355555555555533
b000b000066600060000777006666660000880000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000b00600066608887000765755756000880000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b000b0000000008887000765555556088888800080800000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000b00066600068887000765577556008888000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b000b000600066600000777006666660000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000cc77000cc7700000cc7000000000000000000cc700000000aaaaaa7700000000000000000000000000000a77000000000000000000000000000000000000
000c111170c11117000c11170000000000000000c1117000000a999999997700000000000000000000000000a999700000000000000000000000000000000000
00c111111c111111700c111c0000000000000000c111c000000a999999999970000000000000000000000000a999700000000000000000000000000000000000
00c1111111111111c00c111c0000000000000000c111c000000a9999aaa999a0000000000000000000000000a999a00000000000000000000000000000000000
00c1111c111c1111c000ccc000000000000000000ccc0000000a999a000a99a0000000000000000000000000a999a00000000000000000000000000000000000
00c111c0c1c0c111c0000000000c770cc770000000000000000a999a000a99a0000000000000000000000000a999a00000000000000000000000000000000000
00c111c00c00c111c000ccc000c111c1111700000cc70000000a9999aaa999a000aaa777000000aaa7770000a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111111111c000c1117000000a9999999999a00a99999970000a9999997000a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c1111111111c00c111c000000a999999999a00a99999999700a99999999a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c1111cc1111c00c111c000000a9999aaaaa000a999aa999a00a999aa999a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a99a00a99a00a99a00a99a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a99a00a99a00a99a00a99a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a99a00a99a00a99a00a99a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a99a00a99a00a99a00a99a00a999a00000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a999aa999a00a999aa999a00a9999a0000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a00000000a99999999a00a99999999a00a99999a000000000000000000000000000000000
00c111c00000c111c00c111c00c111c00c111c00c111c000000a999a000000000a999999a0000a999999a0000a9999a000000000000000000000000000000000
000ccc0000000ccc0000ccc0000ccc0000ccc0000ccc00000000aaa00000000000aaaaaa000000aaaaaa000000aaaa0000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e1f1f1f1f1f1f1f1f1f1f1f1f202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1e101010101010101010101010303100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f10101010101010101010101010100f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223101010101010101010101010242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32331f1f1f1f1f1f1f1f1f1f1f1f343500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010c000011000110001000010000100000f0000f0000e0000e0000e0000d0000d0000d0000c0001360013600136001360012600116000f6000e6000d6000b6000960007600056000160000600000000000000000
011000000905509055090550c0550c0550c0550905509055090550e0550e0550e05509055090550905510055100551005510055100551005510055100550e0550900509005090000c0000c0000c0000900009000
01100000266250e6250e625266250e6250e625266250e6250e625266250e6250e625266250e6250e625266250e6250e6252163500005216350000521635216350000000000000000000000000000000000000000
011000001c5521c5521c5521555215552155521c5521d5511d5521c5521c5521c5521a5521a5521a5521855218552175521855218552185521755217552175520050200500005000000000000000000000000000
011000001c5521c5521c5521555215552155521c5521d5511d5521c5521c5521c5521a5521a5521a5521c5521c5521c5521d5521d5521d5521f5521f5521f5520000200000000000000000000000000000000000
0110000013155131551315513155131551315511155111551115511155111551115510155101551015510155101551015511155101550e1550e1550e155000000000000000000000000000000000000000000000
01100000266250e6250e625266250e6250e625326230e6250e625266250e6250e625326250e6250e625266250e6251a6252163521635216350000021635216350000000000000000000000000000000000000000
011000001f7521f7521f7521f7521f7551f7551d7521d7521d7521d7551d7551d7551c7521c7521c7551c7521c7521c7521d7521c7521a7551a7551a755002000020000700006000050000000000000000000000
010e0000154451544515440154401544000000174351843018430000001c4401c44015440154401544000000154451544515440154401544000000174351843018430000001c4401c44015441154401544000000
010e0000154451544515440154401544000000174351843018430000001c4401c44015440154401544000000184401a4411a4401a440184401844018440000001744017440174400000013440134401344000000
010e00000945509425094550942509455000050000500005000050000009455094250945509425094550000500000000000945509425094550942509455000000945009450094500000007450074500745000000
010e0000074550742507455074250745500000000000000000000000000745507425074550742507455000000000000000074550742507455074250745500000074500745007450000000c4500c4500c45000000
010e00000e4550e4550e4550e4550e4550e4550e4550e4550c4550c4550c4550c4550c4550c4550c4550c4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b4550b455
010e00001052010520105201052010520105201052010520105201052010520105201052010520105201052010520105201052010520105201052010520105201052010520105201052010520105201052010520
010e00001152011520115201152011520115201152011520115201152011520115201152011520115201152011520115201152011520115201152011520115201152011520115201152011520115201152011520
010e00000e1530000000000000000e1530010000100001000e1530010000100001000e1530010000100001000e1530010000100001000e1530010000100001000e1530010000100001000e153000000000000000
010e00001065510655101530000010655106551015300000106551065510153000001065510655101530000010655106551065510655106551065510655106551065510655106551065510655106551065510655
011000002175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755
0110000019555195551955519555195551955519555195551a5551a5551a5551a5551a5551a5551a5551a5551c5551c5551c5551c5551c5551c5551c5551c5551a5551a5551a5551a5551a5551a5551a5551a555
011000001c5551c5551c5551c5551c5551c5551c5551c5551a5551a5551a5551a5551a5551a5551a5551a55519555195551955519555195551955519555195551955519555195551955519555195551955519555
011000002175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217552175521755217551e7551e7551e7551e7551e7551e7551e7551e755
011000001e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551e7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a7551a755
001000001755517555175551755517555175551755517555175551755517555175551755517555175551755515555155551555515555155551555515555155551555515555155551555515555155551555515555
0010000019750197501975019750197501975019750197501a7501a7501a7501a7501a7501a7501a7501a7501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c050
011000001455014550145501455014550145501455014550155501555015550155501555015550155501555017050170501705017050170501705017050170501705517055170551705517055170551705517055
001000002175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750217502175021750
0010000019550195501955019550195501955019550195501a5501a5501a5501a5501a5501a5501a5501a5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c5501c550
011000001c6351c6351c6001c6001c6001c6001c6001c6001c6351c6350000500005000000000000000000001c6351c6351c6001c6001c6001c6001c600000001c6351c6351c6351c6351c635000000000000000
010700001770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000180521805218052180021b0521b0521b052180021e0521e052180021f0521f0521f052180021e0521e0521e052180021d0521d0521d0521d052180001800018000180001800000000000000000000000
010a0000180521805218052180021b0521b0521b052180021e0521e052180021f0521f0521f05218002220522205222052180021f0521f0521f0521f052180000000000000000000000000000000000000000000
010a00001f0521f0521f052180001e0521e0521e052180001d0521d052180001b0521b0521b052180021605216052160521605216052160521605216052160520c00000000000000000000000000000000000000
010a00000e6550000000000000001a7632400000000000001a763000000000010655000000000000000106550000000000000001a763000000000000000000000000000000000000000000000000000000000000
010a00000c5200c5200c5200c5201a7630c5200c5200c5201a7630c5200c5200c5200c5200c5200c5200c5200c5200c5200c5201a7630c5200c5200c5200c5200000000000000000000000000000000000000000
010a0000095200952009520095201a7630952009520095201a763095200952009520095200952009520095200952009520095201a763095200952009520095200000000000000000000000000000000000000000
011200000444504445044450444504445004050040500400044000040004445044450444504445044450040004445044450444504445044450040009442094420944209442094320943107441074420744207432
0112000010345103451034510345103450c3050c3050c305103050c30510345103451034510345103450c30510345103451034510345103450c30015340153401534015340153500943113341133401334013340
0112000004445044450444504445044450040500405004000440000400044450444504445044450444500400044450444504445044450444504445094410944009440094400445500400094400b4510b4410b440
0112000010345103451034510345103450c3050c3050c300103000c30010345103451034510345103450c30010345103451034510345103450444515341153401534015340103550c00015340173511734117340
011200000e053000000000000000246500000000000000000e053000000000000000246500000000000000000e053000000000000000246500000000000000000e05300000000000000024650000002465524655
0112000010345103451034510345103450c3051c3401c3401c340000001a3401a3401a34000000183401834017341173401734017340000000000015340153401534015340000000000013340133401334000000
0112000010345103451034510345103450c3051c3451c3451c3451c3451c341173451734517345173551735518345183451834518345183451834517351173551735517355173551735515355153451534515355
0112000010345103451034510345103450c3051c3401c3401c340000001a3401a3401a3400000018340183401734117340173401734000000000001534015340153401534000000000001a3401a3401a34000000
0112000010345103451034510345103450c3051c3451c3451c3451c3451c34117345173451734517355173551834518345183451834518345183451735117355173551735517355173551a3551a3451a3451a355
010c00000d5510d5510d5510d5511455114551145511455116551165510d5510d5511855118551185511855116551165511555115551145511455114551145511255112551125511255111551115511155111551
010c00001255112551125511255119551195511955119551175511755117551175511455114551145511455116551165511655116551145511455114551145511655116551165511655118551185511855118551
010c00001155111551115511155118551185511855118551195511955119551195511b5511b5511b5511b5511d5511d5511c5511c5511b5511b5511b5511b551195511955119551195511a5511a5511a5511a551
010c00001b5511b5511b5511b5511955119551195511955118551185511855118551165511655116551165511455114551145511455112551125511255112551115511155111551115510f5510f5510f5510f551
010c0000046530d100000000000010153000000d1000d100046530d100046530d100101530d100000000000004653000000000000000101530000000000000000465300000046530000004653000000465300000
010c00002571025710257102571025710257102571025710257102571025710257102571025710257102571025710257102571025710257102571025710257102571025710257102571025710257102571025710
010c00002a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a7202a720
010c00002972029720297202972029720297202972029720297202972029720297202972029720297202972029720297202972029720297202972029720297202972029720297202972029720297202972029720
010f0000061500b1500e15006155061500b1500e15006155061500b1500e15006155061500b1500e15006155061500b1501015006155061500b1501015006155061500b1501015006155061500b1501015006155
010f0000071500b1501015007155071500b1501015007155071500b1501015007155071500b1501015007155071500b1501215007155071500b1501215007155071500b1501215007155071500b1501215007155
010f0000091500e1501215009155091500e1501215009155091500e1501215009155091500e1501215009155091500e1501315009155091500e1501315009155091500e1501315009155091500e1501315009155
010f0000071500b1501015007155071500b1501015007155071500b1501015007155071500b1501015007155061500b1500f15006155061500b1500f15006155061500b1500f15006155061500b1500f15006155
010f00001065510655106550000010655106551065500000266430e6000000000000266202662000000000001065510655106550000010655106551065500000266430e60000000000000e6530e6530e6530e653
010f00001065510655106550000010655106551065500000266430e6000000000000266202662000000000001065510655106550000010655106551065500000266430e6000e653000000e6530e6530e6530e653
010f00000e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e7200e72010730107301073010730107301073010730107301073010730107301073010730107301073010730
010f00001272010720107201072010720107201072010720107201072010720107201072010720107201072012730127301273012730127301273012730127301273012730127301273012730127301273012730
000f00001273012730127301273012730127301273012730127301273012730127301273012730127301273013740137401374013740137401374013740137401374013740137401374013740137401374013740
010f0000107401074010740107401074010740107401074010740107401074010740107401074010740107400f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f7500f750
010100000575005750057500575005750047500375003750037500575007750097500975009750097500a7500c7500d7500f750117501375015750197501c7501f7502075024750287502c75031750367503d750
00010000273302733027330273302733027330263302633026330263302533024330223301f3301b33017330133300f3300d3300a330093300833007330073300733006330063300633005330043300233000330
__music__
00 00 01 43 44
01 00 01 02 44
00 00 01 02 44
00 00 01 02 03
00 00 01 02 04
00 00 01 02 03
00 00 01 02 05
00 00 06 01 44
00 00 06 01 44
00 00 06 01 03
00 00 06 01 04
00 00 06 01 03
02 00 01 06 07
01 08 42 43 44
00 09 42 43 44
00 08 0d 0f 44
00 09 0e 0f 44
00 0a 0f 0d 44
00 0b 0f 0e 44
00 0a 0f 0d 44
02 0c 0e 10 44
01 11 12 1b 44
00 14 13 1b 44
00 15 16 43 44
00 17 18 43 44
00 11 12 1b 44
00 14 13 1b 44
00 15 16 1b 44
02 19 1a 1b 44
01 1c 1d 20 44
00 1c 1e 20 44
00 1c 1d 20 44
00 1c 1f 43 44
00 1c 1d 21 44
00 1c 1e 22 44
00 1c 1d 21 44
02 1c 1f 22 44
01 23 24 00 00
00 25 26 00 00
00 23 24 27 44
00 25 26 27 44
00 28 27 23 44
00 2a 27 25 44
00 29 27 23 44
02 2b 27 25 44
01 2c 31 00 00
00 2d 32 00 00
00 2e 33 00 00
00 2f 31 00 00
00 2c 31 30 00
00 2d 32 30 00
00 2e 33 30 00
02 2f 31 30 00
01 34 3a 00 00
00 35 3b 00 00
00 36 3c 00 00
00 37 3d 00 00
00 34 38 3a 00
00 35 39 3b 00
00 36 38 3c 00
02 37 39 3d 00
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
