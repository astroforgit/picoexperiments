pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- picomage
--by nicopico

function _init()
 gamestate="titlescreen"
 music(0) 
 difficulty="normal"
 init_game()
end

function init_game()
 ingamestate="player_draw_cards"
 palt(0,false)
 init_cards()
 init_players()
 frame=0
 selected_card_index=1
 enemy_action=""
 delaytimer={active=false,delay=0,expired=false}
 showchanges=false
 banneranim1=0
 banneranim2=0
 keydown={false,false,false,false,false,false}
 clouds={create_cloud(),create_cloud(),create_cloud(),create_cloud(),create_cloud(),create_cloud(),create_cloud()}
end

function create_cloud()
 cloud={x=-flr(rnd(128)),y=flr(rnd(24))+4,speed=flr(rnd(17)+3),sprite=flr(rnd(4))+128}
 return cloud
end

function recreate_cloud(cloud)
 cloud.x=-flr(rnd(64))
 cloud.y=flr(rnd(24))+4
 cloud.speed=flr(rnd(17)+3)
 cloud.sprite=flr(rnd(4))+128
end

function init_cards()
 cards=
 {
  create_card("bricks",1,"wall: wall +3",70,1),
  create_card("bricks",1,"base: castle +2",68,2),
  create_card("bricks",3,"reserve: castle +8, wall -4",62,3),
  create_card("bricks",3,"defense: wall +6",56,4),
  create_card("bricks",5,"tower: castle +5",66,5),
  create_card("bricks",8,"school: builders +1",64,6),
  create_card("bricks",10,"wain: castle+8, enemy castle-4",60,7),
  create_card("bricks",12,"bulwark: wall +22",54,8),
  create_card("bricks",18,"fort: castle +20",58,9),
  create_card("bricks",39,"babylon: castle +32",52,10),
  create_card("weapons",1,"archer: attack 3",44,11),
  create_card("weapons",2,"knight: attack 5",38,12),
  create_card("weapons",3,"rider: attack 8",34,13),
  create_card("weapons",4,"platoon: attack 10",32,14),
  create_card("weapons",8,"recruit: soldiers +1",36,15),
  create_card("weapons",9,"catapult: attack 14",50,16),
  create_card("weapons",12,"saboteur: enemy resources -4",40,17),
  create_card("weapons",15,"thief: steal 5 resources",48,18),
  create_card("weapons",18,"swat: enemy castle -10",46,19),
  create_card("weapons",28,"banshee: attack 32",42,20),
  create_card("crystals",4,"crush: enemy crystals -8",90,21),
  create_card("crystals",4,"melt: enemy weapons -8",88,22),
  create_card("crystals",4,"crumble: enemy bricks -8",86,23),
  create_card("crystals",4,"conjure crystals: crystals +8",78,24),
  create_card("crystals",4,"conjure bricks: bricks +8",74,25),
  create_card("crystals",4,"conjure weapons: weapons +8",76,26),
  create_card("crystals",8,"sorcerer: magi +1",72,27),
  create_card("crystals",21,"dragon: attack 25",80,28),
  create_card("crystals",22,"pixies: castle +22",84,29),
  create_card("crystals",25,"curse: all +1, enemy all -1",82,30)
 }
end

function card01(player,enemy)
 sfx(9)
 player.change.wall=3 
end

function card02(player,enemy)
 sfx(9)
 player.change.castle=2 
end

function card03(player,enemy)
 sfx(9)
 player.change.castle=8
 player.change.wall=-4
end

function card04(player,enemy)
 sfx(9)
 player.change.wall=6 
end

function card05(player,enemy)
 sfx(9)
 player.change.castle=5 
end

function card06(player,enemy) 
 sfx(11)
 player.change.builders=1 
end

function card07(player,enemy)
 sfx(9)
 player.change.castle=8 
 enemy.change.castle=-4 
end

function card08(player,enemy) 
 sfx(9)
 player.change.wall=22 
end

function card09(player,enemy) 
 sfx(9)
 player.change.castle=20 
end

function card10(player,enemy) 
 sfx(9)
 player.change.castle=32 
end

function card11(player,enemy)
 sfx(10)
 attack(3,enemy)
end

function card12(player,enemy) 
 sfx(10)
 attack(5,enemy)
end

function card13(player,enemy) 
 sfx(10)
 attack(8,enemy)
end

function card14(player,enemy) 
 sfx(10)
 attack(10,enemy)
end

function card15(player,enemy) 
 sfx(11)
 player.change.soldiers=1 
end

function card16(player,enemy)
 sfx(10)
 attack(14,enemy)
end

function card17(player,enemy)
 sfx(7)
 change_resources(-4,enemy) 
end

function card18(player,enemy)
 sfx(7)
 player.change.bricks=min(5,enemy.bricks)
 player.change.weapons=min(5,enemy.weapons)
 player.change.crystals=min(5,enemy.crystals)
 enemy.change.bricks=max(-5,-enemy.bricks)
 enemy.change.weapons=max(-5,-enemy.weapons)
 enemy.change.crystals=max(-5,-enemy.crystals)
end

function card19(player,enemy)
 sfx(10)
 enemy.change.castle=-10 
end

function card20(player,enemy)
 sfx(10)
 attack(32,enemy)
end

function card21(player,enemy)
 sfx(12)
 enemy.change.crystals=-8
end

function card22(player,enemy)
 sfx(12)
 enemy.change.weapons=-8 
end

function card23(player,enemy)
 sfx(12)
 enemy.change.bricks=-8
end

function card24(player,enemy)
 sfx(8)
 player.change.crystals=8 
end

function card25(player,enemy)
 sfx(8)
 player.change.bricks=8 
end

function card26(player,enemy)
 sfx(8)
 player.change.weapons=8 
end

function card27(player,enemy)
 sfx(11)
 player.change.magi=1 
end

function card28(player,enemy)
 sfx(10)
 attack(25,enemy)
end

function card29(player,enemy) 
 sfx(9)
 player.change.castle=22 
end

function card30(player,enemy)
 sfx(6)
 change_all(-1,enemy)
 change_all(1,player) 
end

function attack(damage,player)
 if player.wall>=damage then
  player.change.wall=-damage
 else
  player.change.castle=player.wall-damage
  player.change.wall=-player.wall
 end 
end

function change_resources(amount,player)
 player.change.bricks=amount 
 player.change.weapons=amount 
 player.change.crystals=amount
end

function change_all(amount,player)
 change_resources(amount,player)
 player.change.builders=amount 
 player.change.soldiers=amount 
 player.change.magi=amount
 player.change.castle=amount
 player.change.wall=amount
end

function apply_all_changes()
 apply_changes(player_red)
 apply_changes(player_blue)
end

function apply_changes(player)
 player.builders+=player.change.builders
 player.bricks+=player.change.bricks
 player.soldiers+=player.change.soldiers
 player.weapons+=player.change.weapons
 player.magi+=player.change.magi
 player.crystals+=player.change.crystals
 player.castle+=player.change.castle
 player.wall+=player.change.wall
 check_resources(player)
 reset_change(player)
