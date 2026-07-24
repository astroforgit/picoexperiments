pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
moon = {};
moon.mass = 1;
moon.loc = {};
moon.loc.x = 100;
moon.loc.y = 100;
moon.vel = {};
moon.vel.x = -0.65;
moon.vel.y = 0.6;
moon.accel = {};
moon.accel.x = 0;
moon.accel.y = 0;
moon.dir = {};
moon.dir.x = 0;
moon.dir.y = 0;
moon.rad = 0.5;
spaceman = {};
spaceman.mass = 1;
spaceman.loc = {};
spaceman.loc.x = 20;
spaceman.loc.y = 95;
spaceman.vel = {};
spaceman.vel.x = 0.6;
spaceman.vel.y = 0.5;
spaceman.accel = {};
spaceman.accel.x = 0;
spaceman.accel.y = 0;
spaceman.dir = {};
spaceman.dir.x = 0;
spaceman.dir.y = 0;
spaceman.sprite = 1;
planet = {};
planet.loc = {};
planet.loc.x = 62;
planet.loc.y = 65;
planet.mass = 20;
planet.grav = 2;
planet.force = {};
planet.force.x = 0;
planet.force.y = 0;
planet.force2 = {};
planet.force2.x = 0;
planet.force2.y = 0;
force = {};
force.x = 0;
force.y = 0;
f = {};
f.x = {};
f.y = {};
force2 = {};
force2.x = {};
force2.y = {};
f2 = {};
f2.x = {};
f2.y = {};
distance = 0;
distace2 = 0;
distace3 = 0;
timer = 0;
timer2 = 0;
scoretimer = 0;
health_rect = 123;
o2_distance = 0;
greenrect = false;
finalscore = 0;
score_1 = 0;
score_2 = nil;
score_3 = nil;
score_4 = nil;
score_5 = nil;
score_6 = nil;
score_7 = nil;
score_8 = nil;
score_9 = nil;
score_10 = nil;
bucket_1 = 0;
bucket_2 = 0;
bucket_3 = 0;
bucket_4 = 0;
bucket_5 = 0;
bucket_6 = 0;
bucket_7 = 0;
bucket_8 = 0;
bucket_9 = 0;
bucket_10 = 0;

level = 0;
audio_toggle = true;
timer_go = true;
bloop = true;
fun_timer = 0;
fun_timer2 = 0;
redbar = 1;
orangebar = 1;
yellowbar = 1;
greenbar1 = 1;
greenbar2 = 1;
greenbar3 = 1;
greenbar4 = 1;
greenbar5 = 1;
greenbar6 = 1;
greenbar7 = 1;
greenbar8 = 1;
greenbar9 = 1;
greenbar10 = 1;
greenbar11 = 1;
greenbar12 = 1;
greenbar13 = 1;
greenbar14 = 1;
hand1 = 130;
hand2 = 138;
hand3 = 146;
hand4 = 154;
hand5 = 162;
hand6 = 170;
deaths = 0;

function _init()
	cartdata("lostinorbit");
	cls();
	approaching = 1;
	music(1);
	gamestate = 1;
end

