pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- a top down action game 
-- by sebastian lind

-- thanks gruber for lending music
-- thanks fred72 for great functions

game_transition = false
biting = false
bite_y = 0
bite_stop_y = -36
weapon_overload = -1

function _init()
  cartdata("elstiskalinjen_fervour")
  game_won = dget(0)

  pal(10, 128, 1) -- yellow t (1, 129, 1) -- darker blue
  pal(8, 136, 1) -- purple red

  palt(3, true) -- dark green is transparent
  palt(0, false)

  if (game_won == 1)add_switch_weapon_option()

  start_game()
  levels_weapon = split(levels_weapon,",") -- make table
  level_player_angle = split(level_player_angle,",")

  load_level(current_level)
  
  music(1)
end

levels = {
  "207,275,0:177,185,1:185,103,1:137,82,1|215,313,148,288:148,287,131,235:215,312,292,261:292,261,288,167:288,167,176,62:143,177,69,62:69,62,177,61:143,176,130,237|160,233,10:84,71,14:274,256,16:282,166,13|167,265,0:160,205,2:258,183,2:172,163,1:127,96,0:169,97,0:221,217,1",
  "263,368,0:359,399,1:380,269,2:309,175,2:434,165,2:350,354,1|208,401,227,311:227,311,333,354:204,401,318,445:319,445,448,381:332,353,331,247:271,186,326,108:437,243,483,177:416,52,323,109:271,185,330,251:444,382,436,241:415,51,484,180|373,161,16:205,398,16:226,310,16:320,443,13:325,346,13|282,392,0:407,331,0:350,245,1:411,193,2:327,179,2:401,126,1:358,124,0",
  "271,235,0:253,152,1:282,89,1:337,99,1:329,155,1:300,121,2:464,122,3|222,239,300,271:300,271,343,235:221,237,184,171:183,171,255,68:254,68,386,67:341,235,391,170:387,172,480,231:480,230,517,129:517,129,446,5:385,64,447,5|181,170,12:382,64,12:391,208,16:223,226,16:335,229,16|249,192,1:338,179,0:387,146,4:381,90,3:461,164,3:439,87,3:482,123,3:274,137,5",
  "232,299,0:335,232,1:359,210,2:214,116,1:239,148,1:237,108,1:101,199,2:90,224,2:278,221,1:234,175,1:191,208,1|235,338,288,267:50,242,32,188:32,188,178,167:177,167,229,31:229,31,283,167:286,270,435,218:433,216,281,164:231,335,153,258:153,260,49,242|233,336,12:228,39,16:427,217,12:35,191,16:240,224,15|190,254,3:193,175,3:273,176,3:271,255,3:96,214,1:223,138,2:336,218,1:222,291,0:163,193,5:214,240,4:255,251,4:257,196,4:208,200,4",
  "220,199,0:111,109,2:185,50,2:187,145,1:216,123,1:284,108,1:190,101,6:264,88,1:152,34,6|239,242,60,177:60,177,144,1:144,-1,329,104:238,242,326,101|245,112,12:135,134,12|162,166,0:221,80,1:152,29,1:93,151,2:282,121,0:245,178,0:160,108,5:138,94,6:275,139,6",
  "285,258,0:250,170,2:336,191,1:282,137,5:316,169,2:222,195,1:344,83,1:251,78,1:299,93,3|287,307,165,209:165,210,250,118:248,119,226,21:223,23,381,22:381,22,363,128:289,307,415,208:414,207,363,123|167,209,12:246,119,12:361,123,12:407,207,12:288,293,16|244,231,1:264,179,2:338,124,3:267,123,3:303,124,3:334,95,2:269,83,1:304,38,0:196,207,4:368,205,4:318,212,0",
  "328,231,0:335,183,5:159,334,4:125,415,4:143,394,1:231,205,1:342,158,2:117,451,6:101,397,1|357,260,273,256:272,256,191,250:188,176,78,206:78,206,72,287:197,252,261,344:257,344,170,399:170,399,206,448:203,448,102,473:102,473,57,389:56,389,113,320:110,324,69,284:400,216,399,127:399,127,188,176:399,214,352,261|103,274,16:390,135,16:252,341,10|129,344,0:202,330,1:280,200,1:326,160,2:135,330,6:175,308,5",
  "344,466,0:326,382,1:359,382,1:344,364,1:348,291,7:352,269,2:411,217,3:348,213,1:387,207,2|264,424,349,523:349,523,425,411:265,424,318,205:423,409,454,195:317,206,425,120:422,120,453,199|407,176,16:424,410,16|323,424,0:382,361,1:319,299,2:361,474,2",
  "274,261,0:219,171,7:273,163,7:334,117,6:242,142,4:148,185,5:190,57,1:241,42,2|213,218,259,343:260,342,355,301:353,300,299,182:299,182,382,188:381,188,369,49:366,51,278,122:212,218,154,331:153,329,73,131:73,131,188,134:188,131,122,31:122,31,275,14:272,14,278,120|278,118,10:183,131,10:302,184,10:208,221,10|248,261,0:305,266,1:256,212,1:214,184,5:223,141,6:263,167,5:147,190,2:208,52,1:349,103,0:322,149,1:257,79,2",
  "129,430,0:30,252,4:236,301,2:275,284,3:55,281,6:242,217,5:223,220,2:60,243,7:192,389,1:150,364,1:83,380,1|148,241,229,270:225,270,150,354:269,184,337,302:334,302,202,448:200,447,28,445:28,444,13,326:151,351,85,242:140,161,11,196:14,330,12,190:86,246,138,158:148,241,187,158:187,158,272,187|216,270,16:200,441,16:27,441,14:68,322,16|109,325,4:34,287,4:70,219,4:42,369,3:77,262,3:33,216,3:108,394,0:170,398,1:217,374,2:263,328,6:254,264,5:195,214,6",
  "220,355,5:187,327,2:264,328,2:203,432,0:228,300,7:151,375,1:285,369,1|116,382,197,477:197,477,326,375:325,374,228,253:113,380,229,256|194,469,16:114,380,16:228,263,16:320,374,16|221,415,0:184,417,0:158,360,1:216,326,1:258,377,2:208,366,2:249,354,6:184,379,5", 
  "150,363,6:159,261,7:128,283,3:276,342,3:354,240,2:232,98,0:259,338,5:251,39,2:316,299,2|203,79,224,12:223,12,306,27:302,33,267,103:204,76,187,161:187,155,308,237:308,237,269,308:349,176,391,248:267,307,125,191:259,402,182,357:182,356,177,397:177,393,120,390:125,343,34,244:37,245,128,192:327,360,255,402:265,98,352,181:389,245,324,362:119,392,124,341|115,242,16:296,237,16:304,30,12:194,150,14:267,304,10|166,352,3:142,344,3:228,62,0:257,155,0:343,223,1:307,340,1:207,319,2:139,268,0:182,293,1:263,361,5:288,308,6",
  
  "267,239,8:414,372,0|113,187,135,394:273,471,266,349:267,351,340,351:340,351,403,481:406,479,472,387:473,388,456,217:456,217,326,110:134,388,274,476:114,189,328,112|404,483,14:277,473,14|384,402,0:401,433,0:435,381,0:351,300,1:389,214,1:188,232,2:241,272,3:289,273,3:241,208,3:289,208,3:207,238,4:271,158,4:338,238,4:269,306,4:269,239,7:242,427,7:230,252,5:265,214,6:313,292,6:178,161,0:181,310,0:412,370,7"
}

levels_weapon = "0,0,2,1,1,0,0,2,2,0,1,0,0"
level_player_angle = "0.25,0.9,0.25,0.25,0.25,0.25,0.22,0.25,0.3,0.25,0.37,0.2,0.3"

function load_level(id)
  t = 0
  reset_entities()
  stamina = 100
  hurt_counter = 0
  p1state = 0
  p1a = level_player_angle[id]
  level_c = 120
  if(weapon_overload == -1)p1_sword_type = levels_weapon[id]
  souls_level_started = souls
  load_map(levels[id])
  loading_level = false
end

function start_game()
  current_level = 1
  t = 0
  level_c = 0
  game_state = 0
  game_won_c = 0
  nr_enemies = 0

	t = 0
  frames = 0
	seconds = 0
	minutes = 0
  deaths = 0
  souls = 0
  souls_level_started = 0

  health = 100
  health_t = health
  stamina = 100
  stamina_t = stamina

  hitstun = 0

  p1x=128
  p1y=128

  p1ox = p1x
  p1oy = p1y
  p1xtile = flr(p1x/8)
  p1ytile = flr(p1y/8)

  p1acc = 0.1
  p1speed = 20
  p1dx = 0
  p1dy = 0
  p1a = 0

  p1knockback = 1.5

  p1state = 0
  move_t = 0
  feet_d = 0

  swa = 0
  swsp = 0
  swhits = 0
  move_back = true
  sw_c = 0
  p1ha = 0

  dash_counter = 0
  hurt_counter = 0

  -- 0 sword, 1 gun, 2 mace
  p1_sword_type = 0
  p1_gun_delay = 0

  camerax = p1x
  cameray = p1y
  camerasize = 52
  center_camera = false
  camera_dash = 0
  weapon_select_unlocked = false
end