end

function check_resources(player)
 if(player.bricks<0) player.bricks=0
 if(player.weapons<0) player.weapons=0
 if(player.crystals<0) player.crystals=0
 if(player.builders<1) player.builders=1
 if(player.soldiers<1) player.soldiers=1
 if(player.magi<1) player.magi=1
 if(player.wall<0) player.wall=0
end

function reset_change(player)
 player.change.builders=0
 player.change.bricks=0
 player.change.soldiers=0
 player.change.weapons=0
 player.change.magi=0
 player.change.crystals=0
 player.change.castle=0
 player.change.wall=0
end

function create_card(resource,price,description,image_sprite,index)
 local card={}
 card.description=description
 card.resource=resource
 card.price=price
 card.image_sprite=image_sprite
 card.index=index
 return card
end

function init_players()
 player_red=init_player()
 player_blue=init_player()
end

function init_player(player)
 local player={}
 player.castle=30
 player.wall=10
 player.builders=2
 player.bricks=5
 player.soldiers=2
 player.weapons=5
 player.magi=2
 player.crystals=5
 player.cards={}
 player.change={builders=0,bricks=0,soldiers=0,weapons=0,magi=0,crystals=0,castle=0,wall=0}
 return player
end

function create_random_card(player_cards)
 repeat
	local i=flr(rnd(83))+1
	 
	 if     i>=1 and i<=4 then index=1
	 elseif i>=5 and i<=8 then index=2
	 elseif i>=9 and i<=12 then index=3
	 elseif i>=13 and i<=16 then index=4
	 elseif i>=17 and i<=19 then index=5
	 elseif i>=20 and i<=21 then index=6
	 elseif i>=22 and i<=25 then index=7
	 elseif i>=26 and i<=30 then index=8
	 elseif i>=31 and i<=33 then index=9
	 elseif i>=34 and i<=36 then index=10
	 elseif i>=37 and i<=39 then index=11
	 elseif i>=40 and i<=42 then index=12
	 elseif i>=43 and i<=45 then index=13
	 elseif i>=46 and i<=48 then index=14
	 elseif i>=49 and i<=52 then index=15
	 elseif i>=53 and i<=55 then index=16
	 elseif i>=56 and i<=58 then index=17
	 elseif i>=59 and i<=61 then index=18
	 elseif i>=62 and i<=63 then index=19
	 elseif i>=64 and i<=67 then index=20
	 elseif i>=68 and i<=69 then index=21
	 elseif i==70 then index=22
	 elseif i==71 then index=23
	 elseif i>=72 and i<=73 then index=24
	 elseif i>=74 and i<=76 then index=25
	 elseif i==77 then index=26
	 elseif i==78 then index=27
	 elseif i>=79 and i<=80 then index=28
	 elseif i>=81 and i<=82 then index=29
	 else index=30
	 end
	 
	 for j=1,7 do
	  if (player_cards[j]!=nil and player_cards[j].index == index) then
	   index=0
	  end
	 end
	 
 until index>0
 
 return cards[index]
end

function _update()
 update_delaytimer()

 if gamestate=="running" then
  if (ingamestate=="player_draw_cards") update_player_draw_cards()
  if (ingamestate=="player_update_resources") update_player_resources()
  if (ingamestate=="player_card_selection") update_player_card_selection()
  if (ingamestate=="player_card_selected") update_player_card_selected()
  if (ingamestate=="player_card_discarding") update_player_card_discarding()
  if (ingamestate=="player_card_playing") update_player_card_playing()
  if (ingamestate=="player_check_victory") update_player_check_victory()
  if (ingamestate=="enemy_update_resources") update_enemy_resources()
  if (ingamestate=="enemy_draw_cards") update_enemy_draw_cards()
  if (ingamestate=="enemy_card_selection") update_enemy_card_selection()
  if (ingamestate=="enemy_card_selected") update_enemy_card_selected()
  if (ingamestate=="enemy_card_discarding") update_enemy_card_discarding()
  if (ingamestate=="enemy_card_playing") update_enemy_card_playing()
  if (ingamestate=="enemy_check_victory") update_enemy_check_victory()
 end
 
 if gamestate=="titlescreen" then 
  update_input_for_titlescreen()
  update_keys()
 end
 
 if sub(gamestate,0,5)=="howto" then 
  update_input_for_howtoplay()
  update_keys()
 end
 
 if gamestate=="victory_red" or gamestate=="victory_blue" then 
  update_input_for_gameover()
 end
 
 update_keys()
 update_clouds()
end

function update_keys()
 keydown[0]=btn(0,0)
 keydown[1]=btn(1,0)
 keydown[2]=btn(2,0)
 keydown[3]=btn(3,0)
 keydown[4]=btn(4,0)
 keydown[5]=btn(5,0)
end

function update_clouds()
 foreach(clouds,update_cloud)
end

function update_cloud(cloud)
 if cloud.x > 128 then 
  recreate_cloud(cloud)
 end
 
 if (frame%cloud.speed==0) cloud.x+=1 
 
 if (frame%30==0) then
  local move=flr(rnd(5))+1
  if (move==2) cloud.y+=(flr(rnd(3)))-1.5
 end
end

function update_delaytimer()
 if delaytimer.active then
  if delaytimer.delay<=0 then
   delaytimer.active=false
   delaytimer.expired=true
  else
   delaytimer.delay-=1
  end
 end
end

function start_delaytimer(delay)
 delaytimer.delay=delay
 delaytimer.active=true
 delaytimer.expired=false
end

function reset_delaytimer()
 delaytimer.active=false
 delaytimer.expired=false
end

function update_input_for_titlescreen()
 if (btnp(4,0) and keydown[4]==false) then 
  music(-1)
  sfx(0)
  gamestate="running"
  init_game()
 end
 
 if (btnp(5,0) and keydown[5]==false) then
  if (difficulty == "normal") then
	difficulty = "hard"
  elseif (difficulty == "hard") then
	difficulty = "easy"
  else
	difficulty = "normal"
  end
 end
 
 if (btnp(1,0) and keydown[1]==false) then 
  sfx(0)
  gamestate="howtoplay1"
 end
end

function update_input_for_gameover()
 if (btnp(4,0) and keydown[4]==false) or (btnp(5,0) and keydown[5]==false) then 
  gamestate="titlescreen"
 end
end

function update_input_for_howtoplay()
 if (btnp(1,0) and keydown[1]==false) then 
  sfx(0)
  if (gamestate=="howtoplay4") gamestate="titlescreen"
  if (gamestate=="howtoplay3") gamestate="howtoplay4"
  if (gamestate=="howtoplay2") gamestate="howtoplay3"
  if (gamestate=="howtoplay1") gamestate="howtoplay2"
 end
end

function update_player_resources()
 showchanges=false
 if delaytimer.active==false then
  if delaytimer.expired==false then
   start_delaytimer(15)
  else
   reset_delaytimer()
   update_resources(player_red)
   ingamestate="player_draw_cards"
  end
 end