function _update()
	timer2 = timer2 +1

	distance3 = distsqrv(spaceman.loc,planet.loc)
	distance4 = distsqrv(spaceman.loc,moon.loc)

	if gamestate == 3 then
		audio_toggle = true
		scoretimer = scoretimer + 1
		if o2_distance > 110 then
			gamestate = 5
		elseif o2_distance > 100 then
			moon.rad = 4
		elseif o2_distance > 75 then
			moon.rad = 2.5
		elseif o2_distance > 50 then
			moon.rad = 2
		elseif o2_distance > 25 then
			moon.rad = 1
		end

		if	distance4 < 50 then
			greenrect = true;
		else
			greenrect = false;
			timer = timer + 1;
		end

		force = attract();
		force2 = attract2();
		applyforce(force);
		applyforce2(planet.force2);

		moon.vel = addv(moon.vel, moon.accel);
		spaceman.vel = addv(spaceman.vel, spaceman.accel);
		moon.loc = addv(moon.loc, moon.vel);
		spaceman.loc = addv(spaceman.loc, spaceman.vel);
		moon.accel.x = moon.accel.x * 0;
		spaceman.accel.x = spaceman.accel.x * 0;
		moon.accel.y = moon.accel.y * 0;
		spaceman.accel.y = spaceman.accel.y * 0;

		if timer == 30 then
			health_rect = health_rect - 6;
			timer = 0;
		end

		if btn(2) then
			spaceman.accel.y -= 0.02;
			spaceman.sprite = 5;
		elseif btn(1) then
			spaceman.accel.x += 0.02;
			spaceman.sprite = 8;
		elseif btn(0) then
			spaceman.accel.x -= 0.02;
			spaceman.sprite = 7;
		elseif btn (3) then
			spaceman.accel.y += 0.02;
			spaceman.sprite = 6;
		else
			spaceman.sprite = 1;
		end

		if spaceman.loc.y > 200 then
 		spaceman.loc.y = 200
		end
	end


	if (btn(2) and gamestate == 1) then
		gamestate = gamestate + 1
	end

	if (btn(3) and gamestate == 4) then
		gamestate = 3
		check_level_and_start()
	end

	if (btn(2) and gamestate == 7) then
		gamestate = 8;
	end

	if (btn(3) and gamestate == 8) then
		level = 0;
		music(14);
		check_level_and_start();
		gamestate = 3;
	end

	if (btn(3) and gamestate == 2) then
		gamestate = gamestate + 1
		music(14)
	end

	if (btn(3) and gamestate == 6) then
		if level == 10 then
			gamestate = 7
		else
			check_level_and_start();
		end
	end

	if gamestate == 5 then
		if timer2 > 40 then
			timer2 = 0
		end

		if timer2 == 40 then
			if level == 0 then
				score_1 = 1300-scoretimer;
				if dget(1) == 0 then
					dset(1, (score_1));
				else
					if dget(1) < (score_1) then
						dset(1, (score_1));
					end
				end
			elseif level == 1 then
				score_2 = 1300-scoretimer;
				if dget(2) == 0 then
					dset(2, (score_2));
				else
					if dget(2) < (score_2) then
						dset(2, (score_2));
					end
				end
			elseif level == 2 then
				score_3 = 1300-scoretimer;
				if dget(3) == 0 then
					dset(3, (score_3));
				else
					if dget(3) < (score_3) then
						dset(3, (score_3));
					end
				end
			elseif level == 3 then
				score_4 = 1300-scoretimer;
				if dget(4) == 0 then
					dset(4, (score_4));
				else
					if dget(4) < (score_4) then
						dset(4, (score_4));
					end
				end
			elseif level == 4 then
				score_5 = 1300-scoretimer;
				if dget(5) == 0 then
					dset(5, (score_5));
				else
					if dget(5) < (score_5) then
						dset(5, (score_5));
					end
				end
			elseif level == 5 then
				score_6 = 1300-scoretimer;
				if dget(6) == 0 then
					dset(6, (score_6));
				else
					if dget(6) < (score_6) then
						dset(6, (score_6));
					end
				end
			elseif level == 6 then
				score_7 = 1300-scoretimer;
				if dget(7) == 0 then
					dset(7, (score_7));
				else
					if dget(7) < (score_7) then
						dset(7, (score_7));
					end
				end
			elseif level == 7 then
				score_8 = 1300-scoretimer;
				if dget(8) == 0 then
					dset(8, (score_8));
				else
					if dget(8) < (score_8) then
						dset(8, (score_8));
					end
				end
			elseif level == 8 then
				score_9 = 1300-scoretimer;
				if dget(9) == 0 then
					dset(9, (score_9));
				else
					if dget(9) < (score_9) then
						dset(9, (score_9));
					end
				end
			elseif level == 9 then
				score_10 = 1300-scoretimer;
				if dget(10) == 0 then
					dset(10, (score_10));
				else
					if dget(10) < (score_10) then
						dset(10, (score_10));
					end
				end
				gamestate = 7
			end
			level = level + 1;
			gamestate = 6
			timer2 = 0;
			timer = 0
		end
	end

	if gamestate == 6 then
		if level == 1 then
			if timer2 == 3 then
				if bucket_1 == 5 then
				else
					bucket_1 = bucket_1+1
					timer2 = 0
				end
			end
		elseif level == 2 then
			if timer2 == 3 then
				if bucket_2 == 5 then
				else
					bucket_2 = bucket_2+1
					timer2 = 0
				end
			end
		elseif level == 3 then
			if timer2 == 3 then
				if bucket_3 == 5 then
				else
					bucket_3 = bucket_3+1
					timer2 = 0
				end
			end
		elseif level == 4 then
			if timer2 == 3 then
				if bucket_4 == 5 then
				else
					bucket_4 = bucket_4+1
					timer2 = 0
				end
			end
		elseif level == 5 then
			if timer2 == 3 then
				if bucket_5 == 5 then
				else
					bucket_5 = bucket_5+1
					timer2 = 0
				end
			end
		elseif level == 6 then
			if timer2 == 3 then
				if bucket_6 == 5 then
				else
					bucket_6 = bucket_6+1
					timer2 = 0
				end
			end
		elseif level == 7 then
			if timer2 == 3 then
				if bucket_7 == 5 then
				else
					bucket_7 = bucket_7+1
					timer2 = 0
				end
			end
		elseif level == 8 then
			if timer2 == 3 then
				if bucket_8 == 5 then
				else
					bucket_8 = bucket_8+1
					timer2 = 0
				end
			end
		elseif level == 9 then
			if timer2 == 3 then
				if bucket_9 == 5 then
				else
					bucket_9 = bucket_9+1
					timer2 = 0
				end
			end
		elseif level == 10 then
			if timer2 == 3 then
				if bucket_10 == 5 then
				else
					bucket_10 = bucket_10 +1
					timer2 = 0
				end
			end
		end
	end

	if gamestate == 7 then
		if bloop == false then
			fun_timer2 = fun_timer2 + 1;
		end
		if timer_go == true then
			fun_timer=fun_timer+1
			if fun_timer == 20 then
				redbar = 8
				sfx(14)
			elseif fun_timer == 40 then
				redbar = 1
			elseif fun_timer == 60 then
				redbar = 8
				sfx(14)
			elseif fun_timer == 80 then
				redbar = 1
			elseif fun_timer == 100 then
				redbar = 8
				sfx(14)
			elseif fun_timer == 120 then
				redbar = 8
			elseif fun_timer == 122 then
				orangebar = 9
				sfx(15)
			elseif fun_timer == 124 then
				yellowbar = 10
				sfx(16)
			elseif fun_timer == 126 then
				greenbar1 = 11
				sfx(17)
			elseif fun_timer == 128 then
				greenbar2 = 11
				sfx(18)
			elseif fun_timer == 130 then
				greenbar3 = 11
				sfx(19)
			elseif fun_timer == 132 then
				greenbar4 = 11
				sfx(20)
			elseif fun_timer == 134 then
				greenbar5 = 11
				sfx(21)
			elseif fun_timer == 136 then
				greenbar6 = 11
				sfx(22)
			elseif fun_timer == 138 then
				greenbar7 = 11
				sfx(23)
			elseif fun_timer == 140 then
				greenbar8 = 11
				sfx(24)
			elseif fun_timer == 142 then
				greenbar9 = 11
				sfx(25)
			elseif fun_timer == 144 then
				greenbar10 = 11
				sfx(26)
			elseif fun_timer == 146 then
				greenbar11 = 11
				sfx(27)
			elseif fun_timer == 148 then
				greenbar12 = 11
				sfx(28)
			elseif fun_timer == 150 then
				greenbar13 = 11
				sfx(29)
			elseif fun_timer == 152 then
				greenbar14 = 11
				sfx(29)
			elseif fun_timer > 190 then
				hand1 = hand1-2
				hand2 = hand2-2
				hand3 = hand3-2
				hand4 = hand4-2
				hand5 = hand5-2
			end
		end
		if hand1 == 88 then
			ugh()
		end
	end
end