function _update60()
  t+=0.01
  
  foreach(particles, update_particle)
  foreach(effects, update_effect)

  handle_biting()

  if game_state == 0 then 
    spawn_particle_around(0)
    if not biting and (btnp(4) or btnp(5)) then
      biting = true
      game_transition = true
      sfx(21)
    end
    if game_transition and bite_y > 50 then -- game start
      game_state = 1
      t = 0
      game_transition = false
      music(-1,1000)
    end
  elseif game_state == 1 then 
    if hitstun <= 0 then
      for k,p in pairs(enemies) do
        update_enemy(p)
        for k,op in pairs(enemies) do
          move_enemies_away(p, op)
        end
      end
      foreach(walls, update_wall)
      foreach(pillars, update_pillar)
      foreach(bullets, update_bullet)
      update_player()
      update_camera()
      if (boss_health > 0)update_boss()

      if game_won_c == 0 and current_level > 1 then 
        frames += 1
		    if frames == 30 then seconds += 1 frames = 0 end
		    if seconds == 60 then minutes += 1 seconds = 0 end
      end
    else 
      hitstun-=1
    end

    if game_state == 1 and game_won_c == 0 and not loading_level and #enemies == 0 and #effects == 0 and boss_health == 0 then 
      biting = true
      loading_level = true
      current_level += 1
      sfx(11)
    end
    if loading_level and bite_y > 50 then
      load_level(current_level)
    end
    if (level_c > 0)level_c-=1
  elseif game_state == 2 or game_state == 3 then 
    spawn_particle_around(game_state == 3 and 2 or 1)
    if bite_y >= bite_stop_y-2 and (btnp(4) or btnp(5)) then
      if not biting and not game_transition then 
        biting = true
        game_transition = true
        sfx(21)
      end
    end

    if game_transition and not biting then -- game start
      game_transition = false
      if game_state == 2 then 
        game_state = 0
        current_level = 0
        start_game()
      elseif game_state == 3 then
         game_state = 1
         souls = souls_level_started
      end
      load_level(current_level)
      health = 100
    end
  end

  if game_won_c > 1 then -- add delay to victory
    game_won_c-=1
    if game_won_c == 1 then
      game_transition = true
      biting = true
    end
  elseif game_won_c == 1 then 
    if game_transition and bite_y > 50 then 
      game_state = 2
      game_transition = false
      game_won_c = 0
    end
  end
end

function spawn_particle_around(col)
 if ceil(t * 100) % 8 == 0 then
    local sp_x, sp_y = random_corner() 
    local c_a = angle(64, 64, sp_x, sp_y)
    init_particle(sp_x, sp_y, c_a, 2 + rnd(6), 10 + rnd(7), col)
  end
end

function reset_entities()
	for k,v in pairs(enemies) do enemies[k]=nil end
	for k,v in pairs(props) do props[k]=nil end
	for k,v in pairs(walls) do walls[k]=nil end
	for k,v in pairs(pillars) do pillars[k]=nil end
  for k,v in pairs(bullets) do bullets[k]=nil end
  boss_health = 0
end

function handle_biting()
  if biting then 
    bite_y = lerp(bite_y, 63, 0.2)
    if bite_y > 61 then 
      biting = false
      if (game_state == 1 or game_transition)sfx(6)
      for i=0, 8 do 
        init_bite_particle(i, 0.25)
        init_bite_particle(i, 0.75)
      end
    end
  else 
    if bite_y > -35 then 
      bite_y = lerp(bite_y, game_state == 0 and 0 or -36, 0.1)
    else
      bite_y = -36
    end
  end
end

function init_bite_particle(id, dir)
  init_particle(camerax + id*16 - 64, cameray, dir, 3 + rnd(3), 4 + rnd(3), 1)
end

weapon_name={
  "level",
  "sword", 
  "gun",
  "mace"
}

function add_switch_weapon_option()
  menuitem(1, "weapon: " .. weapon_name[weapon_overload+2], function() switch_weapon()  end)
end

function switch_weapon()
  if weapon_overload < 2 then
    weapon_overload+=1
  else 
    weapon_overload = -1
  end
  sfx(1)
  if weapon_overload > -1 then 
    p1_sword_type = weapon_overload
  else 
    p1_sword_type = levels_weapon[current_level]
  end
  menuitem(1, "weapon: " .. weapon_name[weapon_overload+2], function() switch_weapon()  end)
end

