pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--korvus

dbg=''

-- position players
original_x=60
original_y=40
x=original_x
y=original_y

stone_color=5
dirt_color=4

game_states={
	start=1,
	gameover=2,
	play=3,
	campaign=4,
}
--default countdown
dfcd=18
victory_time=dfcd
victory_best=victory_time
--score set to 0 by default to all players
score=0
game_state=game_states.start
-- 8=vie 7->1=crevant 0=mort
health=8
health_p2=health
direction=1
direction_p2=-1

--golden salad
direction_gs=0
gs_direction_tick=0
speed_gs=0.5

weskargool=8
heskargool=8
sprchange=0
sprchange_p2=0
salad_t1={1,19}
salad_t2={2,20}
salad_t3={3,21}
salad_t4={4,50}
salad_t5={5,49}
salad_t6={6,48} -- randomise one
salad_t7={7,16}
salad_t8={8,51}
salad_t9={9,32}
nb_player=-1
saladsprite= {
	salad_t1,
	salad_t2,
	salad_t3,
	salad_t4,
	salad_t5,
	salad_t6,
	salad_t7,
	salad_t8,
	salad_t9,
}
ratio_salads_default={
	salads={
			t1=5,
			t2=1,
			t3=2,
			t4=0,
			t5=0,
			t6=1,
			t7=1,
			t8=0,
			t9=0,
	}
}
list_salads=ratio_salads_default
salads={}

bave={}
bave_p2={}

dying_sprites={17,18,33,34,35,36,37}
dying_sprites_p2={44,45,46,60,61,36,37}

--campaign
--step campaign
df_step=1
step_cp=df_step
campaign={
	{
		tp='explanation',
		txt={
			{'welcome to eskargool!',15,22,7},
			{'all you need to play are',15,34,7},
			{'the directional controls.',15,40,7}
		},
		pics={
			{1,60,75,1,1,true,false},
			{30,60,61,1,1,true,false},
			{29,45,75,1,1,true,true},
			{30,60,90,1,1,true,true},
			{29,75,76,1,1,false,false}
		}
	},
	{
		tp='explanation',
		txt={
			{'your aim is to eat',10,13,7},
			{'green and healthy salads!',10,19,7},
			{'just be careful, there',10,60,7},
			{'is a countdown!',10,66,7},
			{'countdown',14,104,7},
			{'2/10',13,83,10},
			{'18 s.',13,92,7},
			{'salads eat',37,83,7}
		},
		pics={
			{19,20,30,1,1,false,false},
			{19,30,32,1,1,true,false},
			{19,35,35,1,1,false,false},
			{19,42,28,1,1,true,false},
			{19,56,31,1,1,false,false},
			{19,76,33,1,1,true,false},
			{19,62,29,1,1,false,false},
			{19,89,32,1,1,true,false},
			{19,106,30,1,1,false,false},
			{19,60,40,1,1,true,false},
			{19,60,40,1,1,true,false},
			{29,27,82,1,1,true,false},
			{30,14,95,1,1,true,false}
		}
	},
 {
		tp='game',
		ttl='1/12',
		goal=5,
		timeout=30,
		bg={5,4},
		musik=11,
		salads={
			t1=5,
			t2=0,
			t3=0,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'congratulations,',15,15,7},
			{'that was easy!',15,21,7},
			{'but did you notice how',15,27,7},
			{'slow your snail is?',15,33,7},
			{'that\'s why there are blue',15,70,12},
			{'salads!',15,76,12},
			{'blue salads increase your',15,87,7},
			{'speed but not points.',15,93,7},
			{'let\'s try!',80,103,7},
		},
		pics={
			{20,20,45,1,1,false,false},
			{20,30,48,1,1,true,false},
			{20,35,50,1,1,false,false},
			{20,42,43,1,1,true,false},
			{20,56,46,1,1,false,false},
			{20,76,48,1,1,true,false},
			{20,62,44,1,1,false,false},
			{20,89,47,1,1,true,false},
			{20,99,45,1,1,false,false},
			{20,60,55,1,1,true,false},
			{20,60,55,1,1,true,false},
		}
	},
 {
		tp='game',
		goal=10,
		ttl='2/12',
		bg={4,5},
		timeout=20,
		musik=10,
		salads={
			t1=5,
			t2=5,
			t3=0,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'well done!',10,10,7},
			{'let\'s start something more',10,16,7},
			{'difficult now!',10,22,7},
			{'orange salads with eyes!',10,64,9},
			{'this salad kills you...',10,80,7},
			{'and slows your snail down...',10,86,7},
			{'but...',10,92,7},
			{'allows you to gain',10,98,7},
			{'two points!',10,104,7}
		},
		pics={
			{21,20,35,1,1,false,false},
			{21,30,38,1,1,true,false},
			{21,35,40,1,1,false,false},
			{21,42,33,1,1,true,false},
			{21,56,36,1,1,false,false},
			{21,76,38,1,1,true,false},
			{21,62,34,1,1,false,false},
			{21,89,37,1,1,true,false},
			{21,99,35,1,1,false,false},
			{21,60,45,1,1,true,false},
			{21,60,45,1,1,true,false},
		}
	},
	{
		tp='game',
		ttl='3/12',
		goal=6,
		timeout=5,
		musik=12,
		bg={2,4},
		fastness=0.7,
		salads={
			t1=0,
			t2=0,
			t3=10,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'great!',10,10,7},
			{'maybe you noticed you have',10,16,7},
			{'some time before being',10,22,7},
			{'clinically dead?',10,28,7},
			{'the good news is',10,40,7},
			{'you can pick a blue',10,46,7},
			{'salad to heal!',10,52,7},
			{'+',42,71,7},
			{'+',42,91,7},
		},
		pics={
			{1,30,70,1,1},
			{21,48,70,1,1},
			{29,72,70,1,1},
			{18,90,70,1,1},
			{18,30,90,1,1},
			{20,48,90,1,1},
			{29,72,90,1,1},
			{2,90,90,1,1},
		}
	},
	{
		tp='game',
		ttl='4/12',
		bg={5,3},
		goal=20,
		timeout=20,
		musik=15,
		salads={
			t1=0,
			t2=8,
			t3=5,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'ok, you know the basics.',13,20,7},
			{'let\'s mix the three types',13,26,7},
			{'of salad on one board now!',13,32,7},
		},
		pics={
			{1,30,73,1,1},
			{21,50,73,1,1},
			{19,72,73,1,1},
			{20,92,73,1,1},
		}
	},
	{
		tp='game',
		ttl='5/12',
		goal=10,
		bg={4,3},
		timeout=20,
		musik=5,
		salads={
			t1=5,
			t2=1,
			t3=2,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'let\'s continue with',31,20,7},
			{'a new salad!',31,26,7},
			{'the orange salad!',31,42,10},
			{'this one gives you',31,90,7},
			{'some extra time!',31,96,7},
			{'+',42,67,10},
			{'+',95,67,10},
			{'+',100,67,10},
		},
		pics={
			{1,30,65,1,1},
			{50,50,65,1,1},
			{29,70,65,1,1},
			{14,85,65,1,1},
		}
	},
	{
		tp='game',
		ttl='6/12',
		goal=10,
		timeout=6,
		bg={3,1},
		musik=18,
		salads={
			t1=3,
			t2=2,
			t3=3,
			t4=3,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'each bonus has',31,15,7},
			{'its nemesis!',31,21,7},
			{'this red salad',31,35,7},
			{'removes time!',31,41,7},
			{'+',42,57,0},
			{'-',95,57,0},
			{'-',100,57,0},
			{'but there is',31,75,7},
			{'an extra power',31,81,7},
			{'with this salad...',31,87,7},
			{'it gives a lot',31,93,7},
			{'of speed!',31,99,7}
		},
		pics={
			{1,30,55,1,1},
			{49,50,55,1,1},
			{29,70,55,1,1},
			{14,85,55,1,1},
		}
	},
	{
		tp='game',
		ttl='7/12',
		goal=12,
		timeout=20,
		bg={13,5},
		musik=19,
		salads={
			t1=5,
			t2=0,
			t3=2,
			t4=0,
			t5=1,
			t6=0,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'you\'re getting the hang of this!',21,20,7},
			{'this time, no help!',21,26,7},
			{'try to guess what',21,84,7},
			{'the purple salad does!',21,90,7},
			{'?',25, 40,13},
			{'?',105,75,13},
			{'?',30,	67,13},
			{'?',42, 55,13},
			{'?',80, 60,13},
			{'?',49,36,13},
			{'?',42, 40,13},
			{'?',75, 53,13},
			{'?',34, 48,13},
			{'?',42, 60,13},
			{'?',95, 73,13},
			{'?',60, 62,13},
		},
		pics={
			{48,55,55,1,1},
		}
	},
	{
		tp='game',
		ttl='8/12',
		goal=5,
		timeout=13,
		bg={5,1},
		musik=20,
		salads={
			t1=5,
			t2=1,
			t3=2,
			t4=0,
			t5=0,
			t6=1,
			t7=0,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'adventure continues!',31,15,7},
			{'another strange',31,21,7},
			{'salad appears',31,27,7},
			{'in the garden...',31,33,7},
			{'+',42,57,0},
			{'?',95,57,0},
			{'it smells good',31,75,7},
			{'so that must',31,81,7},
			{'give some',31,87,7},
			{'points... but',31,93,7},
			{'why grey?',31,99,7}
		},
		pics={
			{1,30,54,1,1},
			{16,50,55,1,1},
			{29,70,55,1,1},
			{14,85,55,1,1},
		}
	},
	{
		tp='game',
		ttl='9/12',
		goal=10,
		bg={4,2},
		timeout=20,
		musik=21,
		salads={
			t1=0,
			t2=0,
			t3=2,
			t4=2,
			t5=2,
			t6=0,
			t7=2,
			t8=0,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'you\'ve almost reached',21,15,0},
			{'the mysterious golden',21,21,0},
			{'salad!',21,27,0},
			{'but before there is',21,35,0},
			{'a strange white salad...',21,41,0},
			{'+',32,57,0},
			{'+',95,57,0},
			{'it gives you some extra',21,75,0},
			{'points but also some',21,81,0},
			{'extra speed!',21,87,0},
			{'but it is possibly',21,95,0},
			{'dangerous!',21,101,0},
		},
		pics={
			{1,20,55,1,1},
			{51,40,55,1,1},
			{29,65,55,1,1},
			{47,100,55,1,1},
			{14,85,55,1,1},
		}
	},
	{
		tp='game',
		ttl='10/12',
		goal=10,
		timeout=16,
		bg={4,5},
		musik=22,
		salads={
			t1=3,
			t2=0,
			t3=0,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=3,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'before the last round',21,15,7},
			{'with the famous,',21,21,7},
			{'golden salad, let\'s do',21,27,7},
			{'a last training session',21,33,7},
			{'',21,41,0},
		},
		pics={
			{19,25,60,1,1},
			{20,35,65,1,1},
			{21,45,60,1,1},
			{50,55,65,1,1},
			{49,65,60,1,1},
			{48,75,65,1,1},
			{16,85,60,1,1},
			{51,95,65,1,1},
		}
	},
	{
		tp='game',
		ttl='11/12',
		bg={5,4},
		goal=10,
		timeout=18,
		musik=25,
		salads={
			t1=1,
			t2=1,
			t3=1,
			t4=1,
			t5=1,
			t6=1,
			t7=1,
			t8=1,
			t9=0,
		}
	},
	{
		tp='explanation',
		txt={
			{'you finally get it!',21,15,9},
			{'it smells delicious,',21,21,9},
			{'the golden salad is',21,27,9},
			{'there!',21,33,9},
			{'',21,41,0},
		},
		pics={
			{32,61,66,1,1},
			{15,50,50,1,1},
			{15,70,70,1,1},
			{15,80,75,1,1},
			{15,80,45,1,1},
			{15,40,80,1,1},
		}
	},
	{
		tp='game',
		ttl='12/12',
		goal=30,
		bg={1,2},
		timeout=20,
		musik=23,
		salads={
			t1=0,
			t2=0,
			t3=0,
			t4=0,
			t5=0,
			t6=0,
			t7=0,
			t8=0,
			t9=1,
		}
	},
	{
		tp='explanation',
		txt={
			{'you know all the',15,41,7},
			{'secrets! keep training',15,48,7},
			{'hard, a perfect',15,55,7},
			{'control of eskargool',15,62,7},
			{'is the work of a lifetime!',15,69,7},
		},
		pics={
			{64,26,10,10,4},
			{19,20,80,1,1},
			{20,30,80,1,1},
			{21,40,80,1,1},
			{50,50,80,1,1},
			{49,60,80,1,1},
			{48,70,80,1,1},
			{16,80,80,1,1},
			{51,90,80,1,1},
			{32,100,80,1,1},
		}
	},
	{
		tp='end'
	}
}