end

function update_player_draw_cards()
 -- draw cards
 while count(player_red.cards)<7 do
  add(player_red.cards,create_random_card(player_red.cards))
 end

 -- set selected card index to 1
 selected_card_index = 1
 
 -- switch to card selection
 ingamestate="player_card_selection"
end

function update_player_card_selection()
 -- switch to next left card
 if (btnp(0, 0)) then
  sfx(5)
  selected_card_index-=1
  if selected_card_index<1 then 
   selected_card_index=7
  end
 end
 -- switch to next right card
 if (btnp(1, 0)) then
  sfx(5)
  selected_card_index+=1
  if selected_card_index>7 then 
   selected_card_index=1
  end
 end
 -- select current card (press x or o)
 if (btnp(4,0) and keydown[4]==false) or (btnp(5,0) and keydown[5]==false) then
  ingamestate="player_card_selected"
 end
 -- discard current card (press down)
 if (btnp(3,0) and keydown[3]==false) then
  ingamestate="player_card_discarding"
  sfx(13)
 end
end

function update_player_card_selected()
 -- check if card cost can be payed
 if canplay(player_red,player_red.cards[selected_card_index]) then
  ingamestate="player_card_playing"
 else
  ingamestate="player_card_discarding"
  sfx(13)
 end
end

function canplay(player,card)
 if card.resource=="bricks" then
  return player.bricks >= card.price
 end
 if card.resource=="weapons" then
  return player.weapons >= card.price
 end
 if card.resource=="crystals" then
  return player.crystals >= card.price
 end
end

function update_player_card_discarding()
 -- remove card from players hand
 del(player_red.cards,player_red.cards[selected_card_index])
 -- switch to enemy update resources
 ingamestate="enemy_update_resources"
end

function update_player_card_playing()
 if delaytimer.active==false then
  if delaytimer.expired==false then
   -- trigger card effect
   play_card(player_red,player_blue,player_red.cards[selected_card_index])
   -- remove card from players hand
   del(player_red.cards,player_red.cards[selected_card_index])
   -- switch to victory check after delay
   start_delaytimer(30)
  else 
   reset_delaytimer()
   apply_all_changes()
   ingamestate="player_check_victory"
  end
 end
end

function update_player_check_victory()
 -- player wins if his castle is 100 or more or enemy's castle is 0 or less
 if player_red.castle>=100 or player_blue.castle<=0 then 
  if delaytimer.active==false then
   if delaytimer.expired==false then
    start_delaytimer(60)
   else
    reset_delaytimer()
    gamestate="victory_red"
   end
  end
 else
  -- switch to gameover or enemy update resources
  ingamestate="enemy_update_resources"
 end
end

function update_enemy_resources()
 showchanges=false
 if delaytimer.active==false then
  if delaytimer.expired==false then
   start_delaytimer(15)
  else
   reset_delaytimer()
   update_resources(player_blue)
   ingamestate="enemy_draw_cards"
  end
 end
end

function update_enemy_draw_cards()
 -- draw new cards
 while count(player_blue.cards)<7 do
  add(player_blue.cards,create_random_card(player_blue.cards))
 end

 -- switch to card selection
 ingamestate="enemy_card_selection"
end

function update_enemy_card_selection()
 if (hasplayablecards(player_blue)) then
  if (difficulty == "easy") then 
	switch_to_playstrategy_easy()
  elseif (difficulty == "normal") then
    switch_to_playstrategy_normal()
  else
    switch_to_playstrategy_hard()
  end
 else
  sfx(13)
  
  if (difficulty == "easy") then 
	switch_to_discardstrategy_easy()
  elseif (difficulty == "normal") then
    switch_to_discardstrategy_normal()
  else
    switch_to_discardstrategy_hard()
  end
 end
 -- switch to selected
 ingamestate="enemy_card_selected"
end

function hasplayablecards(player)
 for i=1,7 do
  if (canplay(player,player.cards[i])) return true
 end
 return false
end

function switch_to_playstrategy_easy()
  -- play a random card
  for i=1,7 do
   if (canplay(player_blue,player_blue.cards[i])) then
	selected_card_index=i
   end
  end
end

function switch_to_playstrategy_normal()
  selected_card_index=1
  if play_resource_upgrade(player_blue,player_blue.cards)==false then
    if play_attack(player_blue,player_blue.cards,player_red)==false then
      if play_expensive(player_blue,player_blue.cards)==false then
	    for i=1,7 do
	      if (canplay(player_blue,player_blue.cards[i])) then
	        selected_card_index=i
	      end
	    end
	  end
    end
  end
end

function switch_to_playstrategy_hard()
 selected_card_index=1
 if play_resource_upgrade(player_blue,player_blue.cards)==false then
  if play_castle_upgrade(player_blue,player_blue.cards)==false then
   if play_attack(player_blue,player_blue.cards,player_red)==false then
    if play_expensive(player_blue,player_blue.cards)==false then
	 if play_crush(player_blue,player_blue.cards,player_red)==false then
	  for i=1,7 do
	   if (canplay(player_blue,player_blue.cards[i])) then
	    selected_card_index=i
	   end
	  end
	 end
	end
   end
  end
 end
end

function play_resource_upgrade(player,cards)
 for i=1,7 do
  if (cards[i].index==6 or cards[i].index==15 or cards[i].index==27) and canplay(player,cards[i]) then
   selected_card_index=i
   return true
  end
 end
 return false
end

-- if castle is low, prefer to play bricks card
function play_castle_upgrade(player,cards)
 if player.castle<25 then
  for i=1,7 do
   if cards[i].index<11 and canplay(player,cards[i]) then
    selected_card_index=i
    return true
   end
  end
 end
 return false
end

-- if enemy castle is high, prefer to play attack card
function play_attack(player, cards, enemy)
 if enemy.castle>66 then
  for i=1,7 do
   if ((cards[i].index>10 and cards[i].index<21) or cards[i].index==28) and canplay(player,cards[i]) then
    selected_card_index=i
    return true
   end
  end
 end
 return false
end

-- play an expensive card
function play_expensive(player, cards)
 for i=1,7 do
  if (cards[i].price>=10 and canplay(player,cards[i])) then
   selected_card_index=i
   return true
  end
 end
 return false
end

-- play card to reduce enemy's resources
function play_crush(player, cards, enemy)
 for i=1,7 do
  if cards[i].index==21 and enemy.crystals>9 then
   selected_card_index=i
   return true
  end
  if cards[i].index==22 and enemy.weapons>9 then
   selected_card_index=i
   return true
  end
  if cards[i].index==23 and enemy.bricks>9 then
   selected_card_index=i
   return true
  end
 end
 return false
end

function switch_to_discardstrategy_easy()
 -- discard a random card
 selected_card_index=flr(rnd(7))+1 -- discard some random card
end