function _draw()
	if gamestate == 6 then
		cls()
		if bucket_1 == 5 then
			spr(98, 120, 0);
		end
		if level == 1 then
			print(score_1);
		elseif level == 2 then
			print(score_1+score_2);
		elseif level == 3 then
			print(score_1+score_2+score_3);
		elseif level == 4 then
			print(score_1+score_2+score_3+score_4);
		elseif level == 5 then
			print(score_1+score_2+score_3+score_4+score_5);
		elseif level == 6 then
			print(score_1+score_2+score_3+score_4+score_5+score_6);
		elseif level == 7 then
			print(score_1+score_2+score_3+score_4+score_5+score_6+score_7);
		elseif level == 8 then
			print(score_1+score_2+score_3+score_4+score_5+score_6+score_7+score_8);
		elseif level == 9 then
			print(score_1+score_2+score_3+score_4+score_5+score_6+score_7+score_8+score_9);
		elseif level == 10 then
			music(-1);
			finalscore = score_1+score_2+score_3+score_4+score_5+score_6+score_7+score_8+score_9+score_10;
			print(finalscore);
			if dget(11) == 0 then
				dset(11, (finalscore));
			else
				if dget(11) < (finalscore) then
					dset(11, (finalscore));
				end
			end

		end

		print(1300-scoretimer,59,58);
		line(59,65,69,65);

		if level == 1 then
			print(dget(1),59,68);
		elseif level == 2 then
			print(dget(2),59,68);
		elseif level == 3 then
			print(dget(3),59,68);
		elseif level == 4 then
			print(dget(4),59,68);
		elseif level == 5 then
			print(dget(5),59,68);
		elseif level == 6 then
			print(dget(6),59,68);
		elseif level == 7 then
			print(dget(7),59,68);
		elseif level == 8 then
			print(dget(8),59,68);
		elseif level == 9 then
			print(dget(9),59,68);
		elseif level == 10 then
			print(dget(10),59,68);
		end

		circ(64,65,50,9);
		circfill(64,15,5,0);
		circfill(64,15,bucket_1,13);
		circ(64,15,5,7);
		circfill(64,115,5,0);
		circfill(64,115,bucket_6,13);
		circ(64,115,5,7);
		circfill(94,24,5,0);
		circfill(94,24,bucket_2,13);
		circ(94,24,5,7);
		circfill(94,105,5,0);
		circfill(94,105,bucket_5,13);
		circ(94,105,5,7);
		circfill(111,48,5,0);
		circfill(111,48,bucket_3,13);
		circ(111,48,5,7);
		circfill(111,82,5,0);
		circfill(111,82,bucket_4,13);
		circ(111,82,5,7);
		circfill(34,24,5,0);
		circfill(34,24,bucket_10,13);
		circ(34,24,5,7);
		circfill(17,48,5,0);
		circfill(17,48,bucket_9,13);
		circ(17,48,5,7);
		circfill(34,105,5,0);
		circfill(34,105,bucket_7,13);
		circ(34,105,5,7);
		circfill(17,82,5,0);
		circfill(17,82,bucket_8,13);
		circ(17,82,5,7);

	elseif gamestate == 3 then
		cls();
		if health_rect < 0 then
			sfx(8);
			spr(98, 77, 0);
			audio_toggle = false;
			print("to restart", 89, 0, 7);
			deaths = deaths + 1;
			gamestate = 4;
		end

		if distance3 < 189 then
			if audio_toggle == true then
				sfx(7);
				audio_toggle = false;
			end
			spr(98, 77, 0);
			audio_toggle = false;
			print("to restart", 89, 0, 7);
			gamestate = 4;
			deaths = deaths + 1;
		end

		if distance4 < 50 then
			o2_distance = o2_distance + 0.5;
		end
		map(0,0,0,0,100,100);
		spr(spaceman.sprite,spaceman.loc.x-3,spaceman.loc.y-3);
		circfill(moon.loc.x, moon.loc.y, 3,0);
		circfill(moon.loc.x, moon.loc.y, moon.rad,13);
		circfill(planet.loc.x, planet.loc.y, 9, 12);
		circfill(planet.loc.x, planet.loc.y, 2, 1);
		circfill(planet.loc.x, planet.loc.y, 3);
		circ(moon.loc.x, moon.loc.y, 4,7);
		spr(49, planet.loc.x-3, planet.loc.y-1);
		spr(33, planet.loc.x-3, planet.loc.y-9);
		spr(48, planet.loc.x-12, planet.loc.y-6);
		spr(32, planet.loc.x-14, planet.loc.y-8);
		spr(34, planet.loc.x+5, planet.loc.y-8);
		rectfill(0,123,health_rect,126,8);
		if greenrect == true then
			rectfill(0,123,health_rect,126,3);
		end
		rect(0,123,123,126,7);

		if spaceman.loc.x > 180 then
			spaceman.loc.x = 180;
		end
		if spaceman.loc.y < -50 then
			spaceman.loc.y = -50;
		end
		if spaceman.loc.x < -50 then
			spaceman.loc.x = -50;
		end
		if spaceman.loc.y > 180 then
			spaceman.loc.y = 180;
		end
	end
	if gamestate == 2 or gamestate == 8 then
		cls();
		music(-1);
		print("to start", 97, 0, 7);
		spr(98, 85, 0);
		spr(4,40,30);
		spr(4,83,50);
		spr(4,100,30);
		spr(4,4,80);
		spr(4,50,90);
		spr(4,0,30);
		spr(4,110,65);
		spr(4,50,0);
		spr(2,60,13);
		circfill(62, 300, 190, 12);
		spr(21,45,60);
		spr(22,53,60);
		spr(37,45,68);
		spr(38,53,68);
		spr(24,37,74);
		spr(39,29,82);
		spr(26,25,90);
		spr(42,25,98);
		spr(41,17,98);
		spr(27,17,106);
		spr(28,25,106);
		spr(43,17,114);
		spr(44,25,114);
		spr(29,17,122);
		spr(30,25,122);
		spr(45,17,130);
		spr(46,25,130);
		spr(54,100,85);
		spr(54,10,50);
		spr(54,10,10);
		spr(54,60,40);
		spr(54,30,90);
		spr(54,100,10);
		spr(105,0,0);
		spr(100,7,0);
		spr(106,14,0);
		spr(104,21,0);
		spr(103,0,7);
		spr(107,7,7);
		spr(100,0,14);
		spr(101,7,14);
		spr(102,14,14);
		spr(103,21,14);
		spr(104,28,14);
		spr(131,70,80);
		spr(132,78,80);
		spr(133,86,80);
		spr(134,94,80);
		spr(147,70,88);
		spr(148,78,88);
		spr(149,86,88);
		spr(150,94,88);
		spr(151,102,88);
		spr(163,70,96);
		spr(164,78,96);
		spr(165,86,96);
		spr(166,94,96);
		spr(167,102,96);
		spr(180,78,104);
		spr(181,86,104);
		spr(182,94,104);
		spr(183,102,104);
		spr(143,78,112);
		spr(142,70,112);
		spr(128,86,112);
		spr(129,94,112);
		spr(130,102,112);
		spr(146,102,120);
		spr(145,94,120)
		spr(144,86,120);
		spr(159,78,120);
		spr(146,110,120);
		spr(177,110,112);
		spr(160,78,124);
		spr(177,118,120);

	elseif gamestate == 1 then
		cls();
		map(0,0,0,0,100,100);
		timer = timer + 1;
		spr(96,90,123);
		print("to skip", 101, 123, 7);
		if approaching == 1 then
			if timer > 2 then --a
				spr(64,1,1);
			end
			if timer > 4  then --p
				spr(77,8,1);
			end
			if timer > 6 then --p
				spr(77,15,1);
			end
			if timer > 8 then --r
				spr(79,22,1);
			end
			if timer > 10 then --o
				spr(76,29,1);
			end
			if timer > 12 then --a
				spr(64,36,1);
			end
			if timer > 14 then --c
				spr(66,43,1);
			end
			if timer > 16 then --h
				spr(71,50,1);
			end
			if timer > 18 then --i
				spr(72,57,1);
			end
			if timer > 20 then --n
				spr(82,64,1);
			end
			if timer > 22 then --g
				spr(70,71,1);
			end
			if timer > 24 then --.
				spr(83,78,1);
			end
			if timer > 200 then
				approaching = 0
				timer = 0
			end
		elseif approaching == 0 then
 		if timer > 200 then --e
				spr(68,1,1);
			end
			if timer > 202  then --x
				spr(85,8,1);
			end
			if timer > 206 then --p
				spr(77,15,1);
			end
			if timer > 208 then --e
				spr(68,22,1);
			end
			if timer > 210 then --r
				spr(79,29,1);
			end
			if timer > 212 then --i
				spr(72,36,1);
			end
			if timer > 214 then --e
				spr(68,43,1);
			end
			if timer > 216 then --n
				spr(82,50,1);
			end
			if timer > 218 then --c
				spr(66,57,1);
			end
			if timer > 220 then --i
				spr(72,64,1);
			end
			if timer > 222 then --n
				spr(82,71,1);
			end
			if timer > 224 then --g
				spr(70,78,1);
			end
			if timer > 226 then --u
				spr(84,1,8);
			end
			if timer > 228 then --n
				spr(82,8,8);
			end
			if timer > 230 then --e
				spr(68,15,8);
			end
			if timer > 232 then --x
				spr(85,22,8);
			end
			if timer > 234 then --p
				spr(77,29,8);
			end
			if timer > 238 then --e
				spr(68,36,8);
			end
			if timer > 240 then --c
				spr(66,43,8);
			end
			if timer > 242 then --t
				spr(81,50,8);
			end
			if timer > 244 then --e
				spr(68,57,8);
			end
			if timer > 246 then --d
				spr(67,64,8);
			end
			if timer > 248 then --t
				spr(81,1,15);
			end
			if timer > 250 then --u
				spr(84,8,15);
			end
			if timer > 252 then --r
				spr(79,15,15);
			end
			if timer > 254 then --b
				spr(65,22,15);
			end
			if timer > 256 then --u
				spr(84,29,15);
			end
			if timer > 258 then --l
				spr(75,36,15);
			end
			if timer > 260 then --e
				spr(68,43,15);
			end
			if timer > 262 then --n
				spr(82,50,15);
			end
			if timer > 264 then --c
				spr(66,57,15);
			end
			if timer > 266 then --e
				spr(68,64,15);
			end
			if timer > 268 then --.
				spr(83,71,15);
			end
			if timer > 550 then
				timer = 0;
				approaching = 3;
			end
		elseif approaching == 3 then
			if timer > 32 then --b
				spr(65,1,1);
			end
			if timer > 34  then --r
				spr(79,8,1);
			end
			if timer > 36 then --e
				spr(68,15,1);
			end
			if timer > 38 then --a
				spr(64,22,1);
			end
			if timer > 40 then --c
				spr(66,29,1);
			end
			if timer > 42 then --h
				spr(71,36,1);
			end
		if timer > 56 then --d
				spr(67,1,8);
			end
			if timer > 58 then --e
				spr(68,8,8);
			end
			if timer > 60 then --t
				spr(81,15,8);
			end
			if timer > 62 then --e
				spr(68,22,8);
			end
			if timer > 64 then --c
				spr(66,29,8);
			end
			if timer > 66 then --t
				spr(81,36,8);
			end
			if timer > 68 then --e
				spr(68,43,8);
			end
			if timer > 70 then --d
				spr(67,50,8);
			end
			if timer > 72 then --.
				spr(83,57,8);
			end
			if timer > 150 then
				approaching = 4
				timer = 0;
			end
		elseif approaching == 4 then
 		if timer > 20 then --i
				spr(72,1,1);
			end
			if timer > 22  then --n
				spr(82,8,1);
			end
			if timer > 24 then --i
				spr(72,15,1);
			end
			if timer > 26 then --t
				spr(81,22,1);
			end
			if timer > 28 then --i
				spr(72,29,1);
			end
			if timer > 30 then --a
				spr(64,36,1);
			end
		if timer > 32 then --l
				spr(75,43,1);
			end
			if timer > 34 then --i
				spr(72,50,1);
			end
			if timer > 36 then --z
				spr(86,57,1);
			end
			if timer > 38 then --i
				spr(72,64,1);
			end
			if timer > 40 then --n
				spr(82,71,1);
			end
			if timer > 42 then --g
				spr(70,78,1);
			end
			if timer > 48 then --f
				spr(69,1,8);
			end
			if timer > 50  then --a
				spr(64,8,8);
			end
			if timer > 52 then --i
				spr(72,15,8);
			end
			if timer > 54 then --l
				spr(75,22,8);
			end
			if timer > 56 then ---
				spr(87,29,8);
			end
			if timer > 58 then --s
				spr(80,36,8);
			end
		if timer > 60 then --a
				spr(64,43,8);
			end
			if timer > 62 then --f
				spr(69,50,8);
			end
			if timer > 64 then --e
				spr(68,57,8);
			end
			if timer > 66 then --.
				spr(83,64,8);
			end
			if timer > 100 then
				approaching = 5;
				timer = 0;
			end
		elseif approaching == 5 then
 		if timer > 60 then --t
				spr(81,1,1);
			end
			if timer > 62  then --h
				spr(71,8,1);
			end
			if timer > 64 then --r
				spr(79,15,1);
			end
			if timer > 66 then --u
				spr(84,22,1);
			end
			if timer > 68 then --s
				spr(80,29,1);
			end
			if timer > 70 then --t
				spr(81,36,1);
			end
			if timer > 72 then --e
				spr(68,43,1);
			end
			if timer > 74 then --r
				spr(79,50,1);
			end
			if timer > 76 then --space
				spr(89,57,1);
			end
			if timer > 78 then --1
				spr(88,64,1);
			end
			if timer > 80 then ---
				spr(87,71,1);
			end
			if timer > 82 then --e
				spr(68,1,8);
			end
			if timer > 84  then --x
				spr(85,8,8);
			end
			if timer > 86 then --h
				spr(71,15,8);
			end
			if timer > 88 then --a
				spr(64,22,8);
			end
			if timer > 90 then --u
				spr(84,29,8);
			end
			if timer > 92 then --s
				spr(80,36,8);
			end
			if timer > 94 then --t
				spr(81,43,8);
			end
			if timer > 96 then --e
				spr(68,50,8);
			end
			if timer > 98 then --d
				spr(67,57,8);
			end
			if timer > 100 then --.
				spr(83,64,8);
			end
			if timer > 160 then
				approaching = 6;
				timer = 0;
			end
		elseif approaching == 6 then
 		if timer > 40 then --t
				spr(81,1,1);
			end
			if timer > 42  then --h
				spr(71,8,1);
			end
			if timer > 44 then --r
				spr(79,15,1);
			end
			if timer > 46 then --u
				spr(84,22,1);
			end
			if timer > 48 then --s
				spr(80,29,1);
			end
			if timer > 50 then --t
				spr(81,36,1);
			end
			if timer > 52 then --e
				spr(68,43,1);
			end
			if timer > 54 then --r
				spr(79,50,1);
			end
			if timer > 56 then --s
				spr(80,57,1);
			end
			if timer > 58 then --space
				spr(89,64,1);
			end
			if timer > 60 then --3
				spr(92,71,1);
			end
			if timer > 62 then --+
				spr(93,78,1);
			end
			if timer > 64 then --4
				spr(90,85,1);
			end
			if timer > 66 then --+
				spr(93,92,1);
			end
			if timer > 68 then --8
				spr(91,99,1);
			end
			if timer > 70 then --space
				spr(89,106,1);
			end
			if timer > 72 then ---
				spr(87,113,1);
			end
			if timer > 74 then --e
				spr(68,1,8);
			end
			if timer > 76  then --x
				spr(85,8,8);
			end
			if timer > 78 then --h
				spr(71,15,8);
			end
			if timer > 80 then --a
				spr(64,22,8);
			end
			if timer > 82 then --u
				spr(84,29,8);
			end
			if timer > 84 then --s
				spr(80,36,8);
			end
			if timer > 86 then --t
				spr(81,43,8);
			end
			if timer > 88 then --e
				spr(68,50,8);
			end
			if timer > 90 then --d
				spr(67,57,8);
			end
			if timer > 92 then --.
				spr(83,64,8);
			end
			if timer > 140 then
				approaching = 7;
				timer = 0;
			end
		elseif approaching == 7 then
 			if timer > 40 then --p
				spr(77,1,1);
			end
			if timer > 42 then --r
				spr(79,8,1);
			end
			if timer > 44 then --e
				spr(68,15,1);
			end
			if timer > 46 then --p
				spr(77,22,1);
			end
			if timer > 48 then --a
				spr(64,29,1);
			end
			if timer > 50 then --r
				spr(79,36,1);
			end
			if timer > 52 then --i
				spr(72,43,1);
			end
			if timer > 54 then --n
				spr(82,50,1);
			end
			if timer > 56 then --g
				spr(70,57,1);
			end
			if timer > 58 then --e
				spr(68,1,8);
			end
			if timer > 60 then --v
				spr(94,8,8);
			end
			if timer > 62 then --a
				spr(64,15,8);
			end
			if timer > 64 then --c
				spr(66,22,8);
			end
			if timer > 66 then --.
				spr(83,29,8);
			end
			if timer > 350 then
				approaching = nil;
				timer = 0
				gamestate = 2;
			end
		end
	elseif gamestate == 7 then
		cls();
		map(0,0);
		if fun_timer2 > 60 then
			rectfill(0,0,40,8,0);
			print("deaths: " .. deaths, 1, 1, 7);
			if sfx1 == false then
			else
				sfx(31);
				sfx1 = false;
			end
		end
		if fun_timer2 > 100 then
			rectfill(0,8,40,8,0);
			print("score: " .. finalscore, 1, 8, 7);
			if sfx2 == false then
			else
				sfx(31);
				sfx2 = false;
			end
		end
		if fun_timer2 > 140 then
			rectfill(0,15,40,15,0);
			print("best: " .. dget(11), 1, 15, 7);
			if sfx2 == false then
			else
				sfx(31);
				sfx2 = false;
			end
		end
		if fun_timer2 > 140 then
			spr(96, 77, 0);
			print("to restart", 89, 0, 7);
			if sfx3 == false then
			else
				sfx(32);
				sfx3 = false;
			end
		end
		spr(193,44,56);
		spr(194,52,56);
		spr(195,60,56);
		spr(196,68,56);
		spr(197,76,56);
		spr(198,84,56);
		spr(199,92,56);
		spr(200,100,56);
		spr(201,108,56);
		spr(202,116,56);
		spr(203,124,56);
		spr(204,132,56);
		spr(208,36,64);
		spr(209,44,64);
		spr(210,52,64);
		spr(211,60,64);
		spr(212,68,64);
		spr(213,76,64);
		spr(214,84,64);
		spr(215,92,64);
		spr(216,100,64);
		spr(217,108,64);
		spr(218,116,64);
		spr(219,124,64);
		spr(220,132,64);
		spr(224,36,72);
		spr(225,44,72);
		spr(226,52,72);
		spr(227,60,72);
		spr(228,68,72);
		spr(229,76,72);
		spr(230,84,72);
		spr(231,92,72);
		spr(232,100,72);
		spr(233,108,72);
		spr(234,116,72);
		spr(235,124,72);
		spr(236,132,72);
		spr(240,36,80);
		spr(241,44,80);
		spr(242,52,80);
		spr(243,60,80);
		spr(244,68,80);
		spr(245,76,80);
		spr(246,84,80);
		spr(247,92,80);
		spr(248,100,80);
		spr(249,108,80);
		spr(250,116,80);
		spr(251,124,80);
		spr(252,124,80);
		spr(136,39,88);
		spr(137,47,88);
		spr(138,55,88);
		spr(139,63,88);
		spr(152,68,88);
		spr(153,76,88);
		spr(154,84,88);
		spr(155,92,88);
		spr(168,100,88);
		spr(169,108,88);
		spr(170,116,88);
		spr(171,124,88);
		spr(172,132,88);
		spr(9,19,hand1)
		spr(10,27,hand1);
		spr(11,19,hand2);
		spr(12,27,hand2);
		spr(55,-5,hand3);
		spr(56,3,hand3);
		spr(57,11,hand3);
		spr(58,19,hand3);
		spr(59,27,hand3);
		spr(60,35,hand3);
		spr(61,43,hand3);
		spr(112,-5,hand4);
		spr(113,3,hand4);
		spr(114,11,hand4);
		spr(115,19,hand4);
		spr(116,27,hand4);
		spr(117,35,hand4);
		spr(118,43,hand4);
		spr(119,-5,hand5);
		spr(120,3,hand5);
		spr(121,11,hand5);
		spr(122,19,hand5);
		spr(123,27,hand5);
		spr(124,35,hand5);
		spr(108,-5,hand6);
		spr(109,3,hand6);
		spr(110,11,hand6);
		spr(111,19,hand6);
		rectfill(101,66,103,71,redbar);
		rectfill(104,66,106,71,orangebar);
		rectfill(107,66,109,71,yellowbar)
		rectfill(110,66,112,71,greenbar1);
		rectfill(113,66,115,71,greenbar2)
		rectfill(116,66,117,71,greenbar3)
		rectfill(83,74,86,79,greenbar4);
		rectfill(86,74,89,79,greenbar5);
		rectfill(89,74,92,79,greenbar6);
		rectfill(92,74,95,79,greenbar7);
		rectfill(95,74,98,79,greenbar8)
		rectfill(98,74,101,79,greenbar9)
		rectfill(101,74,104,79,greenbar10)
		rectfill(104,74,107,79,greenbar11)
		rectfill(107,74,110,79,greenbar12)
		rectfill(110,74,113,79,greenbar13)
		rectfill(113,74,117,79,greenbar14)
	end