function _draw()
  cls()
  --line(64,0,64,128,2)
  --line(0,64,128,64,2)
  if game_state == 0 then
    logo_y = 52 + sin(t) * 1.9
    for i=0,12 do
      fillp(™)
      draw_spinning_line(i, 0.02)
      fillp()
      draw_spinning_line(i,0)
    end
    foreach(particles, draw_particle)

    spr(128,80,33-sin(t)*0.9,4,4)
    spr(166,100,50-sin(t)*1.1,3,3)
    spr(132,21,52+sin(t)*1.9,11,2)
    draw_blink_start(78)
  elseif game_state == 1 then
    draw_grid()
    camera(camerax - 64, cameray - 64)
    foreach(props, draw_prop)
    foreach(walls, draw_wall)
    foreach(pillars, draw_pillar)
    
    foreach(particles, draw_particle)
    foreach(enemies, draw_enemy_feet)
    foreach(enemies, draw_enemy)
    if (boss_health > 0)draw_boss()
    draw_player()
    foreach(bullets, draw_bullet)

    --draw_camera()

    camera()
    foreach(effects, draw_effect)
    draw_player_ui()
    if (boss_health > 0)draw_boss_ui()
    if level_c > 0 then
      spr(74 + p1_sword_type, 61, 22)
      local level_str = "- level " .. current_level.. " -"
      print(level_str, 64-#level_str*2, 32, 8)
      if(current_level > 1)draw_time(-1,42)
    end
  elseif game_state == 2 or game_state == 3 then 
    foreach(particles, draw_particle)
    spr(192,41,44,6,2)
    if game_state == 2 then 
      spr(224,44,64,5,2)

      spr(31,4,2)
      draw_time(14,4)
      spr(15,4,11)
      print("souls: " .. souls, 14,13, 7)
      spr(30,4,21)
      print("deaths: " .. deaths, 14,22, 7)

      if weapon_select_unlocked then 
        spr(46, 4, 30)
        print("weapon select unlocked!", 14, 31, 13)
      end
    else 
      spr(229,41,64,6,2)
    end
    draw_blink_start(112)
  end

  if game_state == 1 and current_level == 1 then 
    draw_controls()
  end

  if bite_y > bite_stop_y then -- draw bite transition    
    rectfill(0,-1,128, bite_y-1, 1)
    rectfill(0,128,128, 128-bite_y, 1)
    for i=0, 3 do 
      spr(172, 10 + i * 34, 92 - bite_y - cos(t - i / 4)*2.1, 4, 5)
      spr(172, -6 + i * 34, - 10 + bite_y + sin(t - i / 4)*2.1, 4, 5, false, true)
    end
  end

  if (game_state == 0)print("sebastian lind @elastiskalinjen", 2, 122, 14)
end

function draw_controls() 
  print("move",8, 121, 13)
  spr(169, 4, 102, 3, 2)

  print("attack", 40, 121, 13)
  spr(btn(4) and 165 or 164, 42, 112)
  print("/z", 52, 114, 7)

  print("dash/tackle", 82, 121, 13)
  spr(btn(5) and 180 or 181, 94, 112)
  print("/x", 104, 114, 7)
end

-- -x is centered
function draw_time(x,y)
	local m = minutes % 60
	local h = flr(minutes / 60)
  local time_str = (h < 10 and "0"..h or h)..":"..(m < 10 and "0"..m or m)..":"..(seconds < 10 and "0"..seconds or seconds)
	print(time_str, x == -1 and 64 - #time_str * 2 or x, y, 14)
end

function draw_blink_start(y)
  if (flr(t * 10) % 6 ~= 0)print("press Ž/—", 43, y, 13)
end

function draw_spinning_line(offset, slight_offset)
  line(64,logo_y + 14, 64+cos(t/6 - (1*(offset/12 - slight_offset))) * 80, logo_y + 14 + sin(t/6 - (1*(offset/12 - slight_offset))) * 80, 1)
end

function draw_grid()
	fillp(“)
	for x=0, 7 do 
		for y=0, 7 do
			rect(x*16, y*16,-1 + x*16+16,-1 + y*16+16,1)
		end
	end
	fillp()
end

function random_corner() 
  local corner = flr(rnd(4))
  if corner == 0 then
    return 126, rnd(128)
  elseif corner == 1 then
    return 2, rnd(128)
  elseif corner == 2 then
    return rnd(128),2
  elseif corner == 3 then
    return rnd(128),126
  end
end

-->8
--player

function update_player()
  p1ox = p1x
  p1oy = p1y

  health_t = lerp(health_t, health, 0.1)
  stamina_t = lerp(stamina_t, stamina, 0.1)

  stamina = min(stamina, 100)
  stamina = max(stamina, 2)

  if p1state == 0 then 
    if btnp(4) and stamina > 15 then -- attack
      p1state = 1
      stamina-= 15
      if p1_sword_type == 0 then 
        sfx(0)
      elseif p1_sword_type == 1 then 
        sfx(15)
      else 
        sfx(16)
      end
    end

    if btnp(5) and stamina > 25 then -- dash
      p1state = 2
      stamina -= 20
      sfx(2)
      for i=0, 3 do 
        init_particle(p1x + cos(rnd(1))* rnd_int(7), p1y  + sin(rnd(1)) * rnd_int(7), p1a - 0.5, 1 + rnd(2), 3, 7)
      end
    end

    if stamina < 100.5 then 
      stamina += 0.35
    end
  end

  if p1state <= 1 then
    move_player()
  end

  if p1state == 1 then 
    attack_player()
  elseif p1state == 2 then
    dash_player()
  elseif p1state == 3 then 
    hurt_player()
  end
  
  if p1state != 2 and p1state != 1 then
    swa = lerp(swa, 0, 0.1)
  end

  swordx = p1x + cos(p1a + 0.25 - swa) * 14
  swordy = p1y + sin(p1a + 0.25 - swa) * 14

  if (p1state == 0 or p1state == 2) and p1moved then 
    has_moved()
  end
end

function has_moved() 
  p1a = angle(p1x, p1y, p1ox, p1oy)
  move_t += p1state == 2 and 0.04 or 0.025
  feet_d = p1state != 2 and sin(move_t) * 4 or cos(move_t) * 6

  if sw_c < 4 then 
    sw_c += 1
  else
    sw_c = 0
    if(p1_sword_type ~= 1)init_particle(swordx, swordy, 0, 0, 2+rnd(1), p1_sword_type == 0 and 13 or 1)
  end
end

function attack_player()
  if move_back then
    if (swsp < 0.02)swsp+= p1_sword_type ~= 2 and 0.003 or 0.001
    if swa > -0.08 then 
      swa -=swsp
    elseif swa > -0.10 then
      swa -= swsp / 4
    else
      swsp = 0
      move_back = false
    end
  else
    if (swsp < 0.05)swsp+=0.004
    local t_angle = 0

    if p1_sword_type == 0 then --sword
      if (swhits < 7)swhits+=0.5
      t_angle = 0.5
    elseif p1_sword_type == 1 then --gun
      if (swhits < 4)swhits+=0.25
      t_angle = 0.22
    elseif p1_sword_type == 2 then -- mace
      if (swhits < 8)swhits+=0.5
      t_angle = 0.7
    end

    if swa < t_angle then
      swa += swsp
    else
      if p1_sword_type == 0 or p1_sword_type == 2 then 
        reset_attack()
      elseif p1_sword_type == 1 then -- delay shoot
        if p1_gun_delay < 4 then 
          p1_gun_delay+=1
        else
          p1_gun_delay = 0
          local shoot_a = (p1a-0.25-swa)-0.5
          init_particle(swordx, swordy, shoot_a, 2, 2+rnd(1), 13)
          init_bullet(swordx, swordy, shoot_a, 3.5, 5, 20, 14)
          sfx(13)
          reset_attack()
          p1x -= cos(shoot_a) * 2
          p1y -= sin(shoot_a) * 2
        end
      end
    end
  end
end

function reset_attack()
  swsp = 0
  swhits = 0
  p1state = 0
  move_back = true
end

function dash_player()
  if dash_counter < 36 then
    p1moved = true 
    dash_counter +=1
    p1x += cos(p1a) * 1.6
    p1y += sin(p1a) * 1.6
    if (swa > -0.1)swa-=0.05
    if (frames % 7 == 0)sfx(14) -- TODO tapping

    if dash_counter >= 36 or btnp(4) then 
      p1dx = (p1x - p1ox) * 1.5 
      p1dy = (p1y - p1oy) * 1.5
  
      dash_counter = 0 
      if btnp(4) and stamina > 15 then -- dash attack
        p1state = 1
        stamina -= 15
        sfx(1)
      else 
        p1state = 0
      end
    end
  end
end

function hurt_player()
  if hurt_counter < 12 then 
    if (hurt_counter == 0 and souls > 0)souls-=1
    hurt_counter+=1
    p1x += cos(p1ha) * p1knockback
    p1y += sin(p1ha) * p1knockback
    swa = -0.2
  else 
    p1state = 0
    hurt_counter = 0
  end
end

function player_hit(damage, angle, knockback, hit_stun)
  health -= damage
  p1knockback = knockback
  p1state = 3
  p1ha = angle
  hitstun = hit_stun

  for i=0, 3 do 
    init_particle(p1x+rnd(8)-4, p1y+rnd(8)-4, p1ha, 1 + rnd(2), 1 + rnd(3), 8)
  end

  if health <= 0 then 
    game_state = 3
    deaths += 1
    biting = true
    sfx(12)
  end
end

function move_player()
	p1dx *= (p1state >= 1 and 0.9 or 0.83)
	p1dy *= (p1state >= 1 and 0.9 or 0.83)

  local prev_dx = p1dx
  local prev_dy = p1dy
  
  if p1state == 0 then
    if btn(0) then p1dx-=p1acc end
    if btn(1) then p1dx+=p1acc end
    if btn(2) then p1dy-=p1acc end
    if btn(3) then p1dy+=p1acc end
  end

	p1x+=p1dx
	p1y+=p1dy

  if abs(p1dx) ~= abs(prev_dx) or abs(p1dy) ~= abs(prev_dy) then -- moved
    p1moved = true
  else 
    p1moved = false
  end
end

function sword_hit(x, y, rad)
  return p1state == 1 and not move_back and circ_collision(swordx, swordy, swhits, x, y, rad)
end

function draw_player_foot(offset) 
  local feetrx = p1x + cos(p1a + offset) * 3
  local feetry = p1y + sin(p1a + offset) * 3
  
  local dir = offset < 0 and 1 or -1
  circfill(feetrx + (cos(p1a) * dir) * feet_d, feetry + (sin(p1a) * dir) * feet_d, 3, 1)
end

function draw_player()
  --feetsis
  draw_player_foot(-0.25)
  draw_player_foot(0.25) 

    --sword
  local sworda = p1a-0.25-swa + sin(move_t)*0.01
  sword_sp = p1_sword_type == 0 and 8 or 40
  rspr(8 + p1_sword_type * 32 + (p1state == 1 and not move_back and 16 or 0), 0, 16, 16, sworda, swordx, swordy, 24, 24)

  -- body
  rspr(32, 32, 16, 16, p1a - swa / 3 - 0.25 + sin(move_t) * 0.05, p1x, p1y, 24, 24)

  --head
  rspr(48, 32, 16, 16, p1a - swa / 10 - 0.25 + sin(move_t) * 0.02, p1x, p1y, 24, 24)

  -- hitbox 
  --circfill(swordx, swordy, swhits, 11)

  --debug
  -- print("x: " .. p1x .. "| y:  " .. p1y, p1x - 24, p1y - 24, 8)
end

function draw_player_ui()
  fillp()
  rectfill(16, 3, 116, 5, 2)
  rectfill(16, 8, 116, 10, 2)
	fillp()
  spr(16,118,3)
  
  rectfill(16, 3, 16 + health_t, 5, 8)
  rectfill(16, 8, 16 + stamina_t, 10, 14)
  local soul_str = "".. souls
  print(soul_str, 9 - #soul_str * 2, 5, hurt_counter > 0 and 2 or 7)
end

-->8
-- draw functions

-- draw a rotated, scaled
-- sprite at dy,dy with dw,dh
-- as dimensions
--     sx,sy,sw,sh - pos,dimensions
--     in spritesheet
--     a - angle
--     dx,dy,dw,dh - pos,dimensions
--     on screen
-- serious performance issues
-- with large values of dw,dh
function rspr(sx,sy,sw,sh,a,dx,dy,dw,dh)
	sx,sy,sw,sh,a,dx,dy,dw,dh=
		sx or 0, sy or 0,
		sw or 8, sh or 8,
		a or 0,
		dx or 0, dy or 0,
		dw or 8, dh or 8
	
	local s1,c1 = sin(a+0.125),cos(a+0.125)
	local half_dw,half_dh = dw/2,dh/2
	local x1,y1 = half_dw*c1,half_dh*s1
	local x2,y2 = half_dw*s1,half_dh*-c1
	local x3,y3 = half_dw*-c1,half_dh*-s1
	local x4,y4 = half_dw*-s1,half_dh*c1

	local dx1,dy1=(x4-x1)/dh,(y4-y1)/dh
	local dx2,dy2=(x3-x2)/dh,(y3-y2)/dh
			
	local dtxx,dtxy=(x1-x2)/dw,(y1-y2)/dw

	local dsx,dsy=sw/dw,sh/dw
	for y=0,dh-1 do
		local ssx,px,py=sx,dx+x2,dy+y2
		for x=0,dw-1 do
			local col=sget(ssx,sy)
			if (col ~= 3)pset(px,py,col)
			px+=dtxx
			py+=dtxy
			ssx+=dsx
		end
		sy+=dsy
		x2+=dx2
		y2+=dy2
	end
end

-- linefill x0 y0 x1 y1 r [col]
-- draw a tick line
function linefill(ax,ay,bx,by,r,c)
	if(c) color(c)
	local dx,dy=bx-ax,by-ay

	local d=max(abs(dx),abs(dy))
	local n=min(abs(dx),abs(dy))/d
	d*=sqrt(n*n+1)
	if (d < 0.001) then 
		stop()
		return
	end
	local ca,sa=dx/d,-dy/d

	-- polygon points
	local s={{0,-r},{d,-r},{d,r},{0,r}}
	local u,v,spans=s[4][1],s[4][2],{}
	local x0,y0=ax+u*ca+v*sa,ay-u*sa+v*ca
	for i=1,4 do
		local u,v=s[i][1],s[i][2]
		local x1,y1=ax+u*ca+v*sa,ay-u*sa+v*ca
		local _x1,_y1=x1,y1
		if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
		local dx=(x1-x0)/(y1-y0)
		if(y0<0) x0-=y0*dx y0=-1
		local cy0=y0\1+1
		-- sub-pix shift
		x0+=(cy0-y0)*dx
		for y=y0\1+1,min(y1\1,540) do
			-- open span?
			local span=spans[y]
			if span then
				rectfill(x0,y,span,y)
			else
				spans[y]=x0
			end
			x0+=dx
		end
		x0,y0=_x1,_y1
	end
end

-->8
-- help

function shake_xy(x, y, value)
	local shakex=8-rnd(16)
	local shakey=8-rnd(16)
	shakex*=value
	shakey*=value
	x=shakex
	y=shakey
	value=value*0.9
	if (value < 0.04)value=0
	return x, y, value
end

function distance(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function circ_collision(x1,y1,rad1,x2,y2,rad2)
	return distance(x1,y1,x2,y2) < rad1+rad2
end

function line_collision(sx, sy, ex, ey, cx, cy)
  return abs(distance(sx, sy, cx, cy) + distance(cx, cy, ex, ey) - distance(sx, sy, ex, ey)) < 1.3 -- wing number
end

function angle(x1,y1,x2,y2)
 	return atan2(x1-x2,y1-y2)
end

function angle_lerp(angle1,angle2,t)
 angle1=angle1%1
 angle2=angle2%1

 if abs(angle1-angle2) > 0.5 then
	if angle1 > angle2 then
	 angle2+=1
	else
	 angle1+=1
	end
 end

 return ((1-t)*angle1+t*angle2)%1
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

function loopforward(value, threshold)
	return value < threshold and value + 1 or 1
end

function loopbackward(value, threshold)
	return value > 1 and value - 1 or threshold
end

function rnd_int(value)
	return flr(rnd(value)) + 1
end

function load_map(map_str)
	-- spit up first to four strings, entities, walls, pillars and props
	local type_strings = split(map_str, "|")
  
	-- split up entities seperated by :
	local entities = split(type_strings[1], ":")
	for i=1, #entities do 
		-- split up data seperated by ,
		local entity_data = split(entities[i], ",")
		init_entity(entity_data[1], entity_data[2], entity_data[3])
	end

	-- split up walls seperated by :
	local walls = split(type_strings[2], ":")
	for i=1, #walls do 
		-- split up data seperated by ,
		local wall_data = split(walls[i], ",")
		init_wall(wall_data[1], wall_data[2], wall_data[3], wall_data[4])
	end

	-- split up pillars seperated by :
	local pillars = split(type_strings[3], ":")
	for i=1, #pillars do 
		-- split up data seperated by ,
		local pillar_data = split(pillars[i], ",")
		init_pillar(pillar_data[1], pillar_data[2], pillar_data[3])
	end

		-- split up props seperated by :
	local props = split(type_strings[4], ":")
	for i=1, #props do 
		-- split up data seperated by ,
		local prop_data = split(props[i], ",")
		init_prop(prop_data[1], prop_data[2], prop_data[3])
	end
end

-->8
--particles
particles={}
function init_particle(x,y,angle,speed,rad,col)
	local p={
		x = x,
		y = y,
		angle = angle,
		speed = speed,
		rad = rad,
		col = col
	}
	add(particles,p)
end

function update_particle(p)
	p.speed*=0.9
	p.x+=p.speed*cos(p.angle)
	p.y+=p.speed*sin(p.angle)
	local speed = p.rad > 5 and 0.2 or 0.09
	p.rad -= speed
	if(p.rad <=0)del(particles,p)
end

function draw_particle(p)
	if (p.rad < 2)fillp()
	circfill(p.x,p.y,p.rad,p.col)
	fillp()
end

effects={}
function init_effect(x,y,ex,ey,spr,col,type)
	local e={
		x = x,
		y = y,
		ex = ex, 
		ey = ey,
		lx = x + 4,
		ly = y + 4,
		spr = spr,
		col = col,
		speed = (0.1 + (flr(rnd(40)) / 1000)),
		type = type,
	}
	add(effects,e)
end

function update_effect(e)
  e.x = lerp(e.x, e.ex, e.speed)
  e.y = lerp(e.y, e.ey, e.speed)

  e.lx = lerp(e.lx, e.x+4, 0.12)
  e.ly = lerp(e.ly, e.y+4, 0.12)	
  
  if distance(e.x, e.y, e.ex, e.ey) < 4 then
    if e.type == 0 then 
      souls+=1
    end
    init_particle(e.x+4+rnd(4)-2, e.y+4+rnd(4)-2, rnd(1), 1 + rnd(2), 2 + rnd(2), e.type == 0 and 0 or e.col)
    del(effects, e)
  end
end

function draw_effect(e)
	fillp()
	line(e.lx, e.ly, e.x+4, e.y+4, e.col)
	fillp()
	spr(e.spr, e.x, e.y)
end

-->8
--enemies 

enemies = {}
e_attack_dist = "20,50,40,45,18,38,25"
e_speed = "0.24,0.15,0.2,0.12,0.19,0.23,0.21"
function init_enemy(x, y, id)
 local start_speed = split(e_speed)[id]
 local e = {
   ox = x,
   x = x, 
   oy = y,
   y = y,
   id = id,
   a = 0,
   fd = 0,
   t = 0,
   st_sp = start_speed,
   sp = start_speed,
   state = 0,
   counter = 0,
   attack_dist = split(e_attack_dist)[id],
   attacking = false,
   distance = 0,
   health = id < 7 and 1 or 2,
   hurt_immune_c = 0,
 }
 add(enemies, e)
end

function update_enemy(e)
  e.ox = e.x 
  e.oy = e.y
  e.distance = distance(e.x, e.y, p1x, p1y)
  local distance = e.distance

  if (e.distance > 140)return -- dont update when out of sight
  if (e.hurt_immune_c > 0)e.hurt_immune_c -= 1

  if distance < 90 or e.state == 1 then
    e.t += 0.024
    e.fd = sin(e.t) * 4
    e.x += cos(e.a) * e.sp
    e.y += sin(e.a) * e.sp
  end

  if e.state == 0 then -- walk
    e.a = angle(p1x, p1y, e.x, e.y)
  elseif e.state == 2 then -- knock back
    e.counter += 1
    if (e.sp > e.st_sp)e.sp-=0.04
    if e.counter > 36 then 
      reset_to_move(e)
    end
  elseif e.state == 1 then -- attack
    if e.id == 1 then 
      grunt_attack_pattern(e)
    elseif e.id == 2 then 
      shooty_attack_pattern(e)
    elseif e.id == 3 then 
      dig_attack_pattern(e, distance)
    elseif e.id == 4 then 
      ghost_attack_pattern(e, distance)
    elseif e.id == 5 then 
      shield_attack_pattern(e, distance)
    elseif e.id == 6 then 
      shoot_biggy_attack_pattern(e)
    elseif e.id == 7 then 
      tank_attack_pattern(e)
    end
  end
  
  local isDigging = e.id == 3 and e.state == 1 and e.counter < 50

  if distance < 8 then
    if p1state ~= 2 then -- move back
      p1x = p1ox
      p1y = p1oy
    end

    if p1state == 2 and e.state ~= 2 then -- push back e
      e.state = 2
      sfx(3)
      hitstun = 1
      e.a = p1a
      e.counter = 0
      dash_counter = 0
      p1state = 0
      e.sp = 1.3
      for i=0, 3 do 
        init_particle(e.x, e.y, e.a + rnd(1) / 12 - rnd(1) / 24, 2 + rnd(4), 1 + rnd(4), 13)
      end
    end
  end

  local isShield = e.id == 5 and p1state == 2
  if distance < e.attack_dist and e.state == 0 and not isShield  then -- attack
    e.state = 1
  end

  local isShielding = e.id == 5 and e.state ~= 2
  if not isDigging and sword_hit(e.x, e.y, 5) then --sword destroy
    if isShielding then
      reset_attack()
      hitstun = 3
      init_particle(swordx, swordy, swa-0.5, 2 + rnd(2), 2 + rnd(3), 13)
    elseif e.health == 1 and e.hurt_immune_c == 0 then 
      destroy_enemy(e, swa)
    elseif e.hurt_immune_c == 0 then 
      hurt_enemy(e, swa)
    end
  end
end

function hurt_enemy(e, a)
  e.hurt_immune_c = 24
  e.health -= 1
  hitstun = 4
  sfx(32)
  swsp*=0.4
  for i=0, 3 do 
    init_particle(e.x, e.y, a - rnd(1) / 12, 2 + rnd(3), 1 + rnd(4), 2)
  end
end

function destroy_enemy(e, a)
  del(enemies, e)
  hitstun = 6
  sfx(34 + flr(rnd(2)))
  local screenX = e.x - camerax + 64
  local screenY = e.y - cameray + 64
  init_effect(screenX + rnd(8)-4, screenY + rnd(8)-4, 8, 8, 14, 6, 0)
  for i=0, 5 do 
    init_particle(e.x, e.y, a - rnd(1) / 12, 2 + rnd(3), 1 + rnd(4), 2)
  end
end

function reset_to_move(e)
  e.a = angle(p1x, p1y, e.x, e.y)
  e.counter = 0
  e.state = 0
  e.sp = e.st_sp
  e.attacking = false
end

function move_enemies_away(p, op)
  if p ~= op and distance(p.x, p.y, op.x, op.y) < 12 then 
    local a = angle(p.x, p.y, op.x, op.y)
    p.x += cos(a)
    p.y += sin(a)
  end
end

function draw_enemy_foot(e, offset)
  local footx = e.x + cos(e.a + offset) * 3
  local footy = e.y + sin(e.a + offset) * 3
  local dir = offset > 0 and -1 or 1
  circfill(footx + cos(e.a) * offset * e.fd, footy + sin(e.a) * offset * e.fd, 3, 1)
end

function draw_enemy_feet(e)
  if (e.distance > 130)return
  if e.id == 4 and e.state == 1 and e.counter > 8 and e.counter < 8.01 then
    fillp()
    circ(p1x, p1y, e.attack_dist, 2)
    fillp()
  elseif e.id == 1 or e.id == 5 or e.id == 7 then 
    draw_enemy_foot(e, -0.25)
    draw_enemy_foot(e, 0.25)
  elseif e.id == 6 and e.state == 1 and e.counter <= 9 then 
    circ(e.x, e.y, e.attack_dist, 2)
  end 
end

function draw_enemy(e)
  if (e.distance > 130)return
  
  if e.id ~= 3 or not (e.state == 1 and e.counter < 30) then
    spr(30 + 2 * e.id, e.x-8, e.y-8, 2, 2) -- body
    spr(e.attacking and 29 or 13, e.x - 3 + cos(e.a)*2, e.y - 3 + sin(e.a) * 2) -- eye
  end

  if e.id == 2 and e.state == 1 and e.counter < 11 then -- charge
    circ(e.x, e.y, e.counter * 0.8, 7)
  elseif e.id == 5 and e.state ~= 2 then -- shield
    fillp(™)
    local sx = e.x + cos(e.a) * 8
    local sy = e.y + sin(e.a) * 8
    line(sx + cos(e.a-0.25)*8, sy + sin(e.a-0.25)*8,sx + cos(e.a+0.25)*8, sy + sin(e.a+0.25)*8, 13)
    fillp()
  end
  -- print(e.id, e.x, e.y - 8, 7)
end

function shooty_attack_pattern(e)
  e.counter+=1
  e.attacking = e.counter > 8 and e.counter < 16
  if e.counter < 12 then
    e.sp = 0
    if e.counter == 11 then
      sfx(7)
      init_bullet(e.x, e.y, e.a, 2, 4, 40, 7)
      e.x += cos(-e.a) * 2
      e.y += sin(-e.a) * 2 
    end
  elseif e.counter < 90 then 
    e.sp = 0
  else 
    reset_to_move(e)
  end
end

function shoot_biggy_attack_pattern(e)
  e.counter+=1
  e.attacking = e.counter > 10 and e.counter < 22

  if e.counter < 11 then
    e.sp = 0.05
    if e.counter == 10 then 
      init_bullet(e.x, e.y, e.a - rnd(i) / 10, 3, 7, 16, 7)
      e.x += cos(-e.a) * 4
      e.y += sin(-e.a) * 4 
    end
  elseif e.counter < 85 then 
    e.sp = 0
  else 
    reset_to_move(e)
  end
end

function grunt_attack_pattern(e)
  e.counter+=1
  e.attacking = e.counter >= 30 and e.counter < 50 and e.state == 1
  if e.counter < 30 then 
    e.a = angle(e.x, e.y, p1x, p1y)
    e.sp = 0.12
    if e.counter == 29 then
      init_particle(e.x, e.y, e.a, 1 + rnd(2), 3, 6)
      sfx(20)
    end
  elseif e.counter < 50 then
    e.a = angle(p1x, p1y, e.x, e.y)
    e.sp = 1
    if (tackle_player(e))e.counter = 51
  elseif e.counter < 90 then 
    e.sp = 0.1
  else
    reset_to_move(e)
  end
end


function tank_attack_pattern(e)
  e.counter+=1
  e.attacking = e.counter >= 30 and e.counter < 50 and e.state == 1
  if e.counter < 24 then 
    e.a = angle(e.x, e.y, p1x, p1y)
    e.sp = 0.12
    if e.counter == 23 then
      init_particle(e.x, e.y, e.a, 1 + rnd(2), 3, 6)
      sfx(20)
    end
  elseif e.counter < 40 then
    e.a = angle(p1x, p1y, e.x, e.y)
    e.sp = 1
    if (tackle_player(e))e.counter = 51
  elseif e.counter < 70 then 
    e.sp = 0.1
  else
    reset_to_move(e)
  end
end

function dig_attack_pattern(e, dist)
  e.counter += 1
  e.attacking = e.counter >= 36 and e.counter < 44

  if e.counter < 30 then
    if (e.sp < 4)e.sp+=0.11
    if (dist < 16)e.counter = 30
    if e.counter % 3 == 0 then 
      init_particle(e.x+rnd(8)-4, e.y+rnd(8)-4, 0, 0, 2 + rnd(3), 8)
      sfx(10)
    end
  elseif e.counter < 118 then
    e.sp = 0
    if e.counter == 36 then 
      for i=0, 5 do
        init_particle(e.x, e.y, 1 * (i / 6) - 0.1, 2, 5, 1)
        init_particle(e.x, e.y, 1 * (i / 6), 3, 5, 14)
      end
      sfx(9)
    end
    

    if p1state ~= 3 and p1state ~= 2 and e.counter > 36 and e.counter < 50 and circ_collision(e.x, e.y, 24, p1x, p1y, 5) then 
      player_hit(35, angle(p1x, p1y, e.x, e.y), 2, 2)

      for i=0, 5 do 
        init_particle(e.x+rnd(8)-4, e.y+rnd(8)-4, p1ha, 1 + rnd(2), 1 + rnd(3), 8)
      end
    end
  else
    reset_to_move(e)
  end
end

function ghost_attack_pattern(e, dist)
  e.attacking = e.counter > 8.01 and e.counter < 40

  if e.counter < 8 then
    e.counter +=1

    if (e.counter == 8)e.attack_dist = dist
  elseif e.counter < 8.01 then
    e.counter += 0.00005
    e.a = angle(e.x, e.y, p1x, p1y)
    e.x = p1x + cos(e.a + e.counter) * e.attack_dist
    e.y = p1y + sin(e.a + e.counter) * e.attack_dist
    e.sp = 0.1
    
    if p1state == 2 then 
      e.attack_dist -= 0.3
    end
  elseif e.counter < 40 then
    e.counter += 1
    if (e.sp < 1.1)e.sp+=0.1
    e.a = angle(p1x, p1y, e.x, e.y)
    if (tackle_player(e))e.counter = 41
  elseif e.counter < 150 then 
    e.counter += 1
    e.sp *= 0.97
    e.a = angle(e.x, e.y, p1x, p1y)
  else 
    reset_to_move(e)
    e.attack_dist = 45
  end
end

function is_ghost(e)
  return e.id == 4
end

function tackle_player(e)
  if p1state ~= 3 and circ_collision(e.x, e.y, 5, p1x, p1y, 5) then 
    player_hit(25, e.a, 1.5, 1)
    sfx(17)

    return true
  end

  return false
end

function shield_attack_pattern(e)
  e.attacking = e.counter > 0.01 and e.counter < 30
  e.counter += 1
  if e.counter < 14 then 
    e.sp +=0.1
    if (tackle_player(e))e.counter = 14
  elseif e.counter < 40 then
    e.sp = 0.01
  else 
    reset_to_move(e)
  end
end

bullets={}
function init_bullet(x,y,a,sp,rad,dur,c)
  local b={
    x=x,
    y=y,
    a=a,
    sp=sp,
    r=rad,
    dur=dur,
    invis=4,
    c=c
  }
  add(bullets, b)
end

function update_bullet(b)
  if (b.invis > 0)b.invis-=1
  if b.dur > 0 then 
    b.dur-=1
    b.x += cos(b.a) * b.sp
    b.y += sin(b.a) * b.sp
  else
    init_particle(b.x+rnd(8)-4, b.y+rnd(8)-4, 0, 0, 1 + rnd(3), b.c)
    del(bullets, b)
  end

  if p1state ~= 3 and b.c == 7 and circ_collision(b.x, b.y, b.r, p1x, p1y, 5) then 
    player_hit(min(b.r * 6, 40), b.a, b.r > 10 and 4 or 2, b.r > 10 and 5 or 2)
    b.dur = 0
    sfx(b.r > 12 and 31 or 19) 
  end
  
  if b.c ~= 14 and sword_hit(b.x, b.y, b.r) then
    b.a = angle(b.x, b.y, p1x, p1y)
    b.c = 14
    hitstun = 3
    b.sp *= 1.5
    b.dur += 30
    sfx(8)
  elseif b.c == 14 then -- bounce back
    for e in all(enemies) do 
      if circ_collision(e.x, e.y, 5, b.x, b.y, b.r) then 
        b.dur = 0
        local isShielding = e.id == 5 and e.state ~= 2
        if e.health == 1 and not isShielding then 
         destroy_enemy(e, b.a)
        else 
          init_particle(b.x+rnd(8)-4, b.y+rnd(8)-4, b.a-0.5, 2, 1 + rnd(3), b.c)
        end
      end
    end
  end
end

function draw_bullet(b)
  circfill(b.x, b.y, b.r, b.c)
end

boss_health = 0
function init_boss(x,y)
  boss_x = x 
  boss_y = y
  boss_health = 16
  boss_sp = 0.5
  boss_rad = 24
  boss_tail_rad = 12
  boss_a = 0
  boss_hurt_c = 0
  boss_state = 0
  boss_bite_c = 0
  boss_state_c = 0
  boss_turn_speed = 0.01
end

function update_boss()
  local player_distance = distance(p1x, p1y, boss_x, boss_y)

  if boss_state == 0 then -- normal state
    local boss_turn_speed = player_distance < 40 and 0.005 or 0.01
    if (boss_sp < 0.5)boss_sp+=0.01
    if boss_state_c < 360 then 
      boss_state_c += 1
    else
      boss_state_c = 0
      local random_attack = rnd(1)
      boss_state = random_attack < 0.5 and 1 or 3
    end
  elseif boss_state == 1 then --rush attack
    if boss_state_c < 240 then 
      boss_state_c+=1
      if (boss_sp < 0.9)boss_sp+=0.02
      if (frames % 3 == 0)sfx(27)
      boss_turn_speed = lerp(boss_turn_speed, 0.08, 0.01)
    else
      boss_state = 2 
      boss_state_c = 0
      boss_bite_c = 12
      sfx(26)
      for i=0, 4 do
        init_particle(boss_x + cos(boss_a) * 40, boss_y + sin(boss_a) * 40, rnd(1), 3 + rnd(1), 12 + rnd(6), 6 + rnd(2))
      end
    end
  elseif boss_state == 2 then -- stand still
    boss_turn_speed = lerp(boss_turn_speed, 0.01, 0.005)
    if boss_state_c < 180 then 
      boss_state_c += 1
      if (boss_sp > 0.3)boss_sp-=0.02
    else
      boss_state_c = 0
      boss_state = 0
      boss_sp = 0.5
      boss_turn_speed = 0.01
    end
  elseif boss_state == 3 then -- shoot
    if boss_turn_speed < 0.95 then
      boss_turn_speed +=0.015
      if (boss_sp > 0.05)boss_sp-=0.05
      if (frames % 4 == 0)sfx(28)
    else
      sfx(29)
      init_bullet(boss_x + cos(boss_a) * 16, boss_y + sin(boss_a) * 16, boss_a, 3.5, 13, 60, 7)
      for i=0, 4 do
        init_particle(boss_x + cos(boss_a) * 16, boss_y + sin(boss_a) * 16, boss_a + rnd(1) / 20 - rnd(1) / 20, 4 + rnd(2), 3 + rnd(5), 7)
      end
      boss_x += cos(boss_a-0.5) * 6
      boss_y += sin(boss_a-0.5) * 6
      boss_state = 2
      boss_sp = 0.4
      boss_state_c = 0
    end
  end

  if (boss_hurt_c > 0)boss_hurt_c -= 1

  boss_a = angle_lerp(boss_a, angle(p1x, p1y, boss_x, boss_y), boss_turn_speed)

  boss_x += cos(boss_a) * boss_sp
  boss_y += sin(boss_a) * boss_sp

  boss_tail_x = boss_x + cos(boss_a-0.5) * 32
  boss_tail_y = boss_y + sin(boss_a-0.5) * 32

  if frames % 10 == 0 then 
    init_particle(boss_tail_x,boss_tail_y, 0, 0, boss_tail_rad+1, boss_state == 1 and 12 or 1)
  end

  if boss_bite_c > 0 then 
    boss_bite_c -=1
    if p1knockback ~= 7 and circ_collision(boss_x + cos(boss_a) * 40, boss_y + sin(boss_a) * 40, 24, p1x, p1y, 4) then 
      player_hit(40, boss_a, 7, 6)
      boss_sp *=0.75
    end 
  end

  if boss_hurt_c == 0 then
    if sword_hit(boss_tail_x, boss_tail_y, boss_tail_rad) then 
      hit_boss(2, boss_tail_x, boss_tail_y)
      sfx(23)
    elseif sword_hit(boss_x, boss_y, boss_rad) then 
      hit_boss(1, boss_x, boss_y)
      sfx(22)
    end
  end

  for b in all(bullets) do 
    if b.c == 14 then 
      if circ_collision(boss_tail_x, boss_tail_y, boss_tail_rad, b.x, b.y, b.r) then -- tail
        hit_boss(b.r > 12 and 4 or 1, boss_tail_x, boss_tail_y)
        b.dur = 0
        sfx(24)
      end
      if b.dur > 0 and circ_collision(boss_x, boss_y, boss_rad, b.x, b.y, b.r) then
        hit_boss(b.r > 12 and 4 or 1, boss_x, boss_y)
        b.dur = 0
        sfx(24)
      end
    end
  end

  if p1state ~= 3 and circ_collision(boss_x, boss_y, boss_rad, p1x, p1y, 4) then 
    player_hit(boss_state == 1 and 10 or 5, p1a - boss_a, 2.5, 2)
    boss_sp *=0.75
    sfx(25)

    return true
  end
end

function hit_boss(damage, hitx, hity)
  boss_health -= damage
  boss_hurt_c = 12
  hitstun = 6
  local h_angle = angle(p1x, p1y, hitx, hity)
  if boss_health <= 0 then
    --boss dead
    for i=0,8 do
      init_particle(hitx, hity, i / 8, 6, 12, 12 + (i % 2 == 0 and 1 or 0))
    end
    sfx(30)
    if game_won_c == 0 then
      game_won_c = 90
      if game_won ~= 1 then
        weapon_select_unlocked = true
        game_won = 1
        dset(0, game_won)
        add_switch_weapon_option()
      end
    end 
  end
  for i=0,3 do
    init_particle(hitx, hity, h_angle-0.1 + i*0.05, 3 + rnd(1), 8, 12)
  end
end

function draw_boss()
  draw_boss_wing(0.25, 1, 0)
  draw_boss_wing(-0.25, -1, 16)

  circfill(boss_tail_x, boss_tail_y, boss_tail_rad, 13)
  circfill(boss_tail_x, boss_tail_y, 8 + sin(t)*2.2, 12)
  circfill(boss_x, boss_y, boss_rad, 13)

  -- boss bite
  if (boss_bite_c > 0)circ(boss_x + cos(boss_a) * 40, boss_y + sin(boss_a) * 40, 24, 12)
  if (boss_state == 1 and boss_state_c > 220)circ(boss_x + cos(boss_a) * 40, boss_y + sin(boss_a) * 40, boss_state_c - 220, 13)

  circfill(boss_x + cos(boss_a) * 16, boss_y + sin(boss_a) * 16, 10, 7)

  draw_boss_eye(10, 7)
  draw_boss_eye(boss_hurt_c == 0 and 8 or 5, 1)

  if (boss_state == 3)circfill(boss_x + cos(boss_a) * 16, boss_y + sin(boss_a) * 16, 10 * boss_turn_speed, 7)
end

function draw_boss_eye(size, color)
  circfill(boss_x + cos(boss_a) * 16, boss_y + sin(boss_a) * 16, size, color)
end

function draw_boss_wing(offset, flap_dir, sprX)
  local wing_x = boss_x + cos(boss_a - offset) * (boss_rad + 4)
  local wing_y = boss_y + sin(boss_a - offset) * (boss_rad + 4)
  local flap = flap_dir * abs(sin(t / (boss_state == 1 and 1 or 2) ) * 0.15)
  rspr(sprX, 32, 16, 16, boss_a + flap, wing_x, wing_y, 24, 24)
end

function draw_boss_ui()
  fillp()
  rectfill(4, 120, 122, 122, 2)
	fillp()
  rectfill(4, 120, 4 + 118 * boss_health / 16, 122, 6)
end

-->8
--camera

function update_camera()
  if p1state == 2 then 
    camera_dash = 1
  elseif camera_dash == 1 then 
    camera_dash = 2
  end

  if boss_health > 0 then 
    targetx = lerp(p1x, boss_x, 0.3)
    targety = lerp(p1y, boss_y, 0.3) 
  else 
    targetx = p1state == 2 and p1x + cos(p1a) * 40 or p1x + cos(p1a) * 24
    targety = p1state == 2 and p1y + sin(p1a) * 40 or p1y + sin(p1a) * 24
  end

	if distance(camerax, cameray, targetx, targety) > camerasize  then 
		 center_camera = true
	end

  if p1state == 2 then 
    camerax = lerp(camerax, targetx, 0.05)
		cameray = lerp(cameray, targety, 0.05)
	elseif camera_dash == 2 then 
    if distance(targetx, targety, camerax, cameray) > 4 then 
			camerax = lerp(camerax, targetx, 0.06)
			cameray = lerp(cameray, targety, 0.06)
		else
			camera_dash = 0
		end
  elseif center_camera then
		if distance(targetx, targety, camerax, cameray) > 20 then 
			camerax = lerp(camerax, targetx, 0.03)
			cameray = lerp(cameray, targety, 0.03)
		else
			center_camera = false
		end
  end
end

function draw_camera()
	--circ(camerax, cameray, camerasize, 7)
	--local dist = distance(targetx, targety, camerax, cameray)
	--print(dist, camerax - 12, cameray)
  --print(camera_dash, camerax - 24, cameray, 10)
  --circ(targetx, targety, 6, 9)
end

-->8
-- level editor items

function init_entity(x,y,id) 
	if id == 0 then 
    p1x = x
    p1y = y
    camerax = p1x 
    cameray = p1y
  elseif id < 8 then
    init_enemy(x, y, id)
  elseif id == 8 then 
    init_boss(x, y)
  end
end

function draw_sprite(s)
	spr(s.spr, s.x, s.y)
end

walls={}
function init_wall(sx, sy, ex, ey) 
	local f={
		sx = sx,
		sy = sy,
		ex = ex,
		ey = ey,
		dist = distance(sx, sy, ex, ey)
	}
	add(walls, f)
end

function update_wall(w)
  if line_collision(w.sx, w.sy, w.ex, w.ey, p1x, p1y) then 
    p1x = p1ox 
    p1y = p1oy
  end
  if p1state == 1 and swhits > 3.5 and not move_back and line_collision(w.sx, w.sy, w.ex, w.ey, swordx, swordy) then 
    hitstun = 1
    reset_attack()
    sfx(18)
  end

  for e in all(enemies) do
    if e.distance < 140 and not is_ghost(e) and line_collision(w.sx, w.sy, w.ex, w.ey, e.x, e.y) then 
      e.x = e.ox
      e.y = e.oy
    end
  end
end

function draw_wall(w)
	linefill(w.sx, w.sy, w.ex, w.ey, 4, 1)
end

pillars={}
function init_pillar(x, y, rad) 
	local f={
		x = x,
		y = y,
		r = rad,
	}
	add(pillars, f)
end

function update_pillar(p)
  if circ_collision(p.x, p.y, p.r, p1x, p1y, 5) then 
    p1x = p1ox 
    p1y = p1oy
  end
  if p1state == 1 and not move_back and circ_collision(swordx, swordy, swhits, p.x, p.y, 5) then 
    hitstun = 1
    reset_attack()
    sfx(18)
  end

  for e in all(enemies) do
    if e.distance < 140 and not is_ghost(e) and circ_collision(p.x, p.y, p.r, e.x, e.y, 5) then 
      e.x = e.ox 
      e.y = e.oy
    end
  end
  for b in all(bullets) do 
    if b.invis == 0 and circ_collision(p.x, p.y, p.r, b.x, b.y, b.r) then 
      b.dur = 0
    end
  end
end

function draw_pillar(p)
  circfill(p.x, p.y, p.r, 1)
	circfill(p.x, p.y, p.r-3, 13)
end

props={}
function init_prop(x,y,id)
  local p={
    x=x, 
    y=y,
    id=id,
    spr=96+id*2,
    r=8,
    t=0
  }
  add(props, p)
end

function draw_prop(p)
 spr(p.spr, p.x, p.y, 2, 2)
end
__gfx__
88888888333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333ee3333337733
8888888833333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333ee33333377333
887887883333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333eeee3333777733
888778883333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333ee00ee33eeeeee337777773
8887788833333331dd333333333337777733333333333333333311333333333331333aaa333333333333333335353533333333333ee00ee33eeeeee337777773
8878878833333331dd77333333777777777733333333333333355512333333331313aaaa333333353333333333555333333333333eeeeee33eeeeee337777773
88888888333333315d772a333377777777772a333333333333655514333333555522aaa33333336553333333356655333333333333eeee3333eeee3337777773
888888883333333355552aaa3755555555552aaa333333333335551233333555552aaa33333335555155524456555515555552ff333333333333333333777733
a3333aa333333333333531a175555555555531a133333333333311333336666665aa33333333335553333333565555155555524433333333337777333eeeeee3
aa33aa333333333333333333555533333333333333333333333333333333333335333333333333353333333335555533333333333333333337777773ee3333ee
aa3aaa333333333333333333333333333333333333333333333333333333333333333333333333333333333333555333333333333377773337377373e33e333e
aaaaa3333333333333333333333333333333333333333333333333333333333333333333333333333333333335353533333333333777777337377373e33e333e
aaaaa3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333770077337777773e33eee3e
aaaa33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333377773333777733e333333e
aaaa33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777733ee3333ee
aaa3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333eeeeee3
3333888888883333333333322333333333833333333338333333333333333333333333333333333333333388883333333333838888383333dddddddd00000000
3388888888888833333333222233333338333888888333833333888888883333338838833883883333333338833333333333388888833333dddddddd00000000
33888888888888333333333223333333328888888888882333388888888883333388388338838833333333388333333333333388883333333dddddd300000000
33322888888223333333333223333333332888888888823333888888888888333388888888888833333338888883333333332888888233333dddddd300000000
33333288882333333333322222233333333288888888233333888888888888333388888888888833333388888888333333333288882333333dddddd300000000
3333888888883333333388288288333333282888888282333388888888888833332888888888823333338888888833333338888888888333333dd33300000000
3338888888888333833882888828833833888222222888333332888888882333333888888888833338338888888833833388888888888833333dd33300000000
338888888888883383888888888888383388888888888833333288888888233333388888888883338888888888888888388888888888888333dddd3300000000
33888888888888338888888888888888332888888888823333888888888888333388888888888833888828888882888888888888888888880000000000000000
33888888888888338888888888888888332288888888223333888888888888333338888888888333323332888823332382888888888888280000000000000000
33888888888888333888888888888883333322222222333333888888888888333328888888888233333388888888333388288888888882880000000000000000
33288888888882332388888888888832332222233222233333882882288288333332888888882333333388888888333338822222222228830000000000000000
33322888888223333338888888888333322223333332222333382883388383333333222222223333333328888882333333888888888888330000000000000000
33333333333333333333888888883333333233333333233333338332233833333333333333333333333332233223333333333333333333330000000000000000
33333333333333333333322332233333333333333333333333333333233333333333333333333333333333333333333333333333333333330000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000000000000
333333333ddddddddddd333333333333333333333333333333333333333333330000000000000000888333333333333383883833000000000000000000000000
333333333ddddddd3dddddd33333333333333333333333333333333e333333330000000000000000388833333833338338888333000000000000000000000000
3333333ddddddddddd3ddddd333333333333333333333333333333eee33333330000000000000000388883333888888838888333000000000000000000000000
333333dddddddddd33ddddddd33333333333333333333333333333eee33333330000000000000000338883338883833383883833000000000000000000000000
3333333dddddddd33ddddddddd333333333333333333333333333aeeea3333330000000000000000338883338888333333883333000000000000000000000000
333dddddddddddd33333ddddddd3333332222222222255533333eeeeeee333330000000000000000338883338883333333883333000000000000000000000000
333333ddddddddd33dddddddddddd3332222222222225655333322eee22333330000000000000000333833338833333333883333000000000000000000000000
33333ddddddddd33333ddddddddddd332e222222222225653333eeeeeee333330000000000000000333833333333333333883333000000000000000000000000
333ddddddddddd3333333ddddddddd332e222222222225653333eeeeeee333330000000000000000000000000000000000000000000000000000000000000000
3dddddddddddd333333333ddddddddd32222222222222255333eeeeeeeee33330000000000000000000000000000000000000000000000000000000000000000
3333ddddddd33333333dddddddddddd3322222222222222333eeeeeeeeeee3330000000000000000000000000000000000000000000000000000000000000000
3ddddddddd3333333333333dddddddd333222222222222333eee3eeeee3eee330000000000000000000000000000000000000000000000000000000000000000
33ddddddd3333333333333dddddddddd3333222222223333333333eee33333330000000000000000000000000000000000000000000000000000000000000000
dd3ddddd333333333333333ddddddddd3333ffffffff333333333333333333330000000000000000000000000000000000000000000000000000000000000000
3dddddd333333333333333333ddddddd3333f444444f333333333333333333330000000000000000000000000000000000000000000000000000000000000000
dddd333333333333333333333ddddddd33333ffffff3333333333333333333330000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333111111111111333311111111131133333333333333333333333333333333333113331111333113
33333333331133333333331113133133333333111113313331333333333333133133333333333313333323333333233333332333333323333113333333333113
33313311331113333311333333333113331133131133311331331111111133133133333311113313332322323333333333332233233333333333311111133333
33311313333311333311333333333333331113111113333331311111111113133131331111111313333322223232333333333332223233333333331111333333
33333333333333333333331133133333331333113133333331311111111113133131111113111313333332233232333333333333233333333331333333331333
33133333313333333333131133113133331313333331313331311111111113133131111133111313323332232223333332333333333333333131131331311313
33113333311333333333133131133133333313333113313331311111111113133331111111111333333222222223333333333233333333333131133333311313
33333333333311333333331133333333333333113331133331311111111113133131131111111313323222222222323332332223333232333131133113311313
33333333333331333331333333333113333133113333111331311111111113133131111111133313333332222223323333333233322333333131133113311333
33331131131333333331333113333133333111111333313331311111111113133131331111333313333232222233333333323333323333333331333333331333
33133133333333333311133113333333331111113311333331311111111113133131333111131313333322322223333333333332332333333333331111333333
33133333333313333333331133113333333333133311113331331111111133133133133111133313333223333322333333333333333333333333311111133333
33333313333333333333331333113333333333333111133331333333333333133133333333333313333333223322333333333323333333333113333333333113
33333333333333333333313333311333333333333333333333111111111111333311111111113133323333233333333333333333333333333113331111333113
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333eee333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333333e2ee33ee33333eee3333333311111111333111111111333111111113333332233333332233333311111113333113333311333111111113333333333
333333333e222eeeeee33ee2333333331dddddddd131ddddddddd131dddddddd13333200233333200233331ddddddd1331dd13331dd131dddddddd1333333333
3333333333e2eeeeeeeeee2e333333331dddddddd131ddddddddd131dddddddd1333320023333320023331ddddddddd131dd13331dd131dddddddd1333333333
3333333333ee222eeeeeee23333333331dd111111331dd1111111331dd11111dd133320023333320023331dd11111dd131dd13331dd131dd11111dd133333333
33333333333e7a7eee222ee3333333331dd133333331dd1333333331dd13331dd133320023333320023331dd13331dd131dd13331dd131dd13331dd133333333
33333333333e000eee7a7e33333333331dd111113331dd1111113331dd11111dd133320023333320023331dd13331dd131dd13331dd131dd11111dd133333333
333333333333eeeeee000e33333333331ddddddd1331dddddddd1331ddddddddd133320023333320023331dd13331dd131dd13331dd131ddddddddd133333333
333333333333eeeeeeeeee33333333331ddddddd1331dddddddd1331dddddddd1333320022333220023331dd13331dd131dd13331dd131dddddddd1333333333
333333333333eeeeeeeeee33333333331dd111113331dd1111113331dd11111dd133332000222000233331dd13331dd131dd13331dd131dd11111dd133333333
333333333333eeeeeeeee333333333331dd133333331dd1333333331dd13331dd133333200000002333331dd13331dd131dd13331dd131dd13331dd133333333
3333333333333eeeeeeaa333333333331dd133333331dd1333333331dd13331dd133333200000002333331dd13331dd131dd13331dd131dd13331dd133333333
3333333335555eeeee011123333333331dd133333331dd1111111331dd13331dd133333200000002333331dd11111dd131dd11111dd131dd13331dd133333333
3333333357655eeee0112222233333331dd133333331ddddddddd131dd13331dd133333320000023333331ddddddddd1331ddddddd1331dd13331dd133333333
3333333566555eee01112222a13333331dd133333331ddddddddd131dd13331dd1333333320002333333331ddddddd13331ddddddd1331dd13331dd133333333
33333357655511ee1112222a22a33333311333333333111111111333113333311333333333222333333333311111113333311111113333113333311333333333
33333566555122e11e1222222223333333dddd3333dddd3322233333333333333333333333333333333773333333333333333333333333333333333333333333
333356665501211ee1222222222233333dbbbbd33d0000d322223333333333333333333333333333337777333333333333333333333133333333333333333333
333356655512222112222a2222223333dbb77bbdd005500d222eee33333333333333333333333333377777733333333333333333333133333333333333333333
33335555551222212222222222a22333db7bb7bdd050050d32eeeee3333333333333333333333333777777773333333333333333331113333333333333333333
3333556550222a2212aa222222223333db7bb7bdd050050d3eeeeee3a33333333333333333333333777777773333333333333333331113333333333333333333
333355550122222122a2a22222003333dbb77bbdd005500d33eeeeaa333333333333333333333333333773333333333333333333331111333333333333333333
333352555222a22222222222203333333dbbbbd33d0000d3333aaa55333333333333333333333333333333333333333333333333331111333333333333333333
3333225522222222222222020333333333dddd3333dddd3333aaddd5333333333333333333333333333333333333333333333333331111133333333333333333
333332522202a222222121223333333333dddd3333dddd333a377ddd533333333333333333377333333333333337733333333333311111113333333333333333
333332222202222220222122333333333d8888d33d2222d3333777d5553333333333333333777333333333333337773333333333311111113333333333333333
33333232222223222232223233333333d878878dd252252d333377d5553333333333333337777333333773333337777333333333311111111333333333333333
33333233323223322332223333333333d887788dd225522d3333777d555333333333333377777733777777773377777733333333311111111133333333333333
33333332323233322333323233333333d887788dd225522d3333777d555533333333333377777733777777773377777733333333111111111133333333333333
33332333323233322323323333333333d878878dd252252d33333777d55553333333333337777333377777733337777333333333111111111113333333333333
333333333333333333333333333333333d8888d33d2222d333333377755555333333333333777333337777333337773333333333111111111113333333333333
3333333333332333333333233333333333dddd3333dddd33333333377d5555533333333333377333333773333337733333333333111111111111333333333333
33333333333333333333333333333333333333333333333333333337777d55553333333300000000000000000000000033333311111111111111111133333333
33388888833333388888833338833333388338888888888333333333777755553333333300000000000000000000000033333331111111111111111333333333
33388888833333388888833338833333388338888888888333333333377775555333333300000000000000000000000033333311111111111111113333333333
38833333388338833333388338888338888338833333333333333333333777d55333333300000000000000000000000033333111111111111111111333333333
38833333388338833333388338888338888338833333333333333333333377775533333500000000000000000000000033331111111111111111111333333333
3883333333333883333338833883388338833883333333333333333333333777d555555700000000000000000000000033331111111111111111111133333333
38833333333338833333388338833883388338833333333333333333333333377777777300000000000000000000000033311111111111111111111113333333
38833888888338833333388338833333388338888888833333333333333333333777773300000000000000000000000033311111111111111111111113333333
38833888888338833333388338833333388338888888833333333333333333333333333333333333333333330000000033333111111111111111111333333333
38833333388338888888888338833333388338833333333333333333333333333333333333333333333333330000000033333111111111111111111333333333
38833333388338888888888338833333388338833333333333333333333333333333333333333333333333330000000033331111111111111111111133333333
38833333388338833333388338833333388338833333333333333333333333333333333333333333333333330000000033331111111111111111111133333333
38833333388338833333388338833333388338833333333333333333333333333333333333333333333333330000000033311111111111111111111113333333
33388888833338833333388338833333388338888888888333333333333333333333333333333333333333330000000033311111111111111111111113333333
33388888833338833333388338833333388338888888888333333333333333333333333333333333333333330000000033111111111111111111111111133333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000031111111111111111111111111113333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000033331111111111111111111111133333
333ee333333ee3333eeeeee3333ee333333ee3333883333333333338888883333338888883333888888888830000000033311111111111111111111111113333
333ee333333ee3333eeeeee3333ee333333ee3333883333333333338888883333338888883333888888888830000000033311111111111111111111111133333
333ee333333ee33ee333333ee33ee333333ee3333883333333333883333338833883333338833333388333330000000033311111111111111111111111133333
333ee333333ee33ee333333ee33ee333333ee3333883333333333883333338833883333338833333388333330000000033111111111111111111111111113333
333ee333333ee33ee333333ee33eeee3333ee3333883333333333883333338833883333333333333388333330000000033111111111111111111111111113333
333ee333333ee33ee333333ee33eeee3333ee3333883333333333883333338833883333333333333388333330000000031111111111111111111111111113333
333ee333333ee33ee333333ee33ee33ee33ee3333883333333333883333338833338888883333333388333330000000031111111111111111111111111111333
333ee333333ee33ee333333ee33ee33ee33ee3333883333333333883333338833338888883333333388333330000000000000000000000000000000000000000
333ee33ee33ee33ee333333ee33ee3333eeee3333883333333333883333338833333333338833333388333330000000000000000000000000000000000000000
333ee33ee33ee33ee333333ee33ee3333eeee3333883333333333883333338833333333338833333388333330000000000000000000000000000000000000000
333eeee33eeee33ee333333ee33ee333333ee3333883333333333883333338833883333338833333388333330000000000000000000000000000000000000000
333eeee33eeee33ee333333ee33ee333333ee3333883333333333883333338833883333338833333388333330000000000000000000000000000000000000000
333ee333333ee3333eeeeee3333ee333333ee3333888888888833338888883333338888883333333388333330000000000000000000000000000000000000000
333ee333333ee3333eeeeee3333ee333333ee3333888888888833338888883333338888883333333388333330000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000060240503406034090440c0440e0540f05412054130541405408054060540605405054050540505401034010340003400004000040000400004000040000400004000040000400004000040000400004
00020000060240503406034090440c0440e0540f054120541305414054180641a0540605405054050540505401034010340003400004000040000400004000040000400004000040000400004000040000400004
00020000040240503407034070440b0440b0540d054150540c0640803408024060040600405004050040500401004010040000400004000040000400004000040000400004000040000400004000040000400004
000200000364207052050520305216022010720100200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000366207052056320303216052010520a05204052010520000204052000020003200002000020000200002020020000200002000020000200002000020000200002000020000200002000020000200002
0001000000023030730e0330f0131401306003060031f003010030000304003000030000300003000030000300003020030000300003000030000300003000030000300003000030000300003000030000300003
0001000000031036410a0311101108011060010600116001010010000104001000010000100001000010000100001020010000100001000010000100001000010000100001000010000100001000010000100001
0003000002622046320a03206132136520c0520a05203042050320013204122001020013200102001020010200102021020010200102001020010200102001020010200102001020010200102001020010200102
0003000000022046020a00206102136020c0020a00203002050020010204102001020010200102001020010200102021020010200102001020010200102001020010200102001020010200102001020010200102
0010000005064160441b0040100400004030040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004
0010000002621180410c05103051000010003100001000010c0310702100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000400000364315053050530005300033000030100300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000400000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000060240503406034090440c0440e0540f054120540e0540c05408054060540304401034050040500401004010040000400004000040000400004000040000400004000040000400004000040000400004
000300000002401034000340204408044050540505406054080540f054110541705412054160541c0541c05417034200340204402054000540007400004000040000400004000040000400004000040000400004
000400000607000050016300104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f07000050016300704000050000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000364217052060320007203612110020600200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
0004000001616060460d0460060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606
0006000001635050450c0450060518005160352100518005240050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
000300000007100131001310c0110b051041710f0011e001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000300000007100131071310c0110b051071710a1510f1510a1510000113151000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000300000007100131001310f0111b051041710f0011e001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000400000e07107051060010000101031010010100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000500000007104631066210364128621050710105100001000010200106001270012700101001000010000106001100011900117001000010000100001000010000100001000010000100001000010000100001
000300000101506025000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000300000c01513025000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0005000002622046520a0420616211052000720a00203002050020010204102001020010200102001020010200102021020010200102001020010200102001020010200102001020010200102001020010200102
000c0000000720065201632000420a0520875216052000020a0421e0520d7420176205052090520f0520000210002160522205200002000020300202022040320a0020f002000020400200002000020200201002
000600000104100621060310007105021000010e001000010f6010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0002000003642070520a06200002010520a0520100203002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
00070000070350c045031051d15500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
000200000364207052050520305216022010720100200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
00020000036420c052050520305213022050720100200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000300000364207052060320007200002010020100200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
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
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 34 35 43 44
00 34 35 43 44
00 36 37 43 44
00 34 38 43 44
00 34 38 43 44
02 36 39 43 44
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