function switch_to_discardstrategy_normal()
 local cardindex = get_most_expensive_card(player_blue.cards)
 -- discard most expensive card 
  selected_card_index=cardindex
end

function switch_to_discardstrategy_hard()
 local cardindex = get_most_expensive_card(player_blue.cards)
 if player_blue.cards[cardindex].index!=6 and player_blue.cards[cardindex].index!=15 and player_blue.cards[cardindex].index!=27 and player_blue.cards[cardindex].index!=30 and is_card_playable_next_round(player_blue,player_blue.cards[cardindex])==false then
  -- 1. discard most expensive card if it is expendable
  selected_card_index=cardindex
 else
  -- 2. random card with descending degrees of expendability
  cardindex=flr(rnd(7))+1
  if player_blue.cards[cardindex].index!=6 and player_blue.cards[cardindex].index!=15 and player_blue.cards[cardindex].index!=27 and player_blue.cards[cardindex].index!=30 and is_card_playable_next_round(player_blue,player_blue.cards[cardindex])==false then
   selected_card_index=cardindex
  else
   cardindex=flr(rnd(7))+1
   if is_card_playable_next_round(player_blue,player_blue.cards[cardindex])==false then
    selected_card_index=cardindex
   else
    selected_card_index=flr(rnd(7))+1 -- discard some random card
   end
  end
 end
end

function get_most_expensive_card(cards)
 local cardindex=1
 for i=1,7 do
  for j=1,7 do
   if (cards[i].price<cards[j].price) cardindex=j
  end
 end
 return cardindex
end

function is_card_playable_next_round(player,card)
 if (card.resource=="bricks") return card.price <= player.bricks+player.builders
 if (card.resource=="weapons") return card.price <= player.weapons+player.soldiers
 if (card.resource=="crystals") return card.price <= player.crystals+player.magi
end

function update_enemy_card_selected()
 -- check if enemy can pay the card cost 
 -- switch to card playing or card discarding
 if canplay(player_blue,player_blue.cards[selected_card_index]) then
  if delaytimer.active==false then
   if delaytimer.expired==false then
    -- start timer for displaying info about played card 
    enemy_action="blue ("..difficulty..") plays"
	start_delaytimer(60)
   else
    reset_delaytimer()
    ingamestate="enemy_card_playing"
   end
  end
 else
  if delaytimer.active==false then
   if delaytimer.expired==false then
    -- start timer for displaying info about discarded card 
    enemy_action="blue ("..difficulty..") discards"
	start_delaytimer(60)
   else
    reset_delaytimer()
    ingamestate="enemy_card_discarding"
   end
  end 
 end
end

function update_enemy_card_discarding()
   -- remove card from enemy's hand
   del(player_blue.cards,player_blue.cards[selected_card_index])
   -- switch to player update resources
   ingamestate="player_update_resources"
end

function update_enemy_card_playing()
 if delaytimer.active==false then
  if delaytimer.expired==false then
   -- trigger card effect
   play_card(player_blue,player_red,player_blue.cards[selected_card_index])
   -- switch to victory check after delay
   start_delaytimer(30)
  else
   -- remove card from enemy's hand
   del(player_blue.cards,player_blue.cards[selected_card_index])
   reset_delaytimer()
   apply_all_changes()
   ingamestate="enemy_check_victory"
  end
 end
end

function update_enemy_check_victory()
 -- enemy wins if his castle is 100 or more or players castle is 0 or less 
 if player_blue.castle>=100 or player_red.castle<=0 then
  if delaytimer.active==false then
   if delaytimer.expired==false then
    start_delaytimer(60)
   else
    reset_delaytimer()
    gamestate="victory_blue"
   end
  end 
 else
  -- switch to gameover state or player update resources
  ingamestate="player_update_resources"
 end
end

function update_resources(player)
 player.bricks+=player.builders
 player.weapons+=player.soldiers
 player.crystals+=player.magi
end

function play_card(player,enemy,card)
 paycard(player,card)
 
 if(card.index==1)card01(player,enemy)
 if(card.index==2)card02(player,enemy)
 if(card.index==3)card03(player,enemy)
 if(card.index==4)card04(player,enemy)
 if(card.index==5)card05(player,enemy)
 if(card.index==6)card06(player,enemy)
 if(card.index==7)card07(player,enemy)
 if(card.index==8)card08(player,enemy)
 if(card.index==9)card09(player,enemy)
 if(card.index==10)card10(player,enemy)
 if(card.index==11)card11(player,enemy)
 if(card.index==12)card12(player,enemy)
 if(card.index==13)card13(player,enemy)
 if(card.index==14)card14(player,enemy)
 if(card.index==15)card15(player,enemy)
 if(card.index==16)card16(player,enemy)
 if(card.index==17)card17(player,enemy)
 if(card.index==18)card18(player,enemy)
 if(card.index==19)card19(player,enemy)
 if(card.index==20)card20(player,enemy)
 if(card.index==21)card21(player,enemy)
 if(card.index==22)card22(player,enemy)
 if(card.index==23)card23(player,enemy)
 if(card.index==24)card24(player,enemy)
 if(card.index==25)card25(player,enemy)
 if(card.index==26)card26(player,enemy)
 if(card.index==27)card27(player,enemy)
 if(card.index==28)card28(player,enemy)
 if(card.index==29)card29(player,enemy)
 if(card.index==30)card30(player,enemy)
 
 showchanges=true
end

function paycard(player,card)
 if card.resource=="bricks" then 
  player.bricks-=card.price
 end
 if card.resource=="weapons" then 
  player.weapons-=card.price
 end
 if card.resource=="crystals" then 
  player.crystals-=card.price
 end
end

function _draw()
 cls()
 
 if (gamestate=="titlescreen") draw_titlescreen()
 if (gamestate=="howtoplay1") draw_howtoplay1()
 if (gamestate=="howtoplay2") draw_howtoplay2()
 if (gamestate=="howtoplay3") draw_howtoplay3()
 if (gamestate=="howtoplay4") draw_howtoplay4()
 
 if gamestate=="running" then
  draw_background()
  draw_castles()
  draw_resources()
  draw_cards()
  draw_changes()
 end
 
 if (gamestate=="victory_red") draw_victory_red()
 if (gamestate=="victory_blue") draw_victory_blue()
 
 frame=(frame+1)%30
end

function draw_titlescreen()
 palt(0,false)
 map(0,0,0,0,16,16)
 
 local flagoffset=0
 if (frame < 15) flagoffset=1
 spr(14+flagoffset,24,98)
 spr(16+flagoffset,96,98)
 
 draw_redmage(4,110)
 draw_bluemage(116,110)
 
 print("a game by nicopico",28,44,8)
 print("\142 - start",14,64,0)
 print("\151 - difficulty = "..difficulty,14,74,0)
 print("\145",14,84,0)
 print("- how to play",26,84,0)
end

function draw_redmage(x,y)
 palt(15,true)
 if frame<15 then
  spr(132,x,y)
  spr(133,x,y+8)
 else
  spr(134,x,y)
  spr(135,x,y+8)
 end 
 palt(15,false)