end

function attract()
	planet.force = subv(planet.loc, moon.loc);
	distance = magv(planet.force);
	planet.force = normv(planet.force);
	local strength = ((planet.grav * planet.mass * moon.mass)/(distance*distance));
	planet.force.x = planet.force.x * strength;
	planet.force.y = planet.force.y * strength;
	return planet.force;
end

function attract2()
	planet.force2 = subv(planet.loc, spaceman.loc);
	distance2 = magv(planet.force2);
	planet.force2 = normv(planet.force2);
	local strength = ((planet.grav * planet.mass * spaceman.mass)/(distance2*distance2));
	planet.force2.x = planet.force2.x * strength;
	planet.force2.y = planet.force2.y * strength;
	return planet.force2;
end

function applyforce(force)
	f.x = force.x / moon.mass;
	f.y = force.y / moon.mass;
	moon.accel = addv(moon.accel, f);
end

function applyforce2(force2)
	f2.x = planet.force2.x / spaceman.mass;
	f2.y = planet.force2.y / spaceman.mass;
	spaceman.accel = addv(spaceman.accel, f2);
end

--vectors
function addv(v1, v2)
 return {x=v1.x+v2.x, y=v1.y+v2.y}
end
function subv(v1,v2)
  return {x=v1.x-v2.x, y=v1.y-v2.y}
