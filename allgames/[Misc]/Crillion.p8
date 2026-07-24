pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--crillion
--by bn of gnbn

-- this is a remake of c64 game crillion
-- available online:
--     http://crillion.gnbnentertainment.com/
--     http://gnbn.itch.io/crillion

				
-- sprite-bit:
--     0-2 color
--     3   is color changer
--     4   is block destroyable
--     5   is block movable
--     6   is block background
-- highscore table:
--     8 highscores stored, each of them is 8 numbers
--         1: high score (high order)
--         2: high score (low order)
--         3-4-5-6-7: name of player
--         8: not used (only for checking is high score is saved already)

const = {
  slow_down_factor = 1,
  key_left = 0,
  key_right = 1,
  key_up = 2, -- not used
  key_down = 3, -- not used
  key_o = 4,
  key_x = 5,
  speed_x = 1,
  speed_y = 1,
  map_width = 15,
  map_height = 11,
  game_area_width = 15 * 8,
  game_area_height = 11 * 8,
  virtual_level_background = 31,

  black = 0,
  dark_blue = 1,
  dark_purple = 2,
  dark_green = 3,
  brown = 4,
  dark_gray = 5,
  light_gray = 6,
  white = 7,
  red = 8,
  orange = 9,
  yellow = 10,
  green = 11,
  blue = 12,
  indigo = 13,
  pink = 14,
  peach = 15,

  score_by_level = {
      [1]=81, [2]=70, [3]=39, [4]=28, [5]=50,
      [6]=43, [7]=147,[8]=63, [9]=125,[10]=255,
      [11]=43,[12]=79,[13]=48,[14]=209, [15]=43, 
      [16]=25, [17]=52, [18]=93, [19]=208, [20]=60, 
      [21]=47, [22]=108, [23]=44, [24]=212, [25]=74 
  },

  direction_enum = {
    up = {dx = 0, dy = -1},
    right = {dx = 1, dy = 0},
    down = {dx = 0, dy = 1},
    left = {dx = -1, dy = 0}
  },

  ball_color_green = 0,
  ball_color_blue = 1,
  ball_color_yellow = 2,
  ball_color_red = 3,
  ball_color_purple = 4,
  ball_color_cyan = 5,

  spr = {
    wall = 41,
    ball_shadow = 7,
    skull_shadow = 10,
    explode_0 = 58,
    explode_max = 63,
    ball_explode_0 = 43,
    ball_explode_max = 47,
    skull_0 = 26,
    skull_max = 30,
    placeholder_for_moving_object = 16,
    background_0 = 120,
    background_max = 123,

    start_pos_green_down = 64,
    start_pos_green_up = 65,
    start_pos_yellow_down = 66,
    start_pos_yellow_up = 67,
    start_pos_blue_down = 68,
    start_pos_blue_up = 69,
    start_pos_red_down = 70,
    start_pos_red_up = 71,
    start_pos_purple_down = 72,
    start_pos_purple_up = 73,
    start_pos_cyan_down = 74,
    start_pos_cyan_up = 75,
    start_pos_start = 64,  -- must be the start pos with lowest index
    start_pos_end = 75, -- must be the start pos with highest index

    bonus_4 = 76,
    bonus_5 = 77,
    bonus_6 = 78,
    bonus_7 = 79,
    bonus_8 = 92,
    bonus_9 = 93
  },

  -- chars for highscore
  char_codes = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", 
    "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", 
    "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", 
    "4", "5", "6", "7", "8", "9", "-", ".", " "
  },

  sfx = {
    wind = 0,
    explosion = 2,
    bonus = 3,
    death_explosion = 4,
    color_change = 5,
    wall_collide = 8,
    movement = 9
  } 
}

const.color_seq_lightning = {0, 5, 6, 7, 6, 5, 0}
const.color_seq_highlight = {5, 5, 6, 6, 7, 6, 6}

const.spr.initial_bonus_by_spr={
  [const.spr.bonus_4] = 499,
  [const.spr.bonus_5] = 599,
  [const.spr.bonus_6] = 699,
  [const.spr.bonus_7] = 799,
  [const.spr.bonus_8] = 899,
  [const.spr.bonus_9] = 999
}

const.spr.ball_by_color={
  [const.ball_color_green] = 1,
  [const.ball_color_blue] = 2,
  [const.ball_color_yellow] = 3,
  [const.ball_color_red] = 4,
  [const.ball_color_purple] = 5,
  [const.ball_color_cyan] = 6
}


screens = {
  main_menu_screen = {
    init = function() init_main_menu_screen() end,
    update = function() update_main_menu_screen() end,
    draw = function() draw_main_menu_screen() end    
  },
  highscore_screen = {
    highscores = {},
    score_colors_by_rank = {const.yellow, const.green, const.blue, 
        const.light_gray, const.light_gray, const.dark_gray, 
        const.dark_gray, const.dark_gray},
    is_it_new_highscore = false,
    current_char_index = 0,
    current_highscore_index = 1,
    color_seq_index = 1,
    init = function() init_highscore_screen() end,
    update = function() update_highscore_screen() end,
    draw = function() draw_highscore_screen() end    
  },
  game_screen = {
    init = function() init_game_screen() end,
    update = function() update_game_screen() end,
    draw = function() draw_game_screen() end
  },
  game_over_screen = {
    init = function() init_game_over_screen() end,
    update = function() update_game_over_screen() end,
    draw = function() draw_game_over_screen() end
  }
}

game_state = {

  score = {high = 0, low = 0},
  best_score = {high = 0, low = 0},
  level = 1,
  lives = 1,
  starting_level = 1,
  random_level_selection = false,

  active_screen = screens.main_menu_screen,

  set_active_screen = function(new_screen)
    game_state.active_screen = new_screen
    game_state.active_screen.init()
  end
}

level_state = {
  blocks = 0,
  bonus = 599,
  block_score = 1,
  moving_objects
}

ball_state = {
  spr_ball = 0,
  color = 0,
  x = 0,
  y = 0,
  dx = 0,
  dy = 0,
  dying = false,
  winning = false,
}

mouse_state = {
  x = 0,
  y = 0,
  dx = 0,
  dy = 0,
  button_bits = 0,
  left_click = false
}

anim_state = {
  skull_anim_start = false,
  counter_frame = 0,
  counter_do_not_touch = 0,
  counter_dying = 0,
  ongoing_effect = false,
  effect_fade_ongoing = false,
  effect_fade_counter = 0,
  effect_fade_dir = 0,
  winning_counter = 0,
  effect_death_lightning_ongoing = false,
  counter_death_lightning = 1
}

sound_state = {
    bonus_sound_playing = false
}

pico8 = {
  poke = poke,
  flr = flr,
  mset = mset,
  mget = mget,
  band = band,
  fget = fget,
  btn = btn,
  btnp = btnp,
  stat = stat,
  palt = palt,
  spr = spr,
  print = print,
  rectfill = rectfill,
  rect = rect,
  line = line,
  map = map,
  pal = pal,
  camera = camera,
  menuitem = menuitem,
  dget = dget,
  dset = dset,
  pairs = pairs,
  rnd = rnd
}


----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- general util functions
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function print_center(str, y, c, correction)
  local strlen = #str
  if (correction) then
    strlen += correction
  end
  local x = 64 - strlen*4/2
  pico8.print(str, x, y, c)
end