function get_rand_position()
	local alea_x=flr(rnd(128-weskargool))
	local alea_y=flr(rnd(112-heskargool))

	local init_pos_s1 = collision_check(
		x,
		y,
		alea_x,
		alea_y
	)

	--check collision with second player
	if (
		nb_player==1 and
		init_pos_s1==false
	)
	then
			local init_pos_s2 = collision_check(
				x_p2,
				y_p2,
				alea_x,
				alea_y
			)
	else
		init_pos_s2=false
	end

	--if position dont touch any player, return it
	--boolcollis = collision_check(x_p2,y_p2,75,46)

	if (
		init_pos_s1==false and
		init_pos_s2==false
	)
	then
		return {alea_x, alea_y}
	else
		--return {0,0}
		return get_rand_position()
	end

end

function add_salad(stype)
	if game_state==game_states.play or
				game_state==game_states.campaign
 then
		pos_alea=get_rand_position()

		add(salads, {
		pos_alea[1],
		pos_alea[2],
		saladsprite[stype]
		})
	end

end

function generate_bave()
		color_bave=15
		if(health<8)then color_bave=8 end
		if direction<0 then
			start_bave=x+7
		else
			start_bave=x
		end
		if(flr(rnd(5))==1) then
			add(bave,{
				flr(start_bave+rnd(3)),
				flr(y+5+rnd(4)),
				color_bave
			})
		end
end

function generate_bave_p2()
		color_bave_p2=13
			if(health_p2<8)then color_bave_p2=8 end
		if direction_p2<0 then
			start_bave_p2=x_p2+7
		else
			start_bave_p2=x_p2
		end
		if(flr(rnd(5))==1) then
			add(bave_p2,{
				flr(start_bave_p2+rnd(3)),
				flr(y_p2+5+rnd(4)),
				color_bave_p2
			})
		end