end

function draw_bluemage(x,y)
 palt(15,true)
 if frame<15 then
  spr(136,x,y)
  spr(137,x,y+8)
 else
  spr(138,x,y)
  spr(139,x,y+8)
 end 
 palt(15,false)
end

function draw_howtoplay1()
 rectfill(0,0,127,127,0)
 local textcolor=7
 print("how to play picomage (1/4)", 0, 1, textcolor)
 print("--------------------------", 0, 6, textcolor)
 print("1. the goal",0,18,textcolor)
 print("mage of the red castle,",0,25,textcolor)
 print("your goal is to defeat the mage",0,32,textcolor)
 print("of the blue castle. this can be",0,39,textcolor)
 print("achived by building you castle",0,46,textcolor)
 print("up to a height of 100 or by",0,54,textcolor)
 print("bringing your opponent's castle",0,61,textcolor)
 print("down to zero.",0,68,textcolor)
 print("the mages take turns in playing",0,82,textcolor)
 print("cards for building their castle,",0,89,textcolor)
 print("summoning attackers or casting",0,96,textcolor)
 print("powerful spells.",0,103,textcolor)
 print("press \145 to continue",0,117,10)
end

function draw_howtoplay2()
 palt(15,true)
 rectfill(0,0,127,127,0)
 local textcolor=7
 print("how to play picomage (2/4)",0,1,textcolor)
 print("--------------------------",0,6,textcolor)
 print("2. play cards",0,18,textcolor)
 print("each card requires a certain",0,25,textcolor)
 print("amount of resources to be payed",0,32,textcolor)
 print("in order to play it. you have",0,39,textcolor)
 print("three different resources:",0,46,textcolor)
 spr(0,0,54)
 print("   bricks   - for building",0,56,textcolor)
 spr(1,0,62)
 print("   weapons  - for attacking",0,64,textcolor)
 spr(2,0,70)
 print("   crystals - for magic spells",0,72,textcolor)
 print("if you have not enough resources",0,82,textcolor)
 print("to pay for a card, you can also",0,89,textcolor)
 print("discard that card instead of",0,96,textcolor)
 print("playing it.",0,103,textcolor)
 print("press \145 to continue",0,117,10)
end

function draw_howtoplay3()
 palt(15,true)
 rectfill(0,0,127,127,0)
 local textcolor=7
 print("how to play picomage (3/4)",0,1,textcolor)
 print("--------------------------",0,6,textcolor)
 print("3. fill up resources",0,18,textcolor)
 print("you may wonder how you get those",0,25,textcolor)
 print("resources you need.",0,32,textcolor)
 print("luckily you have your servants",0,39,textcolor)
 print("to help you out:",0,46,textcolor)
 spr(3,0,54)
 print("   builders - generate bricks",0,56,textcolor)
 spr(4,0,62)
 print("   soldiers - generate weapons",0,64,textcolor)
 spr(5,0,70)
 print("   magi     - generate crystals",0,72,textcolor)
 print("at the beginning of each of your",0,82,textcolor)
 print("turns you get new bricks, weapons",0,89,textcolor)
 print("and crystals based on the number",0,96,textcolor)
 print("of builders, soldiers and magi.",0,103,textcolor)
 print("press \145 to continue", 0, 117, 10)
 palt(15,false)
end

function draw_howtoplay4()
 palt(15,true)
 rectfill(0,0,127,127,0)
 local textcolor=7
 print("how to play picomage (4/4)",0,1,textcolor)
 print("--------------------------",0,6,textcolor)
 print("you can discard a card instead",0,18,textcolor)
 print("of playing it by pressing the",0,25,textcolor)
 print("\x83 key when it is selected.",0,32,textcolor)
 print("",0,39,textcolor)
 print("",0,46,textcolor)
 print("",0,53,textcolor)
 print("",0,60,textcolor)
 print("",0,67,textcolor)
 print("",0,74,textcolor)
 print("",0,81,textcolor)
 print("",0,88,textcolor)
 print("",0,95,textcolor)
 print("",0,102,textcolor)
 print("",0,109,textcolor)
 print("press \145 to continue", 0, 117, 10)
 palt(15,false)
end

function draw_background()
 palt(15,false)
 rectfill(0,0,127,127,15)
 
 --sky blue
 rectfill(0,0,127,40,12)
 rectfill(0,40,127,42,12)
 rectfill(0,44,127,45,12)
 line(0,47,127,47,12)
 line(0,50,127,50,12)
 line(0,54,127,54,12)
 
 -- clouds
 palt(0,true)
 foreach(clouds, function(cloud) spr(cloud.sprite,cloud.x,cloud.y) end)
 palt(0,false)
 
 for x=0,127,8 do
  spr(22,x,92)
 end
 
 palt(15,true)
end

function draw_castles()
 local flaganim=0
 if (frame < 15) flaganim=1

 if frame==0 then 
  banneranim1=flr(rnd(2))
  banneranim2=0
 end

 if frame==15 then 
  banneranim1=0
  banneranim2=flr(rnd(2))
 end
 
 draw_red_castle(flaganim,banneranim1)
 draw_blue_castle(flaganim,banneranim2)
 draw_ground()
end

function draw_red_castle(flaganim,banneranim)
 draw_wall(50,player_red.wall)
 draw_castle(25,player_red.castle,9,18+banneranim,14+flaganim)
end

function draw_blue_castle(flaganim,banneranim)
 draw_wall(70,player_blue.wall)
 draw_castle(79,player_blue.castle,10,20+banneranim,16+flaganim)
end

function draw_wall(x,height)
 for y=100-height,100,8 do
  spr(8,x,y)
 end
end

function draw_castle(x,height,tower,banner,flag)
 local y=100-height
 spr(tower,x,y)
 spr(tower,x+16,y)
 spr(11,x,y+8)
 spr(12,x+16,y+8)
 
 for i=115-height,100,8 do
  spr(13,x,i)
  spr(13,x+16,i)
  rectfill(x+8,i,x+15,i+7,6)
 end
 
 spr(banner,x+8,y+11)
 spr(flag,x+8,y+3)
end

function draw_ground()
 rectfill(0,100,127,127,3)
end

function draw_resources()
 draw_resource_info(0,14,player_red.builders,player_red.bricks,3,0,14,2)
 draw_resource_info(104,14,player_blue.builders,player_blue.bricks,3,0,14,2)
 
 draw_resource_info(0,36,player_red.soldiers,player_red.weapons,4,1,11,3)
 draw_resource_info(104,36,player_blue.soldiers,player_blue.weapons,4,1,11,3)
 
 draw_resource_info(0,58,player_red.magi,player_red.crystals,5,2,12,1)
 draw_resource_info(104,58,player_blue.magi,player_blue.crystals,5,2,12,1)

 draw_resource_info(0,80,player_red.castle,player_red.wall,6,7,9,4)
 draw_resource_info(104,80,player_blue.castle,player_blue.wall,6,7,9,4)