-- big number functions
function bn_inc(number)
  if (low < 999) then
    return { high = number.high, low = number.low + 1}
  else
    return { high = number.high + 1, low = 0}
  end
end

function pad_with_zeros(number, zero_count)
  local str = ""..number
  while #str < zero_count do
    str="0"..str
  end
  return str
end

function bn_to_string(number)
  if (number.high == 0) then
    return number.low
  else
    return ""..number.high..pad_with_zeros(number.low,3)
  end
end

function bn_to_string6(number)
  local str = ""..bn_to_string(number)
  return pad_with_zeros(str, 6)
end

function bn_normalize(number)
  local low_remained = number.low % 1000
  local high_to_add = flr(number.low / 1000)
  return { high = number.high + high_to_add, low = low_remained }
end

function bn_add(number, addition)
  return bn_normalize({high = number.high, low = number.low + addition})
end

function bn_create(high, low)
  return {high = high, low = low}
end

function bn_greater(number1, number2)
  return number1.high > number2.high or 
      (number1.high == number2.high and number1.low > number2.low)
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- main menu screen functions
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function init_main_menu_screen()
  pico8.menuitem(1)
end

function update_main_menu_screen()
  if (pico8.btnp(const.key_x) or mouse_state.left_click) then
    game_state.set_active_screen(screens.game_screen)
  end 
  if (pico8.btnp(const.key_left) and game_state.starting_level > 1) then
    game_state.starting_level -= 4
  end
  if (pico8.btnp(const.key_right) and game_state.starting_level < 21) then
    game_state.starting_level += 4
  end
end

function draw_main_menu_screen()
  pico8.rectfill(0, 0, 127, 127, const.black)
  pico8.map(32,48,2,0,16,13)
  print_center("remake of c64 game crillion", 58, const.dark_blue)
  print_center("BY b.n. OF gnbn", 66, const.dark_blue)
  print_center("original game by oliver kirwa", 77, const.dark_blue)

  print_center("1.level:", 88, const.green)
  print_center(pad_with_zeros(game_state.starting_level, 2), 94, const.blue)

  print_center("(x) to continue", 105, const.light_gray)
  print_center("(left) and (right) to control", 113, const.light_gray)

  pico8.print("v1.0", 128-16, 120, const.dark_gray)
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- game over screen functions
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function init_game_over_screen()
  game_over_x = -9*4
  game_over_color_index = 0
  pico8.menuitem(1)
end

function update_game_over_screen()
  if (anim_state.counter_frame % const.slow_down_factor == 0) then		
    if (pico8.btnp(const.key_x) or mouse_state.left_click) then
      game_state.set_active_screen(screens.highscore_screen)
    end
    if (game_over_x < 64 - 4 * 4) then
      game_over_x += 4
    end
    if (anim_state.counter_frame % 3 == 0) then
      if (game_over_x > 0 and game_over_color_index < 8) then
        game_over_color_index += 1
      end
    end
  end
  anim_state.counter_frame+=1
  if (anim_state.counter_frame>255) then
    anim_state.counter_frame=0
  end
end

function draw_game_over_screen()
  local bck_color = const.color_seq_lightning[game_over_color_index]
  pico8.rectfill(0, 0, 127, 127, bck_color)

  pico8.print("game over", game_over_x, 44, const.light_gray)

  draw_frame()
  draw_status()
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- highscore screen functions
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function init_highscores_if_not_present()
  if (pico8.dget(63) != 1976) then
    for i = 1,8 do
      local highscore = {
        name = "nobody",
        score = bn_create(0, 0)
      }
      save_highscore(i, highscore)
    end
    pico8.dset(63, 1976)
  end
end

function get_number_from_char(char)
  for k,v in pico8.pairs(const.char_codes) do
    if (v == char) then
      return k
    end
  end
  return 0
end

function get_char_from_number(number)
  return const.char_codes[number]
end