end

function move(instance,xdiff,ydiff)
	-- if player 1
	if(instance=='p1') then
		x+=xdiff
		y+=ydiff
		sprchange-=1
		if x>128-weskargool	then
			x=128-weskargool
		end
		if x<0	then
			x=0
		end
		if y>112-heskargool	then
			y=112-heskargool
		end
		if y<0	then
			y=0
		end
		generate_bave()
	end
	--if player 2
	if(instance=='p2') then
		x_p2+=xdiff
		y_p2+=ydiff
		sprchange_p2-=1

		if x_p2>128-weskargool	then
			x_p2=128-weskargool
		end
		if x_p2<0	then
			x_p2=0
		end
		if y_p2>112-heskargool	then
			y_p2=112-heskargool
		end
		if y_p2<0	then
			y_p2=0
		end
		generate_bave_p2()
	end

end

dying_tick=15
dying_tick_p2=dying_tick
frequency=60
microtick=frequency

function launch_music()
	sfx(-1)
	music(-1)
	sfx(8)
end

function dying_framerate()
		--dying anim
		if health<8 then
			dying_tick-=1
			if dying_tick<0 then
				health-=1
				dying_tick=15
			end
			if health<0 then
				health=0
			end
			if health==0 then
				player_dead=1
				sfx(-1)
				countdown=0
				--if 2 players, even if death arrive, win music at the end
				if (nb_player==1) then
					sfx(4)
				else
					sfx(9)
				end
				return 'died'
			end
		end

		--dying anim player 2
		if health_p2<8 then
			dying_tick_p2-=1
			if dying_tick_p2<0 then
				health_p2-=1
				dying_tick_p2=15
			end
			if health_p2<0 then
				health_p2=0
			end
			if health_p2==0 then
				sfx(-1)
				sfx(4)
				player_dead=2
				return 'died'
			end
		end
end

function move_commands()

	local d=0
	local d2=0
	--move player1
	if switch_control==false then
		if (btn(0,0)) d=-speed
		if (btn(1,0)) d=speed
		if (btn(2,0)) move('p1',0,-speed)
		if (btn(3,0)) move('p1',0,speed)
	else
		if (btn(0,0)) d=speed
		if (btn(1,0)) d=-speed
		if (btn(2,0)) move('p1',0,speed)
		if (btn(3,0)) move('p1',0,-speed)
	end

	--move player2
	if(nb_player==1) then
		if(switch_control_p2==false)then
			if (btn(0,1)) d2=-speed_p2
			if (btn(1,1)) d2=speed_p2
			if (btn(2,1)) move('p2',0,-speed_p2)
			if (btn(3,1)) move('p2',0,speed_p2)
		else
			if (btn(0,1)) d2=speed_p2
			if (btn(1,1)) d2=-speed_p2
			if (btn(2,1)) move('p2',0,speed_p2)
			if (btn(3,1)) move('p2',0,-speed_p2)
		end
	end

	if d!=0 then
		direction = d
		move('p1',direction,0)
	end
	if d2!=0 then
		direction_p2 = d2
		move('p2',direction_p2,0)
	end

end

function c_down()
		-- countdown
		if (countdown>0) then
			hexacountdown-=1
			microtick-=1
			if microtick==0 then
				countdown-=1
				microtick=frequency
			end
		end

		if countdown==0 then
			if(nb_player==1) then
				sfx(-1)
				sfx(4)
			else
				--dead
				music(-1)
				sfx(-1)
				sfx(9)
			end
			countdown=-1
		end

		if countdown==-1 then
			return 'game_end'
		end

end