end
function multv(v,n)
  return {x=v.x*n, y=v.y*n}
end
function divv(v, n)
  return {x=v.x/n, y=v.y/n}
end
function distsqrv(v1, v2)
  return (v1.x-v2.x) * (v1.x-v2.x) + (v1.y-v2.y) * (v1.y-v2.y)
end
function normv(v)
	local hypotenuse = ((v.x * v.x)) + ((v.y) * (v.y))
	hypotenuse = sqrt(hypotenuse);
	return {x=v.x/hypotenuse, y=v.y/hypotenuse};
end
function magv(v)
	local hypotenuse = ((v.x * v.x)) + ((v.y) * (v.y))
	return sqrt(hypotenuse);
end

function check_level_and_start()
	if level == 0 then
		moon.mass = 1;
		moon.loc.x = 100;
		moon.loc.y = 100;
		moon.vel.x = -0.65;
		moon.vel.y = 0.6;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 20;
		spaceman.loc.y = 95;
		spaceman.vel.x = 0.6;
		spaceman.vel.y = 0.5;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3
	elseif level == 1 then
		moon.mass = 1;
		moon.loc.x = 60;
		moon.loc.y = 10;
		moon.vel.x = 0.7;
		moon.vel.y = 0;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 30;
		spaceman.loc.y = 50;
		spaceman.vel.x = 0;
		spaceman.vel.y = 1;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir = {};
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	elseif level == 2 then
		moon.mass = 1;
		moon.loc.x = 10;
		moon.loc.y = 60;
		moon.vel.x = 0;
		moon.vel.y = 0.8;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 85;
		spaceman.loc.y = 100;
		spaceman.vel.x = -0.7;
		spaceman.vel.y = 0.8;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	elseif level == 3 then
		moon.mass = 1;
		moon.loc.x = 65;
		moon.loc.y = 30;
		moon.vel.x = 1;
		moon.vel.y = 0;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 40;
		spaceman.loc.y = 106;
		spaceman.vel.x = 1;
		spaceman.vel.y = 0;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123;
		o2_distance = 0;
		gamestate = 3;
	elseif level == 4 then
		moon.mass = 1;
		moon.loc.x = 70;
		moon.loc.y = 100;
		moon.vel.x = 0.85;
		moon.vel.y = -0.35;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 90;
		spaceman.loc.y = 36;
		spaceman.vel.x = 0.37;
		spaceman.vel.y = 1;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	elseif level == 5 then
		moon.mass = 1;
		moon.loc.x = 51;
		moon.loc.y = 100;
		moon.vel.x = 1;
		moon.vel.y = 0;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 40;
		spaceman.loc.y = 30+2;
		spaceman.vel.x = 1;
		spaceman.vel.y = 0;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		timer2 = 0;
		scoretimer = 0;
		health_rect = 123;
		o2_distance = 0;
		gamestate = 3;
	elseif level == 6 then
	moon.mass = 1;
		moon.loc.x = 60;
		moon.loc.y = 95;
		moon.vel.x = -1;
		moon.vel.y = -0.2;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 40;
		spaceman.loc.y = 45;
		spaceman.vel.x = 1;
		spaceman.vel.y = -0.6;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123;
		o2_distance = 0;
		gamestate = 3;
	elseif level == 7 then
		moon.mass = 1;
		moon.loc.x = 45;
		moon.loc.y = 30;
		moon.vel.x = 1;
		moon.vel.y = 0;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 95;
		spaceman.loc.y = 50;
		spaceman.vel.x = 1;
		spaceman.vel.y = 0;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	elseif level == 8 then
		moon.mass = 1;
		moon.loc.x = 80;
		moon.loc.y = 30;
		moon.vel.x = 1;
		moon.vel.y = 0;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 70;
		spaceman.loc.y = 93;
		spaceman.vel.x = 1;
		spaceman.vel.y = 0;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	elseif level == 9 then
		moon.mass = 1;
		moon.loc.x = 30;
		moon.loc.y = 53;
		moon.vel.x = 0;
		moon.vel.y = 0.9;
		moon.accel.x = 0;
		moon.accel.y = 0;
		moon.dir.x = 0;
		moon.dir.y = 0;
		moon.rad = 0.5;
		spaceman.mass = 1;
		spaceman.loc.x = 95;
		spaceman.loc.y = 50;
		spaceman.vel.x = 1.2;
		spaceman.vel.y = 0;
		spaceman.accel.x = 0;
		spaceman.accel.y = 0;
		spaceman.dir.x = 0;
		spaceman.dir.y = 0;
		spaceman.sprite = 1;
		planet.loc.x = 62;
		planet.loc.y = 65;
		planet.mass = 20;
		planet.grav = 2;
		planet.force.x = 0;
		planet.force.y = 0;
		planet.force2.x = 0;
		planet.force2.y = 0;
		force.x = 0;
		force.y = 0;
		distance = 0;
		distace2 = 0;
		distace3 = 0;
		timer = 0;
		scoretimer = 0;
		health_rect = 123
		o2_distance = 0;
		gamestate = 3;
	end