end

function draw_resource_info(x,y,sources,resources,source_sprite,resource_sprite,color1,color2)
 rectfill(x,y,x+23,y+18,color1)
 line(x,y+19,x+23,y+19,color2)
 spr(source_sprite,x+1,y+1)
 print(sources,x+12,y+3,0)
 spr(resource_sprite,x+1,y+10)
 print(resources,x+12,y+13,0)
end

function draw_changes()
 if showchanges then
  if (player_red.change.builders!=0) draw_change(22,15,player_red.change.builders) 
  if (player_red.change.bricks!=0) draw_change(22,25,player_red.change.bricks) 
  if (player_red.change.soldiers!=0) draw_change(22,37,player_red.change.soldiers) 
  if (player_red.change.weapons!=0) draw_change(22,47,player_red.change.weapons) 
  if (player_red.change.magi!=0) draw_change(22,59,player_red.change.magi) 
  if (player_red.change.crystals!=0) draw_change(22,69,player_red.change.crystals) 
  if (player_red.change.castle!=0) draw_change(22,81,player_red.change.castle) 
  if (player_red.change.wall!=0) draw_change(22,91,player_red.change.wall) 
  if (player_blue.change.builders!=0) draw_change(89,15,player_blue.change.builders) 
  if (player_blue.change.bricks!=0) draw_change(89,25,player_blue.change.bricks) 
  if (player_blue.change.soldiers!=0) draw_change(89,37,player_blue.change.soldiers) 
  if (player_blue.change.weapons!=0) draw_change(89,47,player_blue.change.weapons) 
  if (player_blue.change.magi!=0) draw_change(89,59,player_blue.change.magi) 
  if (player_blue.change.crystals!=0) draw_change(89,69,player_blue.change.crystals) 
  if (player_blue.change.castle!=0) draw_change(89,81,player_blue.change.castle) 
  if (player_blue.change.wall!=0) draw_change(89,91,player_blue.change.wall)
 end
end

function draw_change(x,y,number)
 rectfill(x+1,y+1,x+13,y+7,7)
 rect(x,y,x+14,y+8,1)
 if (number<-9) print(number,x+2,y+2,0)
 if ((number>-10 and number<0) or number>9) print(number,x+4,y+2,0)
 if (number>=0 and number<10) print(number,x+6,y+2,0)
end

function draw_cards()
 if (sub(ingamestate,0,6)=="player") then
  for i=0,6 do
   if player_red.cards[i+1] != nil then
    draw_card(i*18+1,101,player_red.cards[i+1],canplay(player_red,player_red.cards[i+1])==false)
   end
  end
 else
  for i=0,6 do
   draw_cardback(i*18+1,101)
  end
 end
 
 rectfill(0,121,127,127,7)
 
 if (ingamestate=="player_card_selection") draw_card_selector()
 if (ingamestate=="enemy_card_selected") draw_enemy_card() 
end

function draw_card(x,y,card,disable)
 draw_cardback(x,y)
 
 spr(card.image_sprite,x+1,y+11)
 spr(card.image_sprite+1,x+9,y+11)

 -- draw disabled pattern for card that is too expensive to play right now
 if (disable) then
  spr(23,x+1,y+1)
  spr(23,x+9,y+1)
  spr(23,x+1,y+9)
  spr(23,x+9,y+9)
  spr(23,x+1,y+17)
  spr(23,x+9,y+17)
 end

 draw_card_resource(card.resource,card.price,x+1,y+1)
end

function draw_card_resource(resource,price,x,y)
 if (resource=="bricks") spr(0,x,y)
 if (resource=="weapons") spr(1,x,y)
 if (resource=="crystals") spr(2,x,y)
 print(price,x+9,y+2,0)
end

function draw_cardback(x,y)
 line(x+1,y,x+16,y,7)
 line(x,y+1,x,y+21,7)
 line(x+17,y+1,x+17,y+21,13)
 line(x+1,y+22,x+16,y+22,13)
 rectfill(x+1,y+1,x+16,y+21,6)
end

function draw_card_selector()
 local color=9
 if (frame<7 or (frame>=15 and frame<23)) color=10
 rect(1+(selected_card_index-1)*18,101,selected_card_index*18,120,color)
 
 print(player_red.cards[selected_card_index].description,2,122,0)
 
 print("your turn, red mage",26,4,2)
end