function _update60()

	if (
	 game_state==game_states.start
	) then
	 if btnp(5) then
			get_in_game()
	 end
  return
	end

	--all this events must happen only if game is on fire
	if (game_state==game_states.play) then

		trigger_die = c_down()

		--manage death :.(
		if(dying_framerate()=='died') then
			game_state=game_states.gameover
		end

		move_commands()

		if(trigger_die=='game_end') then
			game_state=game_states.gameover
		end

		--if eskargool is dead, you can reinit to 10
		init_anim_sprite()

		touch_salad()

	end

end

function event_eat_1()
	add_salad(1)
	sfx(1)
end

function event_eat_2()
	add_salad(2)
	sfx(6)
end

function event_eat_3()
	add_salad(3)
	sfx(7)
end

function event_eat_4()
	add_salad(4)
	sfx(16)
end

function event_eat_5()
	add_salad(5)
	sfx(17)
end

function event_eat_6()
	--random salad, dont need to remove anything
	sfx(17)
end

function event_eat_7()
	add_salad(7)
	sfx(7)
	if color_blind==true then
		color_blind=false
	else
		color_blind=true
	end
end

function event_eat_8()
	add_salad(8)
	sfx(17)
end

function event_eat_9()
	countdown+=2
	add_salad(9)
	add_salad(1)
	add_salad(1)
	add_salad(2)
	add_salad(3)
	sfx(24)
end

function eat_s_4(collisioned,salad)
	if collisioned==4 then
		del(salads,salad)
		event_eat_4()
		countdown+=2
	end
end

function clean_up_salads()
	for salad in pairs (salads) do
  salads[salad] = nil
	end
end

function clear_bave()
	for particle in pairs (bave) do
  bave[particle] = nil
	end
end

function collision_p1(salads, salad)
			if salad[3][1]==1 then
			 del(salads,salad)
			 event_eat_1()
			 sc_p1+=1
			end
			--blue salad speed up and heal
			if salad[3][1]==2 then
			 del(salads,salad)
			 event_eat_2()
			 health=8
			 speed+=0.1
			end
			-- salad killing you
			if salad[3][1]==3 then
				del(salads,salad)
				event_eat_3()
			 health-=1
				sc_p1+=2
			 speed-=0.1
			end
			-- salad gaining time
			eat_s_4(salad[3][1],salad)

			-- salad rmeove time
			if salad[3][1]==5 then
				event_eat_5()
				del(salads,salad)
				speed+=0.3
				countdown-=2
			end

			-- salad randoming
			if salad[3][1]==6 then
				clean_up_salads()
				draw_salads()
				event_eat_6()
				set_salads(list_salads)
			end

			if salad[3][1]==7 then
				del(salads,salad)
				event_eat_7()
				sc_p1+=1
			end

			if salad[3][1]==8 then
				del(salads,salad)
				event_eat_8()
				sc_p1+=1
				speed+=0.1
				if(switch_control==false) then
					switch_control=true
				else
					switch_control=false
				end
			end

			if salad[3][1]==9 then
				del(salads,salad)
				event_eat_9()
				health_p2=8
				sc_p1+=1
				speed+=0.1
			end

			if sc_p1>=goal then
				sfx(-1)
				sfx(4)
				manage_victory()
			end
end

function collision_p2(salads, salad)
			if salad[3][1]==1 then
			 del(salads,salad)
			 event_eat_1()
			 sc_p2+=1
			end
			--blue salad speed up and heal
			if salad[3][1]==2 then
			 del(salads,salad)
			 event_eat_2()
			 health_p2=8
			 speed_p2+=0.1
			end
			-- salad killing you
			if salad[3][1]==3 then
			 del(salads,salad)
			 event_eat_3()
			 health_p2-=1
				sc_p2+=2
			 speed_p2-=0.1
			end

			eat_s_4(salad[3][1],salad)

			-- salad randoming
			if salad[3][1]==5 then
				event_eat_5()
				del(salads,salad)
				speed_p2+=0.3
				countdown-=2
			end

			-- salad randoming
			if salad[3][1]==6 then
				clean_up_salads()
				draw_salads()
				set_salads(list_salads)
				event_eat_6()
			end

			if salad[3][1]==7 then
				del(salads,salad)
				event_eat_7()
				sc_p2+=1
			end

			if salad[3][1]==8 then
				del(salads,salad)
				event_eat_8()
				sc_p2+=1
				speed+=0.1
				if(switch_control_p2==false) then
					switch_control_p2=true
				else
					switch_control_p2=false
				end
			end

			if salad[3][1]==9 then
				del(salads,salad)
				event_eat_9()
				health_p2=8
				sc_p2+=1
				speed+=0.1
			end

			if sc_p2>=goal then
				sfx(-1)
				sfx(4)
			 game_state=game_states.win
			end
end

function manage_victory()
	--classical mod
	if game_state==game_states.play then
		--stock time
		victory_time=dfcd-countdown
		if (victory_best>victory_time) then
			victory_best=victory_time
		end
	 game_state=game_states.win
	end
	--campaign mod
	if game_state==game_states.campaign then
			step_cp+=1
			--step_cp+=1
	end
end

function touch_salad()
	for salad in all(salads) do

	 --collision player 1
	 local collision =	collision_check(
		 x,
		y,
		salad[1],
		salad[2]
	 )
	 if collision then
		collision_p1(salads, salad)
	 end

		--collision player 2
		if(nb_player==1) then
		local collision_bool =	collision_check(
			x_p2,
			y_p2,
			salad[1],
			salad[2]
		 )

		 if collision_bool then
				collision_p2(salads, salad)
		 end
	 end

	end
end

function draw_salads()
	local loop_tmp=0
	local	sprite_number=16
	for salad in all(salads) do
		loop_tmp+=1
		if color_blind==false then
			sprite_number=salad[3][2]
		end
		--golden salad moving

		if salad[3][1]==9 then

			gs_direction_tick+=1
			if(gs_direction_tick>80) then
				direction_gs=flr(rnd(8))
				gs_direction_tick=0
			end

			if (direction_gs==0) then
				--boost countdown
				gs_direction_tick+=2
			elseif direction_gs==1 then
				salad[1]+=speed_gs
			elseif direction_gs==2 then
				salad[1]-=speed_gs
			elseif direction_gs==3 then
				salad[2]+=speed_gs
			elseif direction_gs==4 then
				salad[2]-=speed_gs
			elseif direction_gs==5 then
				salad[1]+=speed_gs
				salad[2]+=speed_gs
			elseif direction_gs==6 then
				salad[1]-=speed_gs
				salad[2]-=speed_gs
			elseif direction_gs==7 then
				salad[1]+=speed_gs
				salad[2]-=speed_gs
			elseif direction_gs==8 then
				salad[1]-=speed_gs
				salad[2]+=speed_gs
			end

			if salad[1]<0 then salad[1]=120 end
			if salad[1]>120 then salad[1]=0 end
			if salad[2]>105 then salad[2]=0 end
			if salad[2]<0 then salad[2]=105 end

		end

		spr(sprite_number, salad[1], salad[2])
	end
end

function set_campaign()
	music(0)
	clean_up_salads()
	color_blind=false
	switch_control=false
	switch_control_p2=false
	player_dead=0
end

function _init()

	music(0)

	clear_bave()

	color_blind=false
	switch_control=false
	switch_control_p2=false
	player_dead=0
	score=0
	goal=10
	g_speed=0.2
	mssg_win='congratulation!'

	--var menu end
	menu_nxt='play'
	menu_end_arrow_pos=97

	--specific to player1
	x=60
 y=50
 speed=g_speed
 sc_p1=score
	-- if two players, first player is not at center
	if(nb_player==1) then
		winner=0
		x=40
	 y=50
		x_p2=80
		y_p2=50
		sc_p2=score
		speed_p2=g_speed
	end

	--add salad on board
	add_decor()

	clean_up_salads()
	list_salads=ratio_salads_default

	health=8
	health_p2=health
	countdown=dfcd
	hexacountdown=countdown*60
	hexacdorigin=countdown*60
end

function set_salads(obj)
	for i=1,obj.salads.t1 do
		add_salad(1)
	end
	for i=1,obj.salads.t2 do
		add_salad(2)
	end
	for i=1,obj.salads.t3 do
		add_salad(3)
	end
	for i=1,obj.salads.t4 do
		add_salad(4)
	end
	for i=1,obj.salads.t5 do
		add_salad(5)
	end
	for i=1,obj.salads.t6 do
		add_salad(6)
	end
	for i=1,obj.salads.t7 do
		add_salad(7)
	end
	for i=1,obj.salads.t8 do
		add_salad(8)
	end
	for i=1,obj.salads.t9 do
		add_salad(9)
	end
end

function add_decor()
	stones={}
	grass={}
	for i=1,2000 do
		add(stones,{rnd(130),rnd(110)})
	end
	for i=1,20 do
		add(grass,{flr(rnd(2))+1,flr(rnd(2))+1})
	end
end

function collision_check(x1,y1,x2,y2)
	local size=8
	if(x1+size<x2) return false
	if(x1>x2+size) return false
	if(y1+size<y2) return false
	if(y1>y2+size) return false
	return true
end

function draw_bg_board(fg,bg)
	rectfill(0,0,130,110,bg)
	for stone in all(stones) do
		pset(
			stone[1],
			stone[2],
			fg
		)
	end

	local sprite_grass={52,53}
	local symetry={true,false}

	palt(14,true)
	palt(0,false)

	local iter=0
	for herb in all(grass) do
		spr(
			sprite_grass[herb[1]],
			iter*8,
			104,
			1,
			1,
			symetry[herb[2]],
			false
		)
		iter+=1
	end
	palt(14,false)
	palt(0,true)
end

function draw_eskargool(sprindex)
	--if player 1 is sick, else alternate sprite
	if health<8 then
		sprindex=dying_sprites[8-health]
	elseif sprchange<5 then
		sprindex=2
	end
	return sprindex
end

function draw_bave()

	if count(bave)>100 then
		del(bave, bave[flr(rnd(30))])
	end
	for particle in all(bave) do
  pset(particle[1],particle[2],particle[3])
	end

	if nb_player==1 then
		if count(bave_p2)>100 then
			del(bave_p2, bave_p2[flr(rnd(30))])
		end
		for particle_p2 in all(bave_p2) do
	  pset(particle_p2[1],particle_p2[2],particle_p2[3])
		end
	end

end

function draw_game()

	local sprindex=1
	local sprindex_p2=4

	sprindex=draw_eskargool(sprindex)

	--animation death player 2
	if nb_player==1 then
		if health_p2<8 then
			sprindex_p2=dying_sprites_p2[8-health_p2]
		elseif sprchange_p2<5 then
			sprindex_p2=5
		end
	end

	--background
	draw_bg_board(
		stone_color,
		dirt_color
	)


	draw_bave()

	draw_salads()

	spr(sprindex,x,y,1,1,direction<0)
	print(sc_p1..'/10',2,115,10)

	--square life
	life=0 while life<10 do
		life+=1
		if life<=sc_p1 then
			rectfill(14+(life*4),114,16+(life*4),119,10)
		else
			rect(14+(life*4),114,16+(life*4),119,6)
		end
	end

	--if two players
	if(nb_player==1) then
		spr(sprindex_p2,x_p2,y_p2,1,1,direction_p2<0)
		print(sc_p2..'/10',110,115,2)

		--square life
		life_p2=0 while life_p2<10 do
			life_p2+=1
			if life_p2<=sc_p2 then
				rectfill(110-(life_p2*4),114,108-(life_p2*4),119,14)
			else
				rect(110-(life_p2*4),114,108-(life_p2*4),119,6)
			end
		end
	end

	draw_cd()
end

function display_txt(i)
	for tx in all(campaign[i].txt) do
		print(tx[1],tx[2],tx[3],tx[4])
	end
end

function display_pics(i)
	for pic in all(campaign[i].pics) do
		--spr(n,x,y,w,h,flipx,flipy)
		spr(pic[1],pic[2],pic[3],pic[4],pic[5],pic[6],pic[7])
	end
end

function specificities_cp(i)
	--display a false loading band
	if (i==1) then
		circfill(63,79,20,4)
	end

	if (i==2) then
		rectfill(10,30,118,50,4)
		rectfill(10,79,118,100,0)
		rectfill(35,92,100,96,11)
	end

	if(i==4) then
		rectfill(10,45,118,83,4)
	end

	if(i==6) then
		rectfill(10,35,118,60,4)
	end

	if(i==10) then
		rectfill(10,55,118,100,4)
	end

	if(i==20) then
		rectfill(10,10,118,50,6)
		rectfill(10,70,118,108,6)
	end

	if(i==22) then
		rectfill(10,50,118,90,4)
	end

	if(i==24) then
		circfill(64,73,36,11)
		circfill(64,70,25,10)
		circfill(64,70,20,15)
		circfill(64,70,10,7)
	end

	if(i==26) then
		rectfill(10,111,120,120,11)

		print3d('return to home with (x)',20,113,6,7)
		line(20,120,110,120,7)
	end

end

function draw_explanation(i)

	--set square
	rectfill(0,0,140,140,7)
	--shadow
	rectfill(10,10,125,125,6)
	--background
	rectfill(5,5,123,123,7)
	rectfill(6,6,123,123,11)
	rectfill(8,8,120,110,3)
	--border
	rect(5,5,123,123,0)

	spr(13,40,113)
	print3d('skip/next with (x)',47,113,6,7)
	line(47,120,117,120,7)

	specificities_cp(i)
	display_txt(i)
	display_pics(i)

	if	(rdy_nxt==true)then
		if	(btnp(5)) then
			step_cp+=1
		end
	else
		rdy_nxt=true
	end

end

function init_music(pist)
		music(-1)
		sfx(-1)
		sfx(pist)
end

function draw_fail_cp(i)

	print('retry',30,89,7)
	print('main menu',30,99,7)
	print('press (x) to launch',30,109,5)

	rect(10,80,120,120,7)

	if (btnp(3)) then
		sfx(0)
		if menu_nxt=='play' then
			menu_nxt='start'
			menu_end_arrow_pos=97
		else
			menu_nxt='play'
			menu_end_arrow_pos=87
		end
	end

	if (btnp(2)) then
		sfx(0)
		if menu_nxt=='play' then
			menu_nxt='start'
			menu_end_arrow_pos=97
		else
			menu_nxt='play'
			menu_end_arrow_pos=87
		end
	end

	if (btnp(5)) then
		clean_up_salads()
		color_blind=false
		switch_control=false
		switch_control_p2=false
		player_dead=0
		countdown=dfcd
		health=8
		if(menu_nxt=='play') then
			step_cp=i-1
			--draw_egxplanation(i-3)
			draw_game_cp(i)
		else
			sfx(-1)
			music(0)
			--disallow gameover
			--reinit all campaign
			step_cp=step_cp-1
			game_state=game_states.start
		end
	end

	spr(18,60,35)
	if player_dead==1 then
		print3d('indigestion!',44,50,6,7)
	elseif countdown==-1 then
		print3d('time out!',47,50,6,7)
	end

	spr(13,20,menu_end_arrow_pos)
end

--happen once
function init_stage(i)

	x=original_x
	y=original_y


	clear_bave()
	clean_up_salads()

	list_salads=campaign[i]
	set_salads(list_salads)
	countdown=campaign[i].timeout
	--speed custom
	if(campaign[i].fastness!=nil) then
		speed=campaign[i].fastness
	else
		speed=g_speed
	end
	hexacountdown=countdown*60
	hexacdorigin=countdown*60
	sfx(-1)
	init_music(campaign[i].musik)
	--reset score
	sc_p1=0

	color_blind=false
	switch_control=false
	switch_control_p2=false
	--stop loop
	rdy_nxt=false
end

function draw_game_cp(i)

	local sprindex=1
	sprindex=draw_eskargool(sprindex)
	deadback=c_down()
	if (player_dead==1 or deadback=='game_end' ) then
		--rdy_nxt=false
		draw_fail_cp(i)
	else

		--set only when playing
		menu_end_arrow_pos=87

		dying_framerate()
		draw_bg_board(
			campaign[i].bg[1],
			campaign[i].bg[2]
		)

		--countdown
		goal=campaign[i].goal
		print(sc_p1..'/'..campaign[i].goal,2,115,10)

		life=0 while life<campaign[i].goal do
			life+=1
			if life<=sc_p1 then
				rectfill(19+(life*2),114,19+(life*2),119,10)
			else
				rect(19+(life*2),114,19+(life*2),119,6)
			end
		end

		--title
		print(campaign[i].ttl,108,114,5)

		--init for each starting game during campaign
		if	(rdy_nxt==true) then
			init_stage(i)
		end

		move_commands()
		init_anim_sprite()

		draw_bave()

		draw_salads()
		spr(sprindex,x,y,1,1,direction<0)

		draw_cd()

		touch_salad()

	--condition if game is active
	end

end

function draw_campaign()
	--if explanations

	if(campaign[step_cp].tp=='explanation')then
		health=8
		draw_explanation(step_cp)
	--else draw boardgame
	elseif(campaign[step_cp].tp=='end')then
			sfx(-1)
			music(0)
			clean_up_salads()
			color_blind=false
			switch_control=false
			step_cp=df_step
			game_state=game_states.start
	else
		draw_game_cp(step_cp)
	end

end

function draw_cd()
	print(countdown..' s.',2,123,7)

	hexacountdown=countdown*60

	percentsmall=hexacountdown/(hexacdorigin)
	percent=percentsmall*100

	if percentsmall<0 then
		return
	end

	local kolor=11
	if(percent<50) then
		kolor=10
	end
	if(percent<30) then
		kolor=9
	end
	if(percent<10) then
		kolor=8
	end

	rectfill(22,123, 14+percent, 145, kolor)

end

function print3d(txt,x,y,c1,c2)
	print(txt,x,y,c1)
	print(txt,x,y+1,c2)
end

function init_anim_sprite()
	if (sprchange<0) then
		sprchange=10
	end
	if (sprchange_p2<0) then
		sprchange_p2=10
	end
end

function get_in_game()
	--if not crypted
	if(nb_player!=-1)then
		game_state=game_states.play
		_init()
		launch_music()
		set_salads(list_salads)
	end
	if(nb_player==-1)then
		game_state=game_states.campaign
		rdy_nxt=false
		set_campaign()
	end
end

function draw_end_menu()

	print('retry',25,99,7)
	print('main menu',25,109,7)
	print('press (x) to launch',25,119,5)

	if (btnp(3)) then
		sfx(0)
		if menu_nxt=='play' then
			menu_nxt='start'
			menu_end_arrow_pos=107
		else
			menu_nxt='play'
			menu_end_arrow_pos=97
		end
	end

	if (btnp(2)) then
		sfx(0)
		if menu_nxt=='play' then
			menu_nxt='start'
			menu_end_arrow_pos=107
		else
			menu_nxt='play'
			menu_end_arrow_pos=97
		end
	end

	if (btnp(5)) then
		if(menu_nxt=='play') then
			get_in_game()
		else
			sfx(-1)
			music(0)
		end
		game_state=game_states[menu_nxt]
	end

	spr(13,18,menu_end_arrow_pos)

end

function draw_gameover()

	--if two players, probalby there is one winner
	if nb_player==1 then
		game_state=game_states.win
	end
	spr(38,36,51,6,2)

	if(countdown<0)then
		print('time out',45,65,7)
	else
		print('you explode!',37,65,7)
	end

	draw_end_menu()

end

function draw_start()
	rectfill(0,0,128,20,12)
	circfill(0,5,30,9)
	circfill(5,5,10,10)
	circfill(5,5,8,7)
	rectfill(0,20,128,25,5)
	rectfill(0,21,128,30,3)
	rectfill(0,30,128,50,11)
	rectfill(0,50,128,128,6)

	map(0,0,0,30,16,1)
	map(0,3,28,-4,1,3)

	spr(1,20,20,1,1,direction<0)
	spr(44,30,26,1,1,false,false)
	spr(19,60,17,1,1)
	spr(19,100,22,1,1)
	spr(20,90,19,1,1)
	spr(48,55,28,1,1)
	spr(32,110,24,1,1)
	spr(21,77,34,1,1)

	--earth
	rectfill(5,60,122,160,4)

	-- logo eskargool
	palt(0,true)
	spr(6,36,63,7,2)

	draw_menu()
	action_menu()
end

function action_menu()
	if(btnp(3)) then
		sfx(0)
		nb_player+=1
	end
	if(nb_player>1) then
		nb_player=-1
	end
	if(btnp(2)) then
		sfx(0)
		nb_player-=1
	end
	if(nb_player<-1) then
		nb_player=1
	end
end

function draw_menu()
	--logo pico-8
	palt(14,false)
	print('a',35,53,7)
	print('game',77,53,7)
	spr(74,40,45,5,2)

	if(nb_player==0) then
		spr(13,23,89)
	end
	if(nb_player==1) then
		spr(13,23,99)
	end
	if(nb_player==-1) then
		spr(13,23,79)
	end

	print('training world (1p)',30,80,7)
	print('single board (1p)',30,90,7)
	print('battle (2 players)',30,100,7)
	print('press (x) to start',30,110,5)

end

function sort_winner()
	if nb_player==1 then
		if player_dead==1 then
			winner=2
		elseif player_dead==2 then
			winner=1
		elseif sc_p1>sc_p2 then
			winner=1
		elseif sc_p1<sc_p2 then
			winner=2
		else
			winner=3
		end
	else
		winner=0
	end
end

function draw_win()

	-- black background
	rectfill(0,0,128,128,0)

	sort_winner()

	if nb_player==1 then
		print('player 1',22,2,6)
		print(sc_p1,58,2,10)
		print('|',65,2,7)
		print(sc_p2,70,2,2)
		print('player 2',80,2,6)
	else
		--solo player
		print('time: in '..victory_time..' s',40,83,7)
		if (victory_best!=victory_time) then
			print('your best is '..victory_best..' s',30,89,5)
		end
	end


	if winner==1 then
			mssg_win='player 1 win!'
			posx_mssg=40
			spr(128,33,20,8,7)
	elseif winner==2 then
			mssg_win='player 2 win!'
			posx_mssg=40
			spr(136,33,20,8,7)
	-- draw game
	elseif winner==3 then
			mssg_win='draw!'
			spr(130,0,20,6,7)
			spr(138,80,20,6,7,true)
			posx_mssg=55
	elseif winner==0 then
		--player alone win
		palt(14, false)
		spr(64,28,40,9,4)
		posx_mssg=36
	end

	print(mssg_win,posx_mssg,75,11)

	draw_end_menu()

end

function _draw()
	cls()
	if	game_state==game_states.start then
		draw_start()
	end
	if game_state==game_states.play then
		draw_game()
	end
	if game_state==game_states.campaign then
		draw_campaign()
	end
	if game_state==game_states.gameover then
		draw_gameover()
	end
	if game_state==game_states.win then
		draw_win()
	end
	print(dbg,10,10,2)
end

if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
0000000000555000005550004444444400555000005550000bbbb60000000b0bbbb00000000000000000011101110bbb00000000600000005611165000000000
0000000006566500065665002222222206566500065665000b3333b00bb00b0b33300bb00bbb0000bb000bbb0bbb033b00000000760000006077706000000000
0070070065656650757566502222222265656650757566500b00003bb33b0bb30000b33b0b33b00bb3b0bb3bbb3bb00b0000000077600000600700600000f000
0007700075755969656559692222222275755161656551610bbb00033b030bbb0000b00b0b00300b30b0b373b373b00b000000007776000060050060000faf00
0007700056556969565569692222222256556161565561610b33000003b00b3bb000bbbb0bbbb00b00b0b711b117b00b00000000777500006006006000fa7af0
0070070055665999556659f94444444455665121556651210b0000bb00b00b03b000b33b0b33bb0bb0b0b711b117b00b000000007750000060070060000faf00
000000000559f191055f91914444444405512a1a05521a1a0b000b3bbb300b00bbbbb00bbb003b03bbb0bb7bbb7bb00bb000000075000000607770600000f000
000000000f9f99f969f9f9f94444444402121121612121210bbbbb0333000300333330033b00030033b03bbb3bbb3003bb00b000500000005777775000000000
05550555005550000055500003330333011101110333033303333300000b30000000000003000bb000b003b303b300003bbbb000500000000000000033333333
55655565065665000656650033b333b311c111c133b333b300000000000b3000000000000000b33b00b000b303b00000033330005650000000000000b3b3b3b3
5666566665656650656546503bbb3bb31ccc1ccc3bbb3bbb0000000002267aa0000000000000b00300b000b303b000000000000057650000000000003b3b3b3b
5666566675755969757559693bbb3bb31ccc1ccc3bb1331300000000088769900000000000003b000b3000b303b00000000000005776500000005000bbbbbbbb
555755755655696956556469333733731117117133171171000000000001c00000000000000003bbb300000000000000000000005765000000056500b3b3b3b3
56515615556659f9554659f83b313b131c151c513b191191000000000001c00000000000000000333000000000000000000000005650000000567650bbbbbbbb
556566550559f8980559f89833b3bb3311c1cc1133113311000000000000000000000000000000000000000000000000000000005000000000677760bbbbbbbb
005555500f9f99f90f9889f90033333000111110003333300000000000000000000000000000000000000000000000000000000000000000055555553bbb3bbb
09990999005550000000000000000000000000008000600800e80000000800080888000000088800000000000000000000555000005550000055500000000000
99a999a90656650000000000000000000000000000080800088888088808808808ee0000008eee800000000000000000065665000656650006566500008808e0
9aaa9aaa656546500055500000000000000000006088888008eee80ee808e8e80800000008e000e8080008088808888065656650656546506565465008888e7e
9aaa9aaa656558680556580800000000000000000080808e08000e00080808080888000008000008080008080008ee80757551617575516165655868088888e8
9997997958556869055568090055680800000000000ee0080808880888080e0808ee0000080000080e808e088808008056556161565564615855686100888880
9a919a19585558f8585858f8085858f80000580808e0805008880808e8080008080000000800000800808008ee0888e055665121554651285855582800088800
99a9aa990859f8985858f8980858f89808088888000e80500000080808080008080000000e80008e008880080008ee8005512b1b05512b1b08512b1b00008000
00999990888888f8888888888888888088888888e888888808888e08880800080888000000e888e000e8e0088808008002121121021881218888882800000000
02220222088808880999099906660666eeee0eeeeeeeeeee0eeee00eee0e000e0eee0000000eee00000e000eee0e00e000000000000000500000000099000000
22d222d288e888e899f999f966766676ee00eeeeee0eee0e00000000000000000000000000000000000000000000000005000000050000002222333399999900
2ddd2ddd8eee8eee9fff9fff67776777e00e0ee0ee0eee0e00000000000000000000000000000000000000000000000000555000000050002002300399000099
2ddd2ddd8eee8eee9fff9fff67776777e0e0e0e0ee00ee0e00000000000000000000000000000000000000000000000005565808050000002002300399999900
22272272888788789997997966666666e0e0e0e0ee00ee0e00000000000000000000000000000000000000000000000005556801005558082002300399000000
2d21d2128e81e8189f91f91967686786e0e0e0e0ee00e0ee00000000000000000000000000000000000000000000000058585828085858282002300399999900
22d2dd2288e8ee8899f9ff99667677660e00e0e00e00e00e00000000000000000000000000000000000000000000000058582b1b08582b1b2002300399000099
002222200088888000999990006666600e00e0000e00e00000000000000000000000000000000000000000000000000088888888888888800220033099999900
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660000000000000
0000000000000000000000000000000000000000000000000000dd50000000000000000000000000000000000000000000000000000000666666600000000000
0000000000000000000000000000000000000000000000000000d550000000000000000000000000000000000000000000000000000000666866600000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066697f6660000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066a777e660000000000
00000000000000000000000000000000000cccc100000000ccc10000000000000e8000fa0000000000000000000000000000000000000000b7d0000000000000
00000000008000000000000000000000000c10cc10000000c1cccd500000e8000e8000fa00000000007777077770077700777700000777700c00000000000000
0008880008e800099999a000000000000000000c10000000cc100d50000ee8000e8000fa00000000077077007700770007707700000700700000000000000000
008ee8e008e8e099aaa99a000b0000b30000000cc100c1000cc10d50000ee8000e8000fa00000000077777007700770007707707707777700000000000000000
08e008e088e8889900099900bb300b3000000000c100cc1000c10dd5000eee800e8000fa00000000077000007700770007707700007700700000000000000000
ee0008888e08e09a999aa9bbbb300b3000000000c100cc1000c100d5000e8ee80e8000fa00000000077000077770777707777000007777700000000000000000
e0000088e008e09aaaaa09a00b300b3000000000c100ccc100c100d5000e80ee8e8000fa00000000000000000000000000000000000000000000000000000000
0000000ee008e09a000009a00b300b3000000000cc10c1cc20c100dd500e800eee8000f000000000000000000000000000000000000000000000000000000000
000000000008e099000009a00b3000b3000000000c10c10c10c1000ddd5e8000ee80000000000000000000000000000000000000000000000000000000000000
000000000008e0a990009aa00bb300b3000000000ccc100cccc100000dde8000ee80000000000000000000000000000000000000000000000000000000000000
000000000008e00a99999a0000b300b30000000000cc1000cc100000000000000e8000fa00000000000000000000000000000000000000000000000000000000
00000000008ee000aaaaaa00000bbbb300000000000000000000000000000000000000fa00000000000000000000000000000000000000000000000000000000
000008e0008ee000000000000000000000000000000000000000000000000000000000fa00000000000000000000000000000000000000000000000000000000
00008ee008ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008e0008e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008e008ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000066666600000000000000000000000000000000000000000000000000000000006666660000000000000000000000000000000000000
00000000000000000066655555566660000000000000000000000000000000000000000000000000006665555556666000000000000000000000000000000000
00000000000000006655555555555666660000000000000000000000000000000000000000000000665555555555566666000000000000000000000000000000
00000000000000555555555555555556666000000000000000000000000000000000000000000055555555555555555666600000000000000000000000000000
00000000000005555555555555555556665660000000000000000000000000000000000000000555555555555555555666566000000000000000000000000000
00000000000055555555555555555555666666000000000000000000000000000000000000005555555555555555555566666600000000000000000000000000
00000000000055555555555555555555556665600000000000000000000000000000000000005555555555555555555555666560000000000000000000000000
00000000000555555666666555555555556666560000000000000000000000000000000000055555566666655555555555666656000000000000000000000000
000000000055555566555556666555555555666660000000aaa00000000000000000000000555555665555566665555555556666600000002220000000000000
00000000005555555555555555666555555556666600000aaaaa0000000000000000000000555555555555555566655555555666660000022222000000000000
0000000000555556555555555566665555555566660000aaaaaa9000000000000000000000555556555555555566665555555566660000222222100000000000
0000000005555555555555555556656555555566666000aaaaaa9000000000000000000005555555555555555556656555555566666000222222100000000000
0000000005555565555555555555665655555556666000aa5117a000000000000000000005555565555555555555665655555556666000222aa2200000000000
0000000005555555555555555555666615555556665600aa51aaa00000000000000000000555555555555555555566661555555666560022aa22200000000000
0000000005555655555666555525666665555556666660aa511aa00aaaaaa0000000000005555655555666555555666665555556666660222aa2200222222000
0000000005556555556556665555656665555555666666aaaaaaa00aaaaaa9000000000005556555556556665555656665555555666666222222200222222100
0000000055556555511555656555656661555555666556aaaaaaa00aa511a9000000000055556555511555656555656661555555666556222222200222222100
0000000055556555511556665655656661555555666555aaaaaaa00aa51aa9000000000055556555511556665655656661555555666555222222200222aa2100
0000000055565555511555665655656561555555665555aaaaaa900aa511a900000000005556555551155566565565656155555566555522222210022aa22100
000000005556555551155556661556656155555566555aaaaaaa900aaaaaa9000000000055565555511555566615566561555555665552222222100222aa2100
000000005556515551155556661556666155555655555aaaaaa9000aaaaaa9000000000055565155511555566615566661555556555552222221000222222100
00000000555651555665555666155666515555565555aaaaaaa0000aaaaaaa000000000055565155566555566615566651555556555522222220000222222200
0000000055565155556665565615556655555566555aaaaaaa90000aaaaa90000000000055565155556665565615556655555566555222222210000222221000
0000000055565155555555565615566655555565555aaaaaaa0000aaaaaa90000000000055565155555555565615566655555565555222222200002222221000
0000000055566555555555565615566555555555555aaaaaa90000aaaaaa90000000000055566555555555565615566555555555555222222100002222221000
000000000555665555555556565566615555556555aaaaaaa0000aaaaaaaa0000000000005556655555555565655666155555565552222222000022222222000
000000000055566555555556665566515555566555aaaaaa9000aaaaaaaa90000000000000555665555555566655665155555665552222221000222222221000
000000000005555555555556665565155555565555aaaaaa990aaaaaaa9900000000000000055555555555566655651555555655552222221102222222110000
00000000000555556655556655555115555566555aaaaaaa999aaaaaaa9000000000000000055555665555665555511555556655522222221112222222100000
00000000000055555666666556605555555665555aaaaaaaa99aaaaaa90000000000000000005555566666655660555555566555522222222112222221000000
0000000000000555555555556605555555665555aaaaaaaaaaaaaaaa990000000000000000000555555555556605555555665555222222222222222211000000
0000000000000056655555666a55665555655555aaaaaaaaaaaaaaa9900000000000000000000056655555662255665555655555222222222222222110000000
00000000000000006666666aaa5556666665555aaaaaaaaaaaaaaaa9000000000000000000000000666666622255566666655552222222222222222100000000
00000000000000000aaaaaaaaa556666655555aaaaaaaaaaaaaaa990000000000000000000000000022222222255666665555522222222222222111000000000
000000000000000aaaaaaaaaaaa55555555555aaaaaaaaaaaaaa9900000000000000000000000002222222222225555555555522222222222221110000000000
00000000000000aaaaaaaaaaaaaaa55555555aaaaaaaaaaaaaa99990000000000000000000000022222222222222255555555222222222222222111000000000
0000000000000aaaaaaaaaaaaaaaaaa5555aaaaaaaaaaaaaaaaaa999000000000000000000000222222222222222222555522222222222222222211100000000
000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9000000000000000000002222222222222222222222222222222222222222222110000000
00000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000022222222222222222222222222222222222eeee22222210000000
0000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa900000000000000000222222222222222222222222222222222222222ee2222222000000
000000000aaaaaaaaaaaaaaaaaa77777aaaaaaaaaaaaaaaaaaaaaaaa90000000000000000222222222222222222eeeee222222222222222222ee222222100000
0000000aaaaaaaaaaaaaaaaaaaaaaaa777aaaaaaaaaaaaaaaaaaaaaaa90000000000000222222222222222222222222eee22222222222222222e222222200000
000000aaaaaaaaaaaaaa999999aaaaaaa77777aaa6999aaaaaaaaaaaaa900000000000222222222222221111112222222eeeee22201111122222222222221000
0000aaaaaaaaaaaaa9999999999999aaaaaaaaa6669999999aaaaaaaaaaaa0000000222222222222211111111111112222222220001111111222222222222000
000099999aaaaaaa6999999999999999aaaaa66699999999999aaaaaa99990000000111112222222011111111111111122222000111111111112222221111000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001e050200512105125051290502a0512b0512b0512b0502b0512b0512b0510100004601046010360101600006010b6010a60109600086010560106601046000360103601026010b600076010860108601
000201000835010350163501d3502135025350293502d35032350353503a3503f35037350303502b35028350243501e3501a352133500e3500935004350313001530012300103000e3000c300093000130006300
0010001e000520c4020105201052054000005201052100000e0520e00003052030520e2000e05203052062000e0520e0000105201052202000c05203052102000c0520b20003052030521b4000c0520100204002
0010001e00152055020115201152054000015201152100000e1520e00003152031520b2000e15203152062000e152062000115201152202000c15203152023000c1520b20003152031520b2000c1520720006200
000f01000000032750377503775037750357502e75026750247502275022750257502575026150265502a15026150281502b1502d1502e150311503115031550345503455034750307502e7502e7502d75030750
0010001e0475011750117500675005750037500775006750037500875005750047500875005750047500975007750047500875003750017500a75005750027500b75006750047500675003750037500675005750
000200000d5500f550125501a55021550253502f550335503655038550395503a5503735035550325502e55026350175500955003550023500000000000000000000000000000000000000000000000000000000
000200003d65032650396503b6503c6503a6502e650266501e65019650136500f6500b65005650026500155001100137500000000000000000000000000000000000000000000000000000000000000000000000
0010001f087501f4502a75026550194501f750097500b4501a75006750134501d5501e7501e3500675004750017501c0501f75006750027500175016550195501e750077500375018550195502a7502a35000000
00070000181501a6503865037650363503565035350346503265031350316502f3502e6502d6502b65029350273502665024350226501e3501d650196501765012350106500c6500835003650000000000000000
000f00201175013750147501775016750147501775018750197501a7501a7501a7501c7501c7501c7501c7501c7501c7501b7501a750177501475011750107500e7500f7500f7500f7500f75010750177501a750
000d001c0b1500a1500a150027500000003150031500675000000071500715007150057500815008150081500a7500d1500d1500d15000000081500815007750000000b1500a1500b15000000000000000000000
000c00201f4501c050233502335024350233502335022350213501f3501d350193501635013350103500e3500c3500b350090500a050243500b050243500a050233500b050233500b050194500b050254500b350
000c0020113501c0001e2501e200243001e2501e250223001e2501d2501d3001425014250133000925009250082500b300090000a000243001225024300122502330013250233000b000194000b000254000b300
000c00201f750207502175022750227502275021750217501f7501d750197501775013750117500f7500f7500d7500c7500c7500d7500f7501175013750137501375013750127501375015750187501b7501e750
000c0020165501b4501e250155501a4501e2501e250194501e2501d2501045014250142500c750092500925008250044500d7500a75006750122500d150122500c150132500d5500d5500b550095500755005550
000100003835034350303502b35025350223501d350153500f3500c3500835006350043500335002350023500235003350083500d350123501b35025350343503f35000000000000000000000000000000000000
0001000024250282502c25031250362503b250332500c2500425007250122501b2502125028250312503b2503f2503a2502a2501b250112500b2500525009250112501a2501d250252502d250392503b25000000
001000201a15018150181501715018150173500d3500b3500d35011150152501925019250142501425014150163501435018350181501f1501d1501c1501a15018150197501c15018150187501f1501d1501c150
00100020180530f050180530f050187501a7501c7501f3001f7502175023750253002475023750217501d750217501d700217501d7502175000000187501a7501c75000000217501d75021750000000d0500d050
00160020210501b050210501c050220501d0502605026250282502a2502a150281502515021150211502215022150211501b0501a2501c2501e2501e1501c150191501515015150161501505015150130501a050
000a0020193501935019150191502a7502c3502c3502c3502b1502b1502a7501a350183501815017750267502735027350261502615024750193501a3501b1501b750287502d3502e3502e3502d3502815022150
000c00201a1501a15019150191501915018150173501725017350181501a1501c1501e150201502115022250232502415024150231501c1501535015250153501525015350152501535015350183501c15021150
0010001f0a1500e150161501a15011350071500a1500e1501115014150171501f350081500a1500d15010150111501a350133500f150183501315013150171501a1501b3500c1500f15012350121501015000000
000100001735017350173501735017350353503835038350373503735037350363503635004350043500435005350053500535004300043000430004300043000330003300033000330003300033000430004300
0010001f1855018550185501855018550195501c5501f550205501f5501c55019550155500f5500d5500f550125501455017550195501955018550165501555016550195501a5501c5501e5501e5501d55011100
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 41 02 03 05
03 0d 0c 0e 44
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
00 41 42 43 44
00 41 42 43 44