function get_string_as_numbers(str)
  local number_codes = {}
  local count = pico8.flr(#str/2)
  if (#str % 2 == 1) then
    count += 1
  end
  for i = 1, count do
    local index = (i-1)*2+1
    local letter_1 = sub(str, index, index)
    local letter_2 = sub(str, index+1, index+1)
    local number_1 = get_number_from_char(letter_1)
    local number_2 = get_number_from_char(letter_2)
    number_codes[i] = number_1 * 100 + number_2
  end
  return number_codes
end

function get_numbers_as_string(numbers)
  local result_str = ""
  for number in all(numbers) do
    local number_1 = pico8.flr(number / 100)
    local number_2 = number % 100
    if (number_1 != 0) then
      result_str = result_str..get_char_from_number(number_1)
    end
    if (number_2 != 0) then
      result_str = result_str..get_char_from_number(number_2)    
    end
  end
  return result_str
end

function save_highscore(index, highscore)
  local offset = (index - 1) * 8
  pico8.dset(offset + 0, highscore.score.high)
  pico8.dset(offset + 1, highscore.score.low)
  for i=2,6 do
    pico8.dset(offset + i, 0)
  end
  local name_as_numbers = get_string_as_numbers(highscore.name)
  local i = 2
  for number in all(name_as_numbers) do
    pico8.dset(offset + i, number) 
    i += 1
  end
end

function get_highscore(index)

  local offset = (index - 1) * 8
  local score = bn_create(pico8.dget(offset + 0), pico8.dget(offset + 1))
  local numbers = {}
  for i = 1, 5 do
    numbers[i] = pico8.dget(offset + 1 + i)
  end
  local name = get_numbers_as_string(numbers)  
  return {score = score, name = name }
end

function init_highscore_screen()
  local screen = screens.highscore_screen
  local highscores = screen.highscores
  for i = 1,8 do
    highscores[i] = get_highscore(i)
  end
  screen.is_it_new_highscore = bn_greater(game_state.score, highscores[8].score)
  if (screen.is_it_new_highscore) then
    local index = 8
    while (index >= 1 and bn_greater(game_state.score, highscores[index].score)) do
      if (index < 8) then
        local old_highscore = get_highscore(index)
        save_highscore(index + 1, old_highscore)
        highscores[index + 1] = highscores[index]
      end
      index -= 1
    end
    local new_index = index + 1
    highscores[new_index] = {score = game_state.score, name = "          "} 
    screen.current_highscore_index = new_index
    screen.current_char_index = 1
    save_highscore(new_index, highscores[new_index])
  end
end

function step_highscore_char(change)
  local screen = screens.highscore_screen
  local name = screen.highscores[screen.current_highscore_index].name
  local char = sub(name, screen.current_char_index, screen.current_char_index)
  local number = get_number_from_char(char)
  number += change
  if (number<1) then
    number = #const.char_codes
  end
  if (number>#const.char_codes) then
    number = 1
  end
  local new_char = get_char_from_number(number)
  local pre_char = sub(name, 1, screen.current_char_index - 1)
  local post_char = sub(name, screen.current_char_index+1, 10)
  screen.highscores[screen.current_highscore_index].name = pre_char .. new_char .. post_char
end

function update_highscore_screen()
  local screen = screens.highscore_screen
  if (screen.is_it_new_highscore) then
    -- new highscore enable editing functions
    if (pico8.btnp(const.key_left) and screen.current_char_index > 1) then
      screen.current_char_index -= 1
    end
    if (pico8.btnp(const.key_right) and screen.current_char_index < 10) then
      screen.current_char_index += 1
    end
    if (pico8.btnp(const.key_up)) then
      step_highscore_char(1)
    end
    if (pico8.btnp(const.key_down)) then
      step_highscore_char(-1)
    end
    if (pico8.btnp(const.key_x) or mouse_state.left_click) then
      save_highscore(screen.current_highscore_index, screen.highscores[screen.current_highscore_index])
      screen.is_it_new_highscore = false
    end
  else
    -- no new highscore just display list
    if (pico8.btnp(const.key_x) or mouse_state.left_click) then
      game_state.set_active_screen(screens.main_menu_screen)
    end
  end
  anim_state.counter_frame+=1
  if (anim_state.counter_frame>255) then
    anim_state.counter_frame=0
  end
  if (anim_state.counter_frame % 4 == 0) then
    screen.color_seq_index += 1
    if (screen.color_seq_index > #const.color_seq_highlight) then
      screen.color_seq_index = 1
    end
  end
end

function draw_highscore_screen()
  local screen = screens.highscore_screen
  pico8.rectfill(0, 0, 127, 127, const.black)

  local highlight_color = const.color_seq_highlight[screen.color_seq_index]
  if (screen.is_it_new_highscore) then
    local top = 15 + screen.current_highscore_index*9 - 1
    local left = 15+4*15+4*(screen.current_char_index-1) - 1
    pico8.rectfill(0, top, 127, top + 6, const.dark_blue)
    pico8.rect(left, top-1, left+4, top + 6+1, highlight_color)
    print_center("use arrows to enter name", 100, highlight_color)
    print_center("press x to finish", 108, highlight_color)
  end

  print_center("the top eight:", 8, const.blue)
  for i = 1,8 do
    local highscore = screen.highscores[i]
    local color = screen.score_colors_by_rank[i]
    local text = ""..i..".   "..bn_to_string6(highscore.score).."    "..highscore.name
    pico8.print(text, 15, 15 + i*9, color)
  end
  
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- game screen functions
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

----------------------------------------------------------
-- game screen util function
----------------------------------------------------------
function read_map(x, y)
  local map_x = pico8.flr(x/8)
  local map_y = pico8.flr(y/8)
  return pico8.mget(map_x, map_y)
end

function write_map(x, y, elem)
  local map_x = pico8.flr(x/8)
  local map_y = pico8.flr(y/8)
  pico8.mset(map_x, map_y, elem)
end

function is_same_color(sprite_index)
  local flags = pico8.fget(sprite_index)
  return pico8.band(flags, 7) == ball_state.color
end

function is_color_changer(sprite_index)
  return pico8.fget(sprite_index, 3)
end

function is_block_movable(sprite_index)
  return pico8.fget(sprite_index, 5)
end

function is_block_background(sprite_index)
  return pico8.fget(sprite_index, 6)
end

function is_block_destructible(sprite_index)
  return pico8.fget(sprite_index, 4)
end

function is_skull(sprite_index)
  return sprite_index >= const.spr.skull_0 and sprite_index <= const.spr.skull_max
end

function get_level_offset(level_index)
  return {
      x = (level_index % 8) * 16, 
      y = pico8.flr(level_index/8) * 16
  }
end

function add_score(addition)
  local old_score = game_state.score
  local new_score = bn_add(game_state.score, addition)
  local old_score_ten_thousands = pico8.flr(old_score.high/10)
  local new_score_ten_thousands = pico8.flr(new_score.high/10)
  -- apply extra life rule
  if (new_score_ten_thousands > old_score_ten_thousands) then
    if (game_state.lives < 7) then
      game_state.lives += 1
    end 
  end 
  game_state.score = new_score
  if (bn_greater(new_score, game_state.best_score)) then
    game_state.best_score = new_score
  end
end

----------------------------------------------------------
-- game screen game logic functions
----------------------------------------------------------

function reset_level()
  start_fade_effect(real_reset_level)
end

function reset_game()
  game_state.score = { high = 0, low = 0}
  game_state.level = game_state.starting_level
  game_state.lives = 4
  real_reset_level()
end

function fill_background()
  local level_offset = get_level_offset(const.virtual_level_background)
  local background_count = const.spr.background_max - const.spr.background_0 
  for x=0,const.map_width-1 do
    for y=0,const.map_height-1 do
      local background_index = const.spr.background_0 + pico8.flr(rnd(background_count + 1))
      pico8.mset(level_offset.x + x, level_offset.y + y, background_index)
    end
  end
end

function real_reset_level()
  ball_state.x = 44
  ball_state.y = 8
  ball_state.dx = 0
  ball_state.dy = const.speed_y

  local level_index = game_state.level
  local level_offset = get_level_offset(level_index)

  ball_state.dying = false
  ball_state.winning = false
  anim_state.winning_counter = 0
  level_state.bonus = 999
  local bonus_elem = pico8.mget(level_offset.x + 15, level_offset.y)
  local init_bonus = const.spr.initial_bonus_by_spr[bonus_elem]
  if (init_bonus != nil) then
    level_state.bonus = init_bonus
  end

  level_state.blocks=0
  for x=0,const.map_width-1 do
    for y=0,const.map_height-1 do
      local elem = pico8.mget(level_offset.x + x, level_offset.y + y)
      if (elem >= const.spr.start_pos_start and elem <= const.spr.start_pos_end) then
        ball_state.x = x*8
        ball_state.y = y*8
        ball_state.color=pico8.band(pico8.fget(elem), 7)
        if (elem == const.spr.start_pos_green_down 
           or elem == const.spr.start_pos_yellow_down
           or elem == const.spr.start_pos_blue_down
           or elem == const.spr.start_pos_red_down
           or elem == const.spr.start_pos_purple_down
           or elem == const.spr.start_pos_cyan_down) then
       	  ball_state.dy = const.speed_y
        else
       	  ball_state.dy = -const.speed_y
        end 
        elem = 0
      elseif (is_block_destructible(elem)) then
        level_state.blocks+=1
      end
      pico8.mset(x, y, elem)
    end
  end

  -- setting score for blocks
  level_state.block_score = const.score_by_level[game_state.level]
  if (level_state.block_score == nil) then
    level_state.block_score = pico8.flr(2500 / level_state.blocks) 
  end

  level_state.moving_objects = {}

  sound_state.bonus_sound_playing = false

  fill_background()
end


function explode(x, y)
  write_map(x, y, const.spr.explode_0)
  if (not ball_state.dying) then
    sfx(const.sfx.explosion)
    add_score(level_state.block_score)
    if (level_state.blocks > 0) then
      level_state.blocks-=1
    end
  end
end

function move_object_by_diff(x, y, dx, dy)
  local target_x = x + dx
  local target_y = y + dy
  if (target_x>=0 and target_y>=0 and target_x<const.map_width and target_y<const.map_height) then
    local target_elem = pico8.mget(target_x, target_y)
    if (target_elem == 0) then
      local elem = pico8.mget(x, y)
      add(level_state.moving_objects, {elem=elem, orig_x=x, orig_y=y, dx=dx, dy=dy, offset_x=0, offset_y=0})
      sfx(const.sfx.movement)
      pico8.mset(target_x, target_y, const.spr.placeholder_for_moving_object)
      pico8.mset(x, y, 0)
    end
  end
end

function move_object(contact_x, contact_y, direction) 
  local map_x = pico8.flr(contact_x/8)
  local map_y = pico8.flr(contact_y/8)

  move_object_by_diff(map_x, map_y, direction.dx, direction.dy)
end

function handle_collision(elem, x, y, direction)
  if (is_color_changer(elem)) then
    ball_state.color = pico8.band(pico8.fget(elem),7)
    sfx(const.sfx.color_change)
  elseif (is_skull(elem) and not anim_state.skull_anim_start and not ball_state.winning) then
    anim_state.skull_anim_start = true
    anim_state.effect_death_lightning_ongoing = true
    anim_state.counter_dying = 0
    ball_state.dying = true
    ball_state.dx = 0
    ball_state.dy = 0
  elseif (is_block_movable(elem) and is_same_color(elem)) then
    move_object(x,y, direction)
  elseif (elem!=const.spr.wall and is_same_color(elem)) then
    explode(x, y)
  end
end

function interact_with_map(point1_x, point1_y, direction)
  local elem_1 = read_map(point1_x, point1_y)
  if (not is_block_background(elem_1)) then
    handle_collision(elem_1, point1_x, point1_y, direction)
    if (elem_1 == const.spr.wall) then
      sfx(const.sfx.wall_collide)
    end
    return true  
  end
  return false
end


function update_handle_ball_wall(target_x, target_y)

  if (ball_state.dx < 0) then
    local p1_x = target_x+2
    local p1_y = ball_state.y+4
    if (interact_with_map(p1_x, p1_y, const.direction_enum.left)) then
      ball_state.dx = -ball_state.dx
      target_x = target_x + ball_state.dx * 2
      anim_state.counter_do_not_touch = 3
    end	
  elseif (ball_state.dx > 0) then
    local p1_x = target_x+5
    local p1_y = ball_state.y+4
    if (interact_with_map(p1_x, p1_y, const.direction_enum.right)) then
      ball_state.dx = -ball_state.dx
      target_x = target_x + ball_state.dx * 2
      anim_state.counter_do_not_touch = 3
    end
  end

  if (ball_state.dy > 0) then
    local p1_x = ball_state.x+4
    local p1_y = target_y+5
    if (interact_with_map(p1_x, p1_y, const.direction_enum.down)) then
      ball_state.dy = -ball_state.dy
      target_y = target_y + ball_state.dy*2
    end				
  elseif (ball_state.dy < 0) then
    local p1_x = ball_state.x+4
    local p1_y = target_y+2
    if (interact_with_map(p1_x, p1_y, const.direction_enum.up)) then
      ball_state.dy = -ball_state.dy
      target_y = target_y + ball_state.dy*2
    end				
  end

  ball_state.x = target_x
  ball_state.y = target_y
end


function update_ball()
  if (anim_state.counter_do_not_touch==0) then
    if (pico8.btn(const.key_left) or (mouse_state.dx < 0 and mouse_state.button_bits!=0)) then 
      if (not ball_state.dying and not ball_state.winning) then
        ball_state.dx = -const.speed_x
      end
    elseif (pico8.btn(const.key_right) or (mouse_state.dx > 0 and mouse_state.button_bits!=0)) then 
      if (not ball_state.dying and not ball_state.winning) then
        ball_state.dx = const.speed_x
      end
    elseif (ball_state.x % 4 == 2) then
      ball_state.dx = 0
    end
  else 
    anim_state.counter_do_not_touch -= 1
  end
  -- moving x
  local ball_target_x = ball_state.x + ball_state.dx
  -- left border
  if (ball_target_x < -2) then
    ball_state.dx = -ball_state.dx
    anim_state.counter_do_not_touch = 3
  end
  -- right border
  if (ball_target_x > const.game_area_width - 6) then
    ball_state.dx = -ball_state.dx			
    anim_state.counter_do_not_touch = 3
  end
  -- moving y
  local ball_target_y=ball_state.y + ball_state.dy
  
  -- bottom border
  if (ball_target_y + 5 >= const.game_area_height) then
    ball_state.dy = -ball_state.dy
    ball_target_y = ball_target_y + ball_state.dy*2
  end
  -- upper border
  if (ball_target_y + 2 < 0) then
    ball_state.dy = -ball_state.dy
    ball_target_y = ball_target_y+ball_state.dy*2
  end
  
  update_handle_ball_wall(ball_target_x, ball_target_y)

  if (ball_state.dying and ball_state.spr_ball < const.spr.ball_explode_0) then
    ball_state.spr_ball = const.spr.ball_explode_0
    sfx(const.sfx.death_explosion)
  elseif (not ball_state.dying) then
    ball_state.spr_ball = const.spr.ball_by_color[ball_state.color]
  end
end

function go_to_game_over()
  game_state.set_active_screen(screens.game_over_screen)
end

function kill_player()
  game_state.lives-=1
  if (game_state.lives == 0) then
    start_fade_effect(go_to_game_over)
  else
    reset_level()
  end
end

function go_to_next_level()
  if (not game_state.random_level_selection) then
    if (game_state.level < 25) then
      game_state.level += 1
    else
      game_state.random_level_selection = true
    end
  end
  if (game_state.random_level_selection) then
    local current_level = game_state.level
    local new_level = pico8.flr(pico8.rnd(24))+1
    if (new_level >= current_level) then
      new_level += 1
    end
    game_state.level = new_level
  end
end

function update_animation()
  if anim_state.counter_frame % 4 == 0 then
    for x=0,const.map_width-1 do
      for y=0,const.map_height-1 do
        local palya_elem = pico8.mget(x,y)
        if (palya_elem>=const.spr.explode_0 and palya_elem<=const.spr.explode_max) then
          if (palya_elem<const.spr.explode_max) then
            pico8.mset(x, y, palya_elem+1)
          else
            pico8.mset(x, y, 0)
          end
        end
        if anim_state.counter_frame % 16 == 0 then
          if (palya_elem>const.spr.skull_0 and palya_elem<=const.spr.skull_max) then
            if (palya_elem<const.spr.skull_max) then
              pico8.mset(x, y, palya_elem+1)
            end
          end
          if (palya_elem == const.spr.skull_0 and anim_state.skull_anim_start) then
            pico8.mset(x, y, palya_elem+1)
          end
        end
      end
    end
    if (ball_state.spr_ball >= const.spr.ball_explode_0 and ball_state.spr_ball <= const.spr.ball_explode_max) then 
      ball_state.spr_ball += 1
    end
    if (ball_state.dying) then
      anim_state.counter_dying += 1 
      if (anim_state.counter_dying > 25) then
        anim_state.counter_dying = 0
        anim_state.skull_anim_start = false
        kill_player()
      end
    end
  end
  if (ball_state.winning) then
    if (anim_state.winning_counter == 48) then
      ball_state.dx = 0
      ball_state.dy = 0
      if (not sound_state.bonus_sound_playing) then
        sound_state.bonus_sound_playing = true
        sfx(const.sfx.bonus, 1)
      end
      if (level_state.bonus == 0) then
        sfx(-1, 1) 
        add_score(10)   -- bug from orig game
        go_to_next_level()
        reset_level()
      else
        local diff = 1 
        if (level_state.bonus>=7) then
          diff = 7
        end
        level_state.bonus -= diff
        add_score(diff * 10)
      end
    else
      anim_state.winning_counter += 1
    end
  end
  if (ball_state.dying) then
    if (anim_state.counter_frame % 4 == 0) then
      if (anim_state.effect_death_lightning_ongoing) then
        if (anim_state.counter_death_lightning < #const.color_seq_lightning) then
          anim_state.counter_death_lightning += 1
        else 
          anim_state.effect_death_lightning_ongoing = false
          anim_state.counter_death_lightning = 1
        end
      end
    end
  end
end

function update_bonus()
  if (level_state.bonus > 0 and anim_state.counter_frame % 6 ==0 and not ball_state.winning and not ball_state.dying) then
    level_state.bonus -= 1
  end
end

function update_other_controls()
--  **** this is for testing - you can win levels if you uncomment this part
--  if (pico8.btnp(const.key_o) and game_state.level>1 and not ball_state.dying) then
--    game_state.level-=1
--    reset_level()
--  end
--  if (pico8.btnp(const.key_x) and not ball_state.dying) then
--   start_win_animation()
--  end
end

function start_win_animation()
  ball_state.winning = true
end

function update_win_conditions()
  if (level_state.blocks == 0 and not ball_state.dying and not ball_state.winning) then
    start_win_animation()
  end
end

function update_effects()
  if (anim_state.effect_fade_ongoing) then
    anim_state.effect_fade_counter+=anim_state.effect_fade_dir
    if (anim_state.effect_fade_dir==-1 and anim_state.effect_fade_counter == 0) then
      anim_state.effect_fade_ongoing = false
      anim_state.ongoing_effect = false
    end
    if (anim_state.effect_fade_counter > 16) then
      anim_state.effect_fade_dir = -1
      effect_fade_fn_in_middle() 
    end
  end
end

function restart_level_from_menu()
  anim_state.skull_anim_start = true
  anim_state.effect_death_lightning_ongoing = true
  ball_state.dying = true
  anim_state.counter_dying = 0
  ball_state.dx = 0
  ball_state.dy = 0
--  kill_player()
end

function draw_ball()
  pico8.spr(ball_state.spr_ball, ball_state.x, ball_state.y)
end

function draw_ball_shadow()
  if (not ball_state.dying) then
    pico8.palt(0, false)
    pico8.palt(7, true)
    pico8.spr(const.spr.ball_shadow, ball_state.x + 3, ball_state.y + 3)
    pico8.palt()
  end
end

function draw_status()
  local color_label = const.blue
  local color_value = const.green
  if (anim_state.effect_death_lightning_ongoing) then 
    local new_color = const.color_seq_lightning[anim_state.counter_death_lightning]
    if (new_color != 0) then
      color_label = new_color
      color_value = new_color
    end
  end

  local top = 98
  pico8.print("score", 12, top, color_label)
  pico8.print(bn_to_string6(game_state.score), 12+4, top+6, color_value)

  pico8.print("level", 12 + 44, top, color_label)
  pico8.print(game_state.level, 12 + 44 +4, top+6, color_value)

  pico8.print("bonus", 12 + 80, top, color_label)
  pico8.print(pad_with_zeros(level_state.bonus, 3), 12 + 80 + 4, top+6, color_value)

  pico8.print("best", 12, top+13, color_label)
  pico8.print(bn_to_string6(game_state.best_score), 12+4, top + 13+6, color_value)

  pico8.print("lives", 12 + 44, top + 13, color_label)
  pico8.print(game_state.lives, 12 + 44 +4, top + 13+6, color_value)

  pico8.print("blocks", 12 + 80, top + 13, color_label)
  pico8.print(level_state.blocks, 12 + 80 + 4, top + 13+6, color_value)

--  local cpu_usage = ""..pico8.flr(pico8.stat(1)*100)
--  pico8.print("cpu:"..sub(cpu_usage, 1, 2), 104, 120, const.dark_blue)
end

function update_moving_objects()
  for object in all(level_state.moving_objects) do
    object.offset_x+=object.dx
    object.offset_y+=object.dy
    if (object.offset_x == 8*object.dx and object.offset_y == 8*object.dy) then
      del(level_state.moving_objects, object)
      pico8.mset(object.orig_x + object.dx, object.orig_y + object.dy, object.elem)
    end
  end
end

function draw_moving_objects()
  for object in all(level_state.moving_objects) do
    pico8.spr(object.elem, object.orig_x*8 + object.offset_x, object.orig_y * 8 + object.offset_y)
  end
end

function draw_moving_objects_shadow()
  for object in all(level_state.moving_objects) do
    local x = object.orig_x*8 + object.offset_x 
    local y = object.orig_y * 8 + object.offset_y
    pico8.rectfill(x + 3, y + 3, x + 7 + 3, y + 7 + 3, 0)
  end
end

function draw_frame()

  local frame_light_color = 7
  local frame_main_color = 12
  local frame_dark_color = 1
  if (anim_state.effect_death_lightning_ongoing) then 
    frame_main_color = const.color_seq_lightning[anim_state.counter_death_lightning]
    frame_dark_color = const.color_seq_lightning[anim_state.counter_death_lightning]
    frame_light_color = const.color_seq_lightning[anim_state.counter_death_lightning]
    if (frame_main_color == 0) then
      frame_main_color = 12
      frame_dark_color = 1
      frame_light_color = 7
    end
  end


  local y_middle = const.game_area_height+4
  local y_end = 123

  pico8.line(0,0, 127, 0, frame_light_color)
  pico8.rectfill(0,1, 127, 2, frame_main_color)
  pico8.line(0,3, 127, 3, frame_dark_color)

  pico8.line(0,1, 0, y_end+3, frame_light_color)
  pico8.rectfill(1,1, 2, y_end, frame_main_color)
  pico8.line(3,4, 3, y_end, frame_dark_color)
  
  pico8.line(127-3,4, 127-3, y_end, frame_light_color)
  pico8.rectfill(127-2,3, 127-1, y_end, frame_main_color)
  pico8.line(127,0, 127, y_end+3, frame_dark_color)

  pico8.line(4,y_end, 127-4, y_end, frame_light_color)
  pico8.rectfill(1,y_end+1, 127-1, y_end+2, frame_main_color)
  pico8.line(0,y_end+3, 127, y_end+3, frame_dark_color)

  pico8.line(4,y_middle, 127-4, y_middle, frame_light_color)
  pico8.rectfill(3,y_middle+1, 127-1, y_middle+2, frame_main_color)
  pico8.line(4,y_middle+3, 124, y_middle+3, frame_dark_color)
end

function start_fade_effect(fn_in_middle)
  anim_state.ongoing_effect = true
  anim_state.effect_fade_ongoing = true
  anim_state.effect_fade_counter = 0
  anim_state.effect_fade_dir = 1
  effect_fade_fn_in_middle = fn_in_middle
end

function draw_change_effect()
  if (anim_state.effect_fade_ongoing) then
    for i=0,15 do
      local height = get_height_for_fade_effect(i)
      if (height>0) then
        if (anim_state.effect_fade_dir == 1) then
          pico8.rectfill(0, i*8, 127, i*8+height, const.black)
        else 
          pico8.rectfill(0, i*8+8-height, 127, i*8+8, const.black)
        end
      end
    end
  end
end

function get_height_for_fade_effect(index)
  if (anim_state.effect_fade_counter > 16) then
    return 8
  else
    return anim_state.effect_fade_counter/2
  end
end

function draw_background()
  local level_offset = get_level_offset(const.virtual_level_background)
  if (ball_state.winning) then 
    if (anim_state.winning_counter > 9*4) then
      pico8.pal()
    elseif (anim_state.winning_counter > 8*4) then
      pico8.pal(1, 13)
    elseif (anim_state.winning_counter > 7*4) then
      pico8.pal(1, 6)
    elseif (anim_state.winning_counter > 5*4) then
      pico8.pal(1, 7)
    elseif (anim_state.winning_counter > 4*4) then
      pico8.pal(1, 6)
    elseif (anim_state.winning_counter > 3*4) then
      pico8.pal(1, 13)
    end
  end
  pico8.palt(0, false)
  pico8.map(level_offset.x,level_offset.y,0,0,const.map_width,const.map_height)
  pico8.palt()
  if (ball_state.winning) then 
    pico8.pal()
  end
end

function draw_map_shadow()
  for x=0,const.map_width-1 do
    for y=0,const.map_height-1 do
      local elem = pico8.mget(x, y)
      local elem_to_right = pico8.mget(x + 1, y)
      local elem_to_bottom = pico8.mget(x, y + 1)
      local elem_to_bottom_right = pico8.mget(x + 1, y + 1)
      if (not is_block_background(elem) and not is_skull(elem) and elem != const.spr.placeholder_for_moving_object) then 
        pico8.rectfill(x * 8 + 3, y * 8 + 3, x * 8 + 7 + 3, y * 8 + 7 + 3, 0)
      elseif (is_skull(elem)) then
        pico8.palt(0, false)
        pico8.palt(7, true)
        pico8.spr(const.spr.skull_shadow, x * 8 + 3, y * 8 + 3)
        pico8.palt()
      end
    end
  end  
end

----------------------------------------------------------
-- game screen main functions
----------------------------------------------------------

function init_game_screen()
  reset_game()
  pico8.menuitem(1, "restart level", restart_level_from_menu)
end

function update_game_screen()
  if (anim_state.counter_frame % const.slow_down_factor == 0) then		
    if (anim_state.ongoing_effect) then
      update_effects()
    else     
      update_ball()
      update_animation()
      update_moving_objects()
      update_bonus()
      update_other_controls()
      update_win_conditions()
    end
  end
  anim_state.counter_frame+=1
  if (anim_state.counter_frame>255) then
    anim_state.counter_frame=0
  end
end

function draw_map()
  pico8.map(0,0,0,0,const.map_width,const.map_height)

  -- lightning effect for wall elements
  if (anim_state.effect_death_lightning_ongoing) then 
    pico8.pal(const.light_gray, const.white)
    pico8.pal(const.dark_gray, const.light_gray)
    for x=0,const.map_width-1 do
      for y=0,const.map_height-1 do
         local elem = pico8.mget(x, y)
         if (elem == const.spr.wall) then
           pico8.spr(elem, x * 8, y * 8)
         end
      end
    end
    pico8.pal()
  end
end

function draw_game_screen()
  pico8.rectfill(0, 96, 127, 127, 0)

  pico8.camera(-4,-4)
  draw_background()
  draw_map_shadow()
  draw_ball_shadow()
  draw_moving_objects_shadow()
  draw_map()

  draw_moving_objects()	  	
  draw_ball()
  pico8.camera()

  draw_change_effect()

  draw_frame()

  draw_status()
end

function update_mouse()
  local new_mouse_x = pico8.stat(32)
  local new_mouse_y = pico8.stat(33)
  mouse_state.dx = new_mouse_x - mouse_state.x
  mouse_state.dy = new_mouse_y - mouse_state.y
  mouse_state.x = new_mouse_x
  mouse_state.y = new_mouse_y
  local prev_button_bits = mouse_state.button_bits
  mouse_state.button_bits = pico8.stat(34)
  if (pico8.band(mouse_state.button_bits, 1) == 1 and pico8.band(prev_button_bits, 1) == 0) then
    mouse_state.left_click = true
  else
    mouse_state.left_click = false
  end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
--- pico-8 entry points: init, update, draw
--------------------------------------------
--------------------------------------------
--------------------------------------------

function _init()
  -- turn off mouse support, undocumented feature from http://www.lexaloffle.com/bbs/?tid=3549
  pico8.poke(0x5f2d, 1)  
  cartdata("gnbn_crillion_remake")
  init_highscores_if_not_present()
end

function _update60()
  update_mouse()
  game_state.active_screen.update()
end

function _draw()
  game_state.active_screen.draw()
end	
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
00000000000000000000000000000000000000000000000000000000777777770000000000000000770000770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777777770000000000000000700000070000000000000000000000000000000000000000
00000000000330000005500000099000000ee0000002200000011000777007770000000000000000700000070000000000000000000000000000000000000000
00000000003bb30000511500009aa90000e88e00002ee200001cc100770000770000000000000000700000070000000000000000000000000000000000000000
00000000003bb30000511500009aa90000e88e00002ee200001cc100770000770000000000000000700000070000000000000000000000000000000000000000
00000000000330000005500000099000000ee0000002200000011000777007770000000000000000770000770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777777770000000000000000770000770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777777770000000000000000770000770000000000000000000000000000000000000000
000000007777777377777775777777797777777e7777777277777771000000000000000000000000006666000066660000666600006666000066660000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000066666600666666006666660066666600666666000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000065665600666666006566560065666600656656000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000066556600665566006655660066556600665566000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000056666500566665005666650056666500566665000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000006006000060060000600600006006000060060000000000
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000006666000066660000666600006666000066660000000000
00000000333333335555555599999999eeeeeeee2222222211111111000000000000000000000000005555000055550000555500005555000055550000000000
000000007777777377777775777777797777777e7777777277777771000000000000000066666665000000000000000000000000000000000995990aa955559a
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc10000000000000000666666650000000000000000000000000000000099565990956a9659
000000007b7bb7b3717117157a7aa7a97878878e7e7ee7e27c7cc7c100000000000000006666666500000000000000000a959a0000959000957665995669a665
000000007bb77bb3711771157aa77aa97887788e7ee77ee27cc77cc100000000000000005555555500000000000060000957590009595900577a97595a966a95
000000007bb77bb3711771157aa77aa97887788e7ee77ee27cc77cc1000000000000000066656666000000000006760005767500950a05909579a77559a669a5
000000007b7bb7b3717117157a7aa7a97878878e7e7ee7e27c7cc7c1000000000000000066656666000000000000600009575900566a665999566759566a9665
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc100000000000000006665666600000000000000000a959a0095000590099565999569a659
00000000333333335555555599999999eeeeeeee222222221111111100000000000000005555555500000000000000000000000009555900a0995990a955559a
000000007777777377777775777777797777777e7777777277777771000000000000000000000000000000000000000000000000005555005566665505555550
000000007bbbbbb3711111157aaaaaa97888888e7eeeeee27cccccc1000000000000000000000000000000000000000000566500056776505667766555000055
000000007b333333717777757a7777797877777e7e7777727c777771000000000000000000000000000000000006600005677650567777656675576650000005
000000007b3bbbb3717111157a7aaaa97878888e7e7eeee27c7cccc1000000000000000000000000000000000067760006777760577777756750057650000005
000000007b3b3333717177757a7a77797878777e7e7e77727c7c7771000000000000000000000000000000000067760006777760577777756750057650000005
000000007b3b3bb3717171157a7a7aa97878788e7e7e7ee27c7c7cc1000000000000000000000000000000000006600005677650567777656675576650000005
000000007b3b3b33717171757a7a7a797878787e7e7e7e727c7c7c71000000000000000000000000000000000000000000566500056776505667766555000055
00000000333333335555555599999999eeeeeeee2222222211111111000000000000000000000000000000000000000000000000005555005566665505555550
00bbbb00000bb00000aaaa00000aa00000cccc00000cc000008888000008800000eeee00000ee000006666000006600000008000000088880000888800008888
00bbbb0000bbbb0000aaaa0000aaaa0000cccc0000cccc00008888000088880000eeee0000eeee00006666000066660000008000000080000000800000000008
00bbbb000bbbbbb000aaaa000aaaaaa000cccc000cccccc0008888000888888000eeee000eeeeee0006666000666666000008000000080000000800000000008
00bbbb00bbbbbbbb00aaaa00aaaaaaaa00cccc00cccccccc008888008888888800eeee00eeeeeeee006666006666666655008080550088885500888855000008
bbbbbbbb00bbbb00aaaaaaaa00aaaa00cccccccc00cccc008888888800888800eeeeeeee00eeee00666666660066660050508888505000085050800850500008
0bbbbbb000bbbb000aaaaaa000aaaa000cccccc000cccc0008888880008888000eeeeee000eeee00066666600066660055000080550000085500800855000008
00bbbb0000bbbb0000aaaa0000aaaa0000cccc0000cccc00008888000088880000eeee0000eeee00006666000066660050500080505000085050800850500008
000bb00000bbbb00000aa00000aaaa00000cc00000cccc000008800000888800000ee00000eeee00000660000066660055000080550088885500888855000008
777777777777777777777771000777777777100077777000777777771107ccc10000000000000000000000000000000000008888000088880000000000000000
7cccccccccccccccccccccc10007cccccccc1000ccccc0007ccccccc0017ccc10000000000000000000000000000000000008008000080080000000000000000
7cccccccccccccccccccccc10007cccccccc1000ccccc0007ccccccc1007ccc10000000000000000000000000000000000008008000080080000000000000000
7cccccccccccccccccccccc10007cccccccc1000ccccc0007ccccccc7777ccc10000000000000000000000000000000055008888550088880000000000000000
7ccc1111111111111111ccc10007ccc11ccc1000111110007ccc1111ccccccc10000000000000000000000000000000050508008505000080000000000000000
7ccc1000000000000007ccc10007ccc17ccc1000000000007ccc1001ccccccc10000000000000000000000000000000055008008550000080000000000000000
7ccc1000000000000007ccc10007ccc17ccc1000000000007ccc1010ccccccc10000000000000000000000000000000050508008505000080000000000000000
7ccc1000000000000007ccc10007ccc17ccc1000000000007ccc1001111111110000000000000000000000000000000055008888550000080000000000000000
7ccc1000000000000007ccc17ccc10007ccc1777000000000007ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc11017ccc1ccc000000000017ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc10007ccc1ccc000000000007ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc10107ccc1ccc000000001007ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc10007ccc1111000000000107ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc11017ccc1000000000000007ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc10107ccc1000000000000107ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc17ccc10017ccc1000000000000007ccc1000000000000000000000000000000000000000000000000000000000000000000000000
7ccc1000000000000007ccc1777710000007ccc1000000000007ccc1000000000000101000000010000000000000001000000000000000000000000000000000
7ccc1000000000000007ccc1cccc10001017ccc1000000000107ccc1000000000100000000000000010000000100000000000000000000000000000000000000
7ccc1000000000000007ccc1cccc10000107ccc1000000000017ccc1000000000010100000001000000010000000100000000000000000000000000000000000
7ccc1777777777777777ccc1cccc10000007ccc1777770001007ccc1000000000100000000010001010001000000000000000000000000000000000000000000
7cccccccccccccccccccccc17ccc10000017ccc1ccccc0000017ccc1000000000000101010000010000000001010001000000000000000000000000000000000
7cccccccccccccccccccccc17ccc10001007ccc1ccccc0000107ccc1000000000000000000000100010000010000000000000000000000000000000000000000
7cccccccccccccccccccccc17ccc10000107ccc1ccccc0000007ccc1000000001010100010000000000010000000100000000000000000000000000000000000
1111111111111111111111117ccc10000007ccc1111110001017ccc1000000000000000101000101010101010101000100000000000000000000000000000000
009292929292929292929292929292c5434143434343434343434300004343c50000a1000000220000a1000000a100d500a400000000000000000000000000d4
61a16161926161a1616161a1616161c5520000000000000000000000000000e4a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1d4929292929292929292929292929292d5
0021a12121212121212121212121210000434141414141414341414300004300000042000000a100006200000032000000636363000063636300630063630000
616161a19261616161a161616161a100322292929292929292929292929200000000000000000000000000000000000022222222222231313122313131313100
00212121212121212121a12121212100434341434343430043434100414343000000000052000000000000120000000000636363636300006363006363630000
00000000920000000000000000000000000000000000000000000000000000000000000000000000000000000000000031313131313131313122313131313100
002121212121212121212121a12121004343414343434143004343434341430000000000a1000000000000a10000000000636363630063636363006363000000
00000000000000000000000000000000000000313131315131313131313131000092929292000084920000920000000031313131313131223122319292929200
002121212121a121212121212121210000434143a143644143434343434143009292929292929292929292929200040000006363000000006363006363006300
00000000929292929292920000000000000000314343a14343a1a1a1a1a1a1000092000092000000920000920000000000000000000000000000310000000000
0021212121212121212121212121a100434143434343434343430043434143000000230000000053000000004300000063006300630063006300000063630000
00000000925151000063920000000000000000313131313131313131313131000051000051000000510051000000000031313131313131223122319233330000
0021212121212121a121212121212100004143434343434343434343434143009200000092920000009292000000920063636363006363636300630063630000
000000009251630000a4920000000000000000000000000000000000000000000051000051000000515100000000000031313131313131223122319200000000
00212121a12121212121212121212100434141414100414143434300430043009292009292929200929292920092920063000063006363636300006300636300
92920092929292636300929292009200313131313131313131313131313100000051000051000000510051000000000022222222222231223122319200009200
00929292929292929292929292929200434141414243434343434143004300003192313192619261619211921111920063006363636363636363630063636300
00000000000000000000920000000000a1a1a1a1a1a143a1a1a1a1a1a13100000022000021000000210000210000000000002231313131223122319200923200
00222122212121212122212222212200434143414100434341414141434143003192333192619263619211921311920000000000000000000000000000000000
6192616192929292929292616161a100323131313131313131313131313100000021212121002100210000210021000000002231313131223131319200923200
00000000002300000000000000a40000434343414100414141434341414143003131313192616161619211111111920021222121212121212222212121212100
619261619252616161616161a1616100240000000000000000000000000000000000000000000000000000000000000000002231313131223131319200440000
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
000031926200009241000092000000d5423131313100313131313192000000d50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000092510000920000002300000000220000000000000000240041000000000555652516060600060006652535154500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23929292921392929292929292239200123131313100313131313192000000000600364716060600060006366726000600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220011040000920000009200000000929292929200929292929292000000000600461537060600060006366626000600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000092000000130000001300001100212121212100212121212192000000000600060006060600060006366726000600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92239292921392929213929292139200000000000000000000000092000000000757060006060757075706077526000600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000092000000920000009200000000000000000000000000000092000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000092210000920000009200000000000000000000000000000092922192000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92009292929213923192929292429200000000000000000000000092414141000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41004192000000630000005300000000000000000000000000000092414341000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52410092000000320052519221512200a1a1a1a1a1a1a1a1a1a1a192414141000000000000000000000000000000000000000000000000000000000000000000
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
40000000000000000202000103030000001011121314150000000000000000000008090a0b0c0d0000000000000000000020212223242520202000404040404000000202010103030404050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000004400004d4600000000000000000000000034004d1a121a121a121a121a121a121a121a4f12311212121212311a1212121212125c00460000003400001a0000001414144f1300130013003313330013001300134f1a22000000000000000000001200124c
0000000000000000000000000000000000000000000000120000000000000000002514141414141414141414141400000012001200120012001200120012000012313131123131313131313112311a0000000000002900000000000014142500001300130033003300330013001300001a1a0000000000000000001200220000
000000000000001100000000000000000000000000001212120000000000000000292929292929292929292929290000004400120012001200120012000000001212121212121212123112121231310000000034002915000000000014141400130013001300331333001300130013001a1a1a00000000000000000012001200
000000000000111111000000000000000000000000151515151500000000000000000000000000000000000000350000001200000012001200120000001200001231313131311231123112311212120029292900292929292929292929292900001300130033003300330013001300001a1a1a1a000000000000001200120000
000000000012120012120000000000000000000015151515151525000000000000221515151515151515151515150000001200120000001200000012001200001212121212311231121212311231120000000000000000000000000000000000130013001300331333001300130013001a1a001a1a0000000000000012001200
000000001212120012122200000000000000001a1a1a1a1a1a1a1a1a000000000029292929292929292929292929000000120012001200000012001200120000313131311231123112313131123112000015001515150015151500151515000000130013003300330033001300130000001a1a1a1a1a00000000001200120000
0000001a1a00000000001a1a000000000000000015151515151515000000000000000000000000000000000000000000001200120000001200000012001200001212123112121a3112311a121231120000150015001500150015001400150000130013001300331333001300130013001a1a1a001a1a1a000000000012001200
000000001212120012121200001300000000000000151515151500000000000000241212121212121212121212120000001200000012001200120000001200001231123131123131123131313131120000150015151500151515001414150000001342130033003300330013001300001a1a1a1a1a001a1a0000001200120000
00000000001212001212000000000000000000000000121212000000000000000029291a29291a29291a1a1a292900000000001200120012001200120000000012311212311212311212121212311a0000150000001500150015001400150000130013001300331333001300130013001a001a1a1a1a1a1a1a00004612001200
000000000000111111000000000000000000000000000012000000000000000000000000000000000000000000000000001200120012001200120012001200001231311231123131313131311231310000150000001500151515001414150000001300130033003300330013001300001a1a1a001a1a001a1a1a000000000000
000000000000001100000000002929290000000000000000000000000000000000000000000000000000000000000000001200120012001200120012001200001a311212121212311a4412121212120000000000000000000000000000000000130013001300331333001300130013001a1a1a1a1a1a1a1a1a1a1a0000000000
0000000000000000000000000029292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000002929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000029292929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000025000000000000001111165d0000000000000000000000000000004d1432000000320000003200000032244e1515151515291500152915151515155d1600000000001600001600000000005d0016161616161616001616161616164e2900290029002900290029002900294e1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a4e
0000000025002600000000001111160000000000000000001100000000411100003200320032003200320032003200001313131313292900292913131313130046000000160016160000000000000000001616161616161616161616001616000031113111311131113111311131000000000000110011001100110000000000
0000000029292929290000001111110000000011000000000000001100111100443200320032003200320032003200001414141414141400121212121212120000001600160016000016000000160000001616161600161616160016161616002900290029002900290029002900290000000000000000000000000000000000
0000000029002900290000001116110000111111001100000000001100292900003200320032003200320032003200001111111111112900291111111111110000001600000000000016001616260000001616161616161616161616161616000031003100310031003100310031000000000000000000004000000000000000
0000000029002948290000001616160000000011000000000000001100000000003200320032003200320032003200001616161616161200141616161616160016001600160016160016000000160000002121212121212121212121212121002900290029002900290029002900290000000000000000000000000000000000
0000000029002900290000001611110000313131313131313131313131313100003200320032003200320032003200001212121212121200141414141414140000001600160016000016000000160000002929292929292929292929292929000031003100310031003100310031000000000000000000000000000000000000
291a1a3500002900290000001611160000000000000000000000000000000000003200320032003200320032003200002929292929292934292929292929290000341600160016000016000000160000003500000035000000350000003529002900290029002900290029002900290011111111111111111111111111111100
000000000000000029000000161616000029002900290029002900290029000000320032003200320032003200320000291a221a231a2100261a241a251a290000001600160016000016000000160000000035003500350035003500350029000031003100310031003100314031000011001100111111111111111100111100
1313231300000000000000001111110000290029002900290029002900290000003200320032003200320032003200002900000000000000000000000000290000161600160016000000000000160000260000350000003500000035004829002900290029002900290029002900290011110011111111111111110011001100
0000150000000000000000001116160000230025002400250022002600210000003200320032003200320032003200002900000000000046000000000000290000160000000016000016000016160000000035003500350035003500350029000031113111311131113111311131000011111111111111111111111111111100
2115151500000000000000001116150000291329152914291529122916291100000000320000003200000032000000002900000000000000000000000000290000000000000016000016160000161a00003500000035000000350000003529002900290029002900290029002900290000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002900000000000000000000000000290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0009001f3c6703867034670326702b67027670236601e6501c6401763016610116500f6500d6500a65009650076500b6500e65012650166501a6502065024650286502b6502f65032650376503b6503e6503d000
000200000b6600e6700d6700c6700f6700f0700a6700a6700a6600b05008640066200462003610016100761003600026000260002600026000160000000000000000000000000000000000000000000000000000
000700002963129631116310f6310d6210c6210b6210a6110861108611306012f6012e6012c6012b6012760123601206011f6011c6011a60118601166011460112601106010e6010e6011260111601106010f601
000300203c5403452039530365403a5202c51032530385403851035520355303b5203d5303c5403c5403652031520345303f5103f52036530365203b5203853037530335103a5203d53035530355203c5203a510
00200000266410964104631016211360113601116010e6010b6010260109601056010f6010d6010a601076011a601026010160101601096010660104601026010160100601006010060100601006010060100601
000100000836107361073510735107341083410a3410d3311033113331163211a3212032124311273112b31130311343113d3113e30139301373013c3013f3013330136301383013830109301003010030110301
0010000032350303502d35026350283502535024350243502335023350233502335023350233502335023350203501e3501b3501a35018350143500f350003000030000300003000030000300003000030000300
00060000136411364113641136410a60101601096010860102601026010260102601016010160101601006010060100601006012e601316010060100601006010060100601006010060100601006010060100601
000200001d1631a143121333310300103001030010300103001030010300103001030010300103031030710300103001030010300103001030010300103001030010300103001030010300103001030010300103
000200000726108261092610a2510c2510e25110241132411524117241172311923119231192311723114231102210b2210521100201002010020119201002010020100201002010020100201002010020100201
010200001a3731f37322373283732c37332373373731e3532135324353273532b3532d35330353193331a3331c3332033323333263331432316323193231f3232332314313173131a3131e313213131d30320303
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
00 41 42 43 44
00 41 42 43 44