function draw_enemy_card()
 local y=8
 if enemy_action=="blue ("..difficulty..") discards" then 
  rectfill(3,y+1,124,y+40,2)
 end
 if enemy_action=="blue ("..difficulty..") plays" then 
  rectfill(3,y+1,124,y+40,12)
 end
 rect(2,y,125,y+41,0)
 print(enemy_action,64-#enemy_action*2,y+2,0)
 draw_card(55,y+10,player_blue.cards[selected_card_index], false)
 print(player_blue.cards[selected_card_index].description,64-#player_blue.cards[selected_card_index].description*2,y+35,0)
end

function draw_victory_red()
 palt(0,false)
 palt(15,false)
 map(32,0,0,0,16,16)
 
 --sky red
 rectfill(0,27,127,29,8)
 rectfill(0,32,127,33,8)
 line(0,35,127,35,8)
 line(0,37,127,37,8)
 
 local flagoffset=0
 if (frame < 15) flagoffset=1
 spr(14+flagoffset,24,90)
 
 draw_redmage(4,110)
 
 print("you win !!!",43,57,0)
 print("press \142 or \151 to continue", 13, 67, 0)
end

function draw_victory_blue()
 palt(0,false)
 palt(15,false)
 map(16,0,0,0,16,16)
 
 --sky blue
 rectfill(0,27,127,29,12)
 rectfill(0,32,127,33,12)
 line(0,35,127,35,12)
 line(0,37,127,37,12)
 
 local flagoffset=0
 if (frame < 15) flagoffset=1
 spr(16+flagoffset,96,90)
 
 draw_bluemage(116,110)
 
 print("you have been defeated.",18,57,0)
 print("press \142 or \151 to continue", 13, 67, 0)
end
__gfx__
ff0000fffffff000fff00ffff000000ff000000fffff0000ff0ff0fff000000feee8eee8fff00ffffff00ffff000000ff000000f067666d0f2f88ffff288ffff
f0eeee0ff0ff0670ff07c0ff0ee888800b7bb330ffff0cc0f080080f0eee8ee0e888e882fff00ffffff00fff07766dd007766dd007766dd0f028828ff08828ff
0e8888200b006750f077cc0f0ee8882007bb3330ffff0910088008800e88e880e888e882ff0ee0ffff0660ff067666d0067666d0067666d0f0288282f0882828
0e8888200bb6750f0777cc10088888200b033030fff00000066006600e88e880e888e882ff0e80ffff06c0fff0676d0660676d0f07766dd0f228828ff288282f
0e888820f0bb50ff07cc1110f00dd00f0b000030ff040fff066666600eeeeee0eeeeeee8f0e8820ff06cc10ff077dd066077dd0f067666d0f02ff2fff0ff2fff
0e8888200bb330fff0cc110fff0dd0ff0bb00330f040ffff066006600e888880e8888882f0e8820ff06cc10ff0676d0660676d0f07766dd0f0fffffff0ffffff
f022220f0b30330fff0c10ffff0dd0fff0b0030f040fffff060550600e888880e88888820e88882006cccc10f077dd066077dd0f067666d0f0fffffff0ffffff
ff0000fff00f00fffff00ffffff00fffff0ff0ff00ffffff00000000f000000fe8888882088888200ccccc10f0676d0660676d0f07766dd0f0fffffff0ffffff
f1ddfffff1fddfff02200220022002200110011001100110ffffffff7f7f7f7f8f8fffff888888888f8f8f8fcccccccccfcfcfcfffffcfcfffffffffffffffff
f0dd1dfff01dd1df48466484484664844c4664c44c4664c4fffffffff7f7f7f7f8f8ffff88888888f8f8f8f8ccccccccfcfcfcfcfffffcfcffffffffffffffff
f0dd1d1df01dd1d1d288882dd888882dd1cccc1ddccccc1daaaaaaaa7f7f7f7f8f8fffff888888888f8f8f8fcccccccccfcfcfcfffffcfcfaaaaaaaaaaaaaaaa
f1dd1d1ff11dd1df6d8e28d668e288d66dc16cd66c61ccd6bbbbbbbbf7f7f7f7f8f8ffff88888888f8f8f8f8ccccccccfcfcfcfcfffffcfcbbbbbbbbbb6bbbbb
f0ff1ffff01ff1ff6682e86668e88d6666c61c666c6ccd66bbbbbbbb7f7f7f7f8f8fffff8f8f8f8f88888888cfcfcfcfccccccccffffcfcfbbbe8ebbb675dbbb
f0fffffff0ffffff668888666888866666cccc666cccc66633333333f7f7f7f7f8f8fffff8f8f8f888888888fcfcfcfcccccccccfffffcfc333888333d666d53
f0fffffff0ffffff66d88d66688d666666dccd666ccd6666333333337f7f7f7f8f8fffff8f8f8f8f88888888cfcfcfcfccccccccffffcfcf33882883d665d6d3
f0fffffff0ffffff666dd66666d66666666dd66666d6666633333333f7f7f7f7f8f8fffff8f8f8f888888888fcfcfcfcccccccccfffffcfc822222825d6d5d55
6666666666666666666663bb6666bbb6600000066666666666dd6666b33666666666666666666666666665000000666666666535666666666666b33b11366666
66b3166b3166b316636363b0666b4b0b0b7bb330663bb36666d3d66bb3336666666660006666666666665000ff00566666666d366666b7666666311100166666
b6505b6505b650563665613666bb4bbb07bb3330633bb336666d3ddb0303666666110066066666a666665099999006666666d6b666664b666666313b10166666
6b36d6b36d6b36d636331114444444360b0330306bbbbbb66666d31b0003666661dd111660666a9a66655022f2290066666d6636666466666666b1bb30366666
63621d3621d3621d335bb110b33366660b0000306bbbbbb66666d11db03d556661dd10166066698966650928f829006666d66426664666666666101310166666
66d11d6d11d6d11d3b53bb1b335666660bb00330633bb33666666d6d111533566110001660666606666009f949f900665d664266b46666666666100100166666
660dd660dd660dd6636333333536666660b00306663bb36666666666ddd535566100011666066066666050949490006633b3266b436666666666630003666666
65065150601506015556333665556666660660666666666666666661060155666611116666600666666656094906066656666666366666666666661316666666
669f9946666666666666666666446226cccc5c5c5ccc77cc666eeeeeeeeeeee26666666666666666666666666666666666666666666666666666666666666666
69f99442666666666666666666442666c77c55d55cc7777766e88888888888226666666666666666666666666666666666666ffffffff6666666666663bb3366
69f9999266666a96666ddd6662464666cccc5d5d5cccc77c6eeedeedeedee222666666ee2ee2666666655665566556666666ffffffffff66666666b3b3333ee2
6400f002666a9946664d556224444666cc7c55d55ccccccc6288d88d88d88222666666e82e826666666dd55dd55dd666666699999999996666666bb333332e82
69f9f4426a994a966664122466464266cccc5d5d5c77cccc62deedeedeede2226666ee2ee2ee2666666500d00d00566666669999999999666666ee33333e2ee2
69994442694a99466650546644450526cccc55d55ccccccc62d88d88d88d82226666e82e82e82666666d00500500d6666664d242dd242d666666e82e33e82e82
669f9426666946666409045555409046cccc5d5d5ccccccc62edeedeedeed22266ee2ee2ee2ee26666655dd55dd5566666465444554445666ee2ee2e32ee2ee2
6669426666666666665056666665056633bb55055333bbb3628d88d88d88d22666e82e82e82e8266666dd55dd55dd66664666242662426666e82e82e82e82e82
6000000666666666666666682666666666666666666666666666666666666666666600006666666666666a8ea66aa66666666a3ba6666aa666666adca66aa666
0ee888806628826666666688826666666666666666666666666666666666666666660cc066dccd6666666a88aaa00a6666666a33aaa6a00a66666addaaa00a66
0ee8882062288226666668888226666677757775777577756666666666666666666609106ddccdd66666692aaa0ee0a666666d2aaa0a070a6666631aaa07c0a6
088888206888888666666d88885666667665766576657665eee2eee2eee2eee2666000006cccccc666664626a0e8820a66665626a0b060a666664616a077cc0a
600dd0066888888666666ddddd5666667665766576657665e882e882e882e882660406666cccccc666646666a0e8820a666566666a0b0a6666646666a0cc110a
660dd0666228822666666dd00d5666667555755575557555e222e222e222e222604066666ddccdd6664666666a0220a666566666a05030a6664666666a0c10a6
660dd0666628826666666dd00d566666666666666666666666666666666666660406666666dccd666466666666a00a66656666666a0a0a666466666666a00a66
6660066666666666666666dddd66666666666666666666666666666666666666006666666666666696666666666aa666d666666666a6a66636666666666aa666
66553366666666666666a8a8a8a666666668886666888666666668688686666666668666688668666666866886686666ffff8f8f88888888cccccccccfcfffff
653333366633b66a66669999999966666688868668688866666866800868686686666686800866666686668008666686fffff8f888888888ccccccccfcfcffff
53128333333bba996666288888826666660f06666660f0666866680ee0866666666868080708666866666807c0868666ffff8f8f88888888cccccccccfcfffff
3118a8333bba9988666622008002666663bfb366663bfb36666680e882086866666680b06086686666668077cc086666fffff8f888888888ccccccccfcfcffff
33128333ba998888666622008002666663bbb366663bbb36668680e8820866666686680b08666666668680cc11086866ffff8f8f88888888cccccccccfcfffff
333333333bba998866666882028866663611163663611163666668022086866866668050308686866666680c10866666fffff8f888888888ccccccccfcfcffff
33333336633baa9966666628282666666616166666616166668666800868666668666808086666666866868008668668ffff8f8f88888888cccccccccfcfffff
333333666666666a66666686868666666006006666006006666686688666686666686686868668666686666886866666fffff8f888888888ccccccccfcfcffff
ffffffff88888777777777788877777777778888887777777888888777777788ccaaaaaaaaaacccaaaaaaaaaaccccccaaaaaaacccaaaaaaaaaacccccffffffff
ffffffff888887cccccccc68887cccccccc68888887ccccc68888887ccccc688cca888888889ccca888888889cccccca888889ccca888888889cccccffffffff
ffffffff888887c66666cc68887777c6666688888866666668888886666cc688cca888888889ccca899999889cccccc9999999ccca899999999ccccc00000000
ffffffff888887c68887cc68888887c6888888877788888888887778887cc688cca888888889ccca89ccca889cccaaacccccccccca89cccccccccccc66666666
ffffffff888887c68887cc68888887c688888887c688888888887c68887cc688cca888888889ccca89ccca889ccca89cccccccccca89cccccccccccc00600600
ffffffff888887c68887cc68888887c688888887c688888888887c68887cc688cca899999889ccca89ccca889ccca89cccccccccca89cccccccccccc00600600
ffffffff888887c67777cc68888887c688888887c688888888887c68887cc688cca89ccca889ccca89aaaa889ccca89cccccccccca89aaaccccccccc66666666
ffffffff888887cccccccc68888887c688888887c688888888887c68887cc688cca89ccca889ccca888888889ccca89cccccccccca88889ccccccccc66666666
66666666888887cccccccc68888887c688888887c688888888887c68887cc688cca89ccca889ccca888888889ccca89cccccccccca88889cccccccccbbbbbbbb
66666666888887c666666668888887c688888887c688888888887c68887cc688cca89ccca889ccca899999889ccca89cccccccccca89999cccccccccbbbbbbbb
66666666888887c688888888888887c688888887c688888888887c68887cc688cca89ccca889ccca89ccca889ccca89cccaaaaccca89ccccccccccccbbbbbbbb
66666666888887c688888888888887c688888887c688888888887c68887cc688cca89ccca889ccca89ccca889ccca89ccca889ccca89cccccccccccc33333333
66600666888887c688888888888887c6888888866688888888887c6888666688cca89ccca889ccca89ccca889ccca89ccca889ccca89cccccccccccc33333333
66066066888887c688888888887777c6777788888877777778887c6777888888cca89ccca889ccca89ccca889ccca89aaaa889ccca89aaaaaaaccccc33333333
66066066888887c688888888887cccccccc68888887ccccc68887cccc6888888cca89ccca889ccca89ccca889ccca888888889ccca888888889ccccc33333333
6606606688888666888888888866666666668888886666666888666666888888cc999ccc9999ccc999ccc9999ccc9999999999ccc9999999999ccccc33333333
00000000000000000000000000000000ffffffff00a00a00fff89fff40000004ffffffffcc7cc7ccfffd1fff5cccccc500000000000000000000000000000000
00000000000000000000000000000000fff89fff40000004fff88ffff990099ffffd1fff5cccccc5fff11ffffddccddf00000000000000000000000000000000
00000000000000000077000000077000fff88ffff990099ffff98ffff299992ffff11ffffddccddffff1dffff1dddd1f00000000000000000000000000000000
00000000000770000777770007777700fff98ffff299992fff8889fff289982ffff1dffff1dddd1fff111dfff1cddc1f00000000000000000000000000000000
00007700077777007777777707677700ff8889fff229922fff9888fff289982fff111dfff11dd11fffd111fff1cddc1f00000000000000000000000000000000
07777770777777700677677000666000ff9888fff289982fff8898ff28899882ffd111fff1cddc1fff11d1ff1ccddcc100000000000000000000000000000000
77777777666777770066660000000000ff8898ff228998228822229828888882ff11d1ff11cddc111d0000111cccccc100000000000000000000000000000000
06666666066666600000000000000000882222982118811200a00a00211881121d000011155cc551cc7cc7cc155cc55100000000000000000000000000000000
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
606060606060606060606060606060605e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c1a1a1a1a1a1a1a1c1c1c1c1c1c1c5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c6162636465666768696a6b6c6d6e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c7172737475767778797a7b7c7d7e5f60606060606060606060606060606060606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c191919191919191b1b1b1b1b1b1b5f60606060606060606060606060606060606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606060606060606060606060606060601d1c1c1c1c1c1c1c1c1c1c1c1c1c1c5f5c1a1a1a1a1a1a1a1a1a1a1a1a1a1a180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606060606060606060606060606060601d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f5c5d5d5d5d5d5d5d5d5d5d5d5d5d5d180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606060606060606060606060606060601d5e5e5e5e5e5e5e5e5e5e5e5e5e5e5f5c5d5d5d5d5d5d5d5d5d5d5d5d5d5d180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606060606060606060606060606060601d1b1b1b1b1b1b1b1b1b1b1b1b1b1b5f5c1919191919191919191919191919180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606060606060606060606060606060606060606060606060600a600a6060606009600960606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60600960096060606060600a600a606060606060606060606060600b6f0c606060600b6f0c60606060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60600b6f0c6008606008600b6f0c606060606060606060606008600d140d606060600d120d60086060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16160d700d1608161608160d700d161616161f161f161e161608160d700d161616160d700d160816161e161f161f16160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0102000010050170501f0501a05023050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001502200000180220000017022000001c022000001a022180221702215022180000000018000000001c0220000021022000001f0221d0221d0221c0221c0221a0221a0221802218022000001702200000
001000001502200400180221800017022004001c022004001a0221802217022150220c0000040000400004001c0220040018022180001f0221d0221c0221a0221802200400170221800015022000000000000000
00100000155240c300185240c300175240c3001c5240c3001a5241852417524155240c3040c3010c3000c300155240c3001c5240c3001f5241d5241d5241c5241c5241a5241a52418524185240c300175240c300
001000001552400000185240000017524000001c524000001a524185241752415524000000000000000000001c5240000018524000001f5241d5241c5241a5241852400000175240000015524000000000000000
0101000000520005200052002520045200552006520075200952010520175201b52000500005000150003500045000550006500095000a5000b5000c500015000250003500035000350003500035000350003500
01080000002400c240002400c240002400c2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000180502820015050112001305011000110500a200082010720105201042010220101201002010000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0109000028520295301c555210001050517000110000900004000000001c000190001700015000140000000000000020000200002000000000000000000000000000000000000000000000000000000000000000
010600000c754000001075400000137540000017754000001a754000001d754000002175400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000455300000045630000004573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900001355415554000001755418554000001a5541c554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000010575105750c5750c5750b575095050957500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000757600006075760000007576007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 01 03 43 00
02 02 04 43 44
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