end

function ugh()
	if bloop == true then
		music(20)
		bloop = false
		timer_go = false
	end
end
__gfx__
00000000077777700000000000000000000000000777777007777770077777700777777000005500000000005577777777555000000000000000000000000000
00000000766666670000000000000000000000007656656776666667766666677666666700555555500000005577777777555000000000000000000000000000
00000000765665670000000000000000000000007666666776666667756656677665665705555777755000005577777777555000000000000000000000000000
00000000766666670000000000000000000000007666666776566567766666677666666705577777755500005577777777550000000000000000000000000000
00000000077777700000000000a0000000a000000777777007777770077777700777777055777777775500005577777777550000000000000000000000000000
000000000ffffff000700000090900000aaa00000ffffff00ffffff00ffffff00ffffff055777777775500005577777777550000000000000000000000000000
000000000ffddff00000000000a0000000a000000ffddff00ffddff00ffddff00ffddff055777777775550005577777775550000000000000000000000000000
0000000000ffff0000000000000000000000000000ffff0000ffff0000ffff0000ffff0055777777775550005577777775550000000000000000000000000000
00000000000000000000000000000000000000000000000007700000000000000000000400000000000444440004444444000000444444444444000000000000
00000000000000000000000000000000000000000000000077770000000000000000004000000000000444400004444444000000444444444444400000000000
00000000000000000000000000000000000000000000007777777000000000000000040000000000000444400004444444000000444444444444400000000000
000000000000000000000000000000000000000000000777ddd77700000000000000400000000000000044000044444444000000044444444444440000000000
00000000000000000000090000000a00000000000000777dddd77700000000000044000000000000000044000044444444000000044444444444440000000000
00000000000000000000a0a00000aaa000000000000777ddd77d7770000000000440000000000000400040000044444444000000044444444444440000000000
00000000000000000000090000000a00000000000000777d77dd7700000000004400000000000000400040000444444444000000044444444444444000000000
000000000000000000000000000000000000000000000777dddd7000000000000000000000000004400000000444444444000000044444444444444000000000
000000000000000000000000000000000000000000000077dd000000000000400000000000000004400000000444444444000000044444444444444000000000
00000000000b00000000000000000000000000000000047770007000000000000000000000000044000000000444444444000000044444444444444400000000
0000000bccbcbcccbb00000000000000000000000000400770700000000040000000000000000444000000000444444444000000044444444444444400000000
0000000bcc77bcbbbbb0000000000077000000000004000070000000000444000000000000000444400000004444444444400000004444444444444400000000
000000bbc7777bbbbbb0000000000000000777000440000000007000004440000000000000000444400000004444444444400000004444444444444400000000
000000bbccbbbbbbbccc000000000000000070004000000000000007044440000000000000004444400000004444444444440000004444444444444440000000
00000000ccbbbbbbb77c000000000000000000000000000000000000444400000000000000004444400000004444444444440000004444444444444444000000
00000000cbcccccb7777000000000000000000000000000000000007444400000000000000004444444000004444444444440000004000000000000004000000
00000000cbbbbbccbbcccccc00000000000000000000000000000000000000000000000000000005777777775550000000000000000000000000000000000000
000000c0bbbbbbbccbcccccc00000000000000000000000000000000000000000000000000000055777777775555555555555500000000000000000000000000
000070c0bbbb7bbccccccccc00000000000007000000000000000000000000000044000000000555777777777775555555555555000000000000000000000000
000070ccbbb777777ccccccc00000000000007700000000000000000fffffffff444555555555557777777775557777777777755000000000000000000000000
00077bcccbbbbb7ccccccccc00000000000000000000000000000000ffffffff4444455555555777777777555577777777777755000000000000000000000000
000b7bcccccbbbbccccccccc00000000000000000000000000000000ffffffff4444455555555777777777555577777777777755000000000000000000000000
000bbc77ccccbbcccccccccc00000000000000000000000000070000ffffffff4444777777777777777777555777777777777755000000000000000000000000
000bbccccccccbcbcccccccc00000000000000000000000000000000ffffffff4444777777777777777777775555555555555555000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555000000005555555555555555555555550000000055555555
55777755577777555577777557777755557777755577777555777755577557755777777555777775000000005777555555777755557777550000000055777755
57777775577557755777777557777775577777755777777557777775577557755777777555777775000000005777555557777775577777750000000057777775
57755775577777755775555557755775577755555775555557755555577777755557755555555775000000005777555557755775577557750000000057755775
57777775577777755775555557755775577777555777775557755775577777755557755557755775000000005777555557755775577777550000000057777755
57755775577557755777777557777775577755555775555557777775577557755777777557777775000000005777777557777775577555550000000057755775
57755775577777555577777557777755557777755775555555777755577557755777777555777755000000005777777555777755577555550000000057755775
55555555555555555555555555555555555555555555555555555555555555555555555555555555000000005555555555555555555555550000000055555555
55555555555555555555555555550000555555555555555555555555555555555555555555555555555555555555555555555555555555555555555500000000
55777775577777755577775555550000577557755775577557777775555555555577755555555555577577555577775557777755555555555775577500000000
57777775577777755777777555550000577557755775577557777775555555555577755555555555577577555775577557777775555775555775577500000000
57777555555775555775577555550000577557755557755555577755557777555557755555555555577777755777777555557775557777555775577500000000
57777775555775555775577555550000577557755557755555777555557777555557755555555555555577555777777555777775557777555775577500000000
55577775555775555775577557750000577777755775577557777775555555555557755555555555555577555775577555557775555775555577775500000000
57777755555775555775577557750000557777555775577557777775555555555557755555555555555577555577775557777755555555555557755500000000
55555555555555555555555555550000555555555555555555555555555555555555555555555555555555555555555555555555555555555555555500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff0000000000000000000000000000
00070000000000000777777700000000007777000077770007777700077777700777777007770000007777700077770000000000000000000000000000000000
00777000000000000077777000000000077777700777777007700770077777700777777007770000077777700777777000000000000000000000000000000000
07777700000000000007770000000000077007700770077007777770000770000007700007770000077770000770077000000000000000000000000000000000
77777770000000000000700000000000077007700777770007777770000770000007700007770000077777700770077000000000000000000000000000000000
00000000000000000000000000000000077777700770077007700770077777700007700007777770000777700770077000000000000000000000000000000000
00000000000000000000000000000000007777000770077007777700077777700007700007777770077777000770077000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff444477777777777777777755555555555555555500000000ffffff444477777777777777777775555555557777775550000000000000000000000000
ffffffff444477777777777777777555577777777777777550000000ffffff444477777777777777777777755555555555555550000000000000000000000000
ffffffff444777777777777777777555577777777777777550000000ffffff444477777777777777777777755555555555555550000000000000000000000000
ffffffff444777777777777777777555555777777777777550000000ffffff444477777777777777777777755777755555555500000000000000000000000000
ffffffff444777777777777777777755555555555555555550000000ffffff444477777777777777777777757777777777777500000000000000000000000000
ffffffff447777777777777777777755577555555555555500000000fffffff44477777777777777777777755777777775555500000000000000000000000000
fffffff4447777777777777777777755777777777777775500000000fffffff44455555555555557777777775555555555555000000000000000000000000000
ffffff44447777777777777777777755777777777777777500000000fffffff44455555555555555555555555555555555550000000000000000000000000000
77777777777777777777444400000000000000055555500005555500000000000555577777777777777777555574400000000000000000000555555550055577
77777777777777777774444400000000000005577777555055555550000000000055555777755555555555555554400000000000000000000557775555555777
7777777777777777444444ff00000000000005577777755557777555500000000005555555555555557777775500000000000000000000005577777777777777
7777777777777774444fffff00555550000005577777755777777755500000000005555555557777777775555000000000000000000000005557777777777777
777777777777744444ffffff05557750000005577777755777777775500000000000557777777777555555000000000000000000000000000055577777777777
7777777777774444ffffffff05777755500000555777755777777775500000000000555777777775550000000000000000000000000000000005557777777777
777777777444444fffffffff55777775550000055777755555777775500000000000005555555555000000000000000000000000000000000000555577777777
7777777744444fffffffffff55777777550000005777755000577775000000000000000000000000000000000000000000000000000000000000055555777777
77777444444fffffffffffff057777777550000057777550055777750055550044440000000000f444ffffffffffffff00000000000000000000000555555577
444444444fffffffffffffff05577777775500005777755005577775055555504444000000000000440000000000000000000000000000000000000000555544
44444fffffffffffffffffff00577777775550005777755005577775055777554400000000000000000000000000000000000000000000000000000000000444
444fffffffffffffffffffff00557777777555005777755005577775055777750000000000000000000000000000000000000000000000000000000000000044
ffffffffffffffffffffffff00057777777755005777755005577775055577750000000000000000000000000000000000000000000000000000000000000004
ffffffffffffffffffffffff00055777777775505777775005777775005577750000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffff00005777777775505777775555777775005577750000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffff00005577777777555777777557777775055777750000000000000000000000000000000000000000000000000000000000000000
0000000fffffffffffffffff0000055777777755577777777777777755577775ffffffffff4444fffffffffffffffffffffffff0000000000000000000000000
0000000fffffffffffffffff000000577777777557777777777777775777777500000000004444fffffffffffffffffffffff000000000000000000000000000
0000000000000000000000000000005577777777557777777777777777777775000000000004400000ffffffffffffff00000000000000000000000000000000
00000000000000000000000000000005777777777777777777777777777777750000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005577777777777777777777777777775550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000557777777777777777777777777775550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000557777777777777777777777777775500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055777777777777777777777777755500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055777777777777777777777777755000000000000000000000000000000000000000000000000000000000000000000
00000000f00000000000000000000000005577777777777777777777777755000000000000000000000000000000000000000000000000000000000000000000
00000000ff0000000000000000000000005577777777777777777777777755000000000000000000000000000000000000000000000000000000000000000000
00000000fff000000000000000000000000557777777777777777777777550000000000000000000000000000000000000000000000000000000000000000000
00000000ffff00000000000000000000000557777777777777777777777550000000000000000000000000000000000000000000000000000000000000000000
00000000fffff0000000000000000000000057777777777777777777777550000000000000000000000000000000000000000000000000000000000000000000
00000000ffffff000000000000000000000057777777777777777777777550000000000000000000000000000000000000000000000000000000000000000000
00000000fffffff00000000000000000000057777777777777777777777755000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000
000000000000000000000000000000004444000000000000400000ffffffffffffffffffffffff444fffffffffffffffffffffff000000000000000000000000
0000000000055555550055000000000444440000000000f404ffffffffffffffffffffffffffff404fffffffffffffffffffffff000000000000000000000000
000000000555777755555555555555544444ffffffff66644466666666666666666666666666664446666fffffffffffffffffff000000000000000000000000
0000000055577777555555555777777444444ffffff6555555555555555555555555555555555555555556ffffffffffffffffff000000000000000000000000
0000000055777777777777777777777444444fffff655555555555555555555555555555555555555555556fffffffffffffffff000000000000000000000000
0000005557777777777777777777777444444fffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
0000005577777777777777777777777744444fffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
0000055777777777777777777777777744444fffff655111bbbb111bbbb111b11888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
0000057777777777777777777777777744444fffff65511b1111b1b1111b11111888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
0000557777777777777777777777777744444fffff65511b1111b111111b11111888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
0005557777777777777777777777777744444fffff65511b1111b11bbbb111111888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
0005557777777777777777777777777744444fffff65511b1111b1b1111111111888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
0005557777777777777777777777777744444fffff655111bbbb11bbbbbb11b11888999aaabbbbbbb111556fffffffffffffffff000000000000000000000000
000555777777777777777777777777774444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777774444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777774444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777774444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444ffffff655111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
000557777777777777777777777777744444fffffff55111111111111111111111111111111111111111556fffffffffffffffff000000000000000000000000
005577777777777777777777777777744444ffffff655555555555555555555555555555555555555555556fffffffffffffffff000000000000000000000000
005557777777777777777777777777744444fffffff6555555555555555555555555555555555555555556ffffffffffffffffff000000000000000000000000
005557777777777777777777777777744444ffffffff66644466666666666666666666666664444666666fffffffffffffffffff000000000000000000000000
005557777777777777777777777777744444fffffffffff404ffffffffffffffffffffffff4404ffffffffffffffffffffffffff000000000000000000000000
000055777777777777777777777777444444fffffffffff444ffffffffffffffffffffffff4444ffffffffffffffffffffffffff000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0003280002280000000000bebf3d000000000000000000006d6d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000020003000200cecf3d030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000130000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000020012000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000020000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030000000004020000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000200000000020004000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000002000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000302000003000202000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000020000000000000000000000000000000000000000000052000052005200005200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000400000000000200020000000000000000000000000000000000520052000000520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000052000000000000000000005252520000520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000005252525252525200525252525252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002000002000000000000000000000000000000000000000000000000000000000000005252525252525252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200030000000002000000000300020000000000000000000000000000000000000000000000005252005252525252520052520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000005252525252525252525200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001400001b510230001b520000001b530000001b520000001b510000001b520000001b530000001b520000001b510000001b520000001b530000001b520000001b510000001b520000001b530000001b52000000
001400001b510000001b520195301b530000001b520000001b510000001b520000001b530000001b520000001b510000001b520195301b530000001b520000001b510000001b520000001b530000001b52000000
001400000000000000000000000000000000002e500000002e540000002e540000002e540000002e5400000000000000000000000000000000000000000000002e540000002e540000002e540000002e54000000
0014000000000000000000000000000000000000000000002e500196102e500000002e500000002e5000000000000000000000000000000000000000000000002e500196102e5000000019610196102e50000000
001400000000019610196201961000000000001961000000000001961000000000000000000000186101862018610000001961000000000001961000000000000000019600196100000019600000001961000000
00140000000001961019620196101562017630186100000000000196100f620166200000014630186101862018610000001962000000000001961000000000000000019610196100a62019620096201963009630
0014000001600016000160001600016000160001600016000160001600016000160001600016000160001600036000361001610026200462005630096300b6300e63013640176401b6501f650246602966032660
000100003761037610376103761037610376103661036610366103661036610366103661036610366103561035610346103461035610356103560035600366003660037600376003760038600386003860038600
000400002411024110241002410024110241102410024100241102411024100241002411024110241002410024110241102411024110241102411024110241102411024110241102411024110241102411024110
000400002411024110241102411024110241102411024110241102411024110241102411024110241102411024110241102411024110241102411024110241102411024110241102411024110241102411024110
002800000102001000015200100001020010000152001000010200100001520010000102001000015200110001020010000152001100010200100001520000000102001000015200000001020010000152000000
001400000102001000015200100001020010000152001000010200100001520010000102001000015200110001020010000152001100010200100001520000000102001000015200000001020010000152000000
0014000001000190100d010190100d010010001b0100100019000190100d010190100d010010001b010190000d000190100d010190100d010010001b0100d00019000190100d010190100d010010001b01000000
00140000150001c00018000130001c00015000150101c00018010130101c000150101c00011000180101c00018000180101c00018010130101c000150101c00011000180101c00018000180101c0001801014000
001000002f03035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003003035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003003035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003003035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003003035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003403035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003403035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003403035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003403035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003803035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003803035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003803035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003803035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c03035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c03035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c03035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c03035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002d070250000c0000c000000000c0000c0000b0000b0000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000390303d0303d0303d0303d0303d0303d0303d0203d0103d0003d000390003d0003d0003d0003d0003d0003d0003d0003d0003d0000000000000000000000000000000000000000000000000000000000
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
01 00 42 43 44
01 00 42 43 44
01 00 42 43 44
01 01 42 43 44
01 01 42 43 44
01 01 02 43 44
01 01 02 03 44
01 01 02 03 44
01 01 02 04 44
01 01 02 04 06
04 02 42 43 44
04 07 42 43 44
01 08 42 43 44
04 09 42 43 44
01 0a 0b 43 44
00 0a 0b 43 44
00 0a 0b 0c 44
00 0a 0b 0c 44
00 0a 0d 0b 44
02 0a 0d 0b 44
04 20 42 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
04 20 42 43 44
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
