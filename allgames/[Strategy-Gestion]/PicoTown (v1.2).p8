pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
-- picotown #citysimjam
-- a game by adrian09_01
-- made for #citysimjam

-- values
mapx = 0 -- map loop
mapy = 0 -- map loop
genx = 0 -- gen loop
geny = 0 -- gen loop
cntx = 0 -- county x
cnty = 0 -- county y
x = 32 -- actual x
y = 32 -- actual y
tile = 0 -- random tile
menusel = 0 -- selection
ismenu = 10 -- menu to show
cash = 500 -- cash
energy = 0 -- generated energy
water = 0 -- generated water
sewage = 0 -- generated sewage
trash = 0 -- generated trash
residents = 32767 -- current resids.
tourists = 0 -- random tourism
taxpercent = 1 -- tax %
lastsel = 1 -- last building
lastset = 0 -- was last set?
timeh = 12 -- hours
timem = 0 -- minutes
car = 0 -- random cars
addcash = 0 -- cash added
howlongd = 0 -- city age in days
howlongm = 0 -- city age in months
howlongy = 0 -- city age in years
happiness = 0 -- happiness
speed = 1 -- game speed
palette = 0 -- palette
firepower = 0 -- fire power
crimepower = 0 -- crime power

function _update()
if (ismenu == 0) count_time()
if (ismenu == 9) prg_options_menu()
if (ismenu == 8) prg_trash_menu()
if (ismenu == 7) prg_sewage_menu()
if (ismenu == 6) prg_water_menu()
if (ismenu == 5) prg_energy_menu()
if (ismenu == 4) prg_stats_menu()
if (ismenu == 3) prg_budget_menu()
if (ismenu == 2) prg_build_menu()
if (ismenu == 1) prg_main_menu()
if (ismenu == 0) move_player()
if (ismenu == 11) prg_map_menu()
if (ismenu == 10) prg_title_menu()
end

function _draw()
draw_map()
draw_chair()
if (ismenu < 10) draw_data()
if (ismenu == 11) grp_map_menu()
if (ismenu == 9) grp_options_menu()
if (ismenu == 8) grp_trash_menu()
if (ismenu == 7) grp_sewage_menu()
if (ismenu == 6) grp_water_menu()
if (ismenu == 5) grp_energy_menu()
if (ismenu == 4) grp_stats_menu()
if (ismenu == 3) grp_budget_menu()
if (ismenu == 2) grp_build_menu()
if (ismenu == 1) grp_main_menu()
if (ismenu == 10) grp_title_menu()
end

function _init()
count_residents()
count_energy()
generate_level()
reset_values()
music(1)
end


function draw_map()
-- this function goes thru
-- the map and draws it
-- loop thru the map
for mapx=0,64,1 do
	for mapy=0,64,1 do
	 -- draw a sprite
	 spr(mget(mapx + x - 8, mapy + y - 8), mapx * 8, mapy * 8)
	end
end
end

function draw_minimap(drawx, drawy)
-- this function goes thru
-- the map and draws it
-- loop thru the map
for mapx=0,64,1 do
	for mapy=0,64,1 do
	 -- draw a sprite
	 if (mget(mapx, mapy) == 0) pset(drawx+mapx, drawy+mapy, 11)
	 if (mget(mapx, mapy) == 48) pset(drawx+mapx, drawy+mapy, 6)
	 if (mget(mapx, mapy) == 49) pset(drawx+mapx, drawy+mapy, 3)	
  if (mget(mapx, mapy) == 50) pset(drawx+mapx, drawy+mapy, 4)
  if (mget(mapx, mapy) == 51) pset(drawx+mapx, drawy+mapy, 12) 
	end
end
end

function draw_chair()
-- this function draws
-- a crosshair
spr(63, 64, 64)
end

function draw_data()
-- this function draws the
-- most important data
spr(52, 8, 8)
print(cash, 16, 10, 0)
spr(74, 40, 8)
print(residents, 48, 10, 0)
print(timeh..":"..timem, 96, 10, 0)
end

function move_player()
-- this function moves the
-- player's crosshair
if (btnp(2)) y = y - 1
if (btnp(3)) y = y + 1
if (btnp(0)) x = x - 1
if (btnp(1)) x = x + 1
if (btnp(5)) then
sfx(4)
ismenu = 1
end
menusel = 1
constraint_player()
end

function constraint_player()
-- this function checks for
-- the player's position and
-- constrains it
if (x < 0) x = 0
if (x > 64) x = 64
if (y < 0) y = 0
if (y > 64) y = 64
end

function play_music()
-- this function plays music.
music(0)
end

function generate_level()
-- this function generates
-- levels using random values
for genx=0,64,1 do
	for geny=0,64,1 do
	 -- fill with grass
	 mset(genx, geny, 0)
	end
end
for genx=0,64,1 do
	for geny=0,64,1 do
	 -- randomly get a tile
	 tile = flr(rnd(100))
	 if (tile == 0) mset(genx, geny, 0)
	 if (tile == 1) mset(genx, geny, 48)
	 if (tile == 2) mset(genx, geny, 49)
	 if (tile > 85) mset(genx, geny, 50)
  if (tile > 95) mset(genx, geny, 51)
	end
end
end

function count_residents()
-- this function counts the
-- residents in your town
-- reset the residents to 0
residents = 0
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 -- add a resident for each
	 -- inhabitable building
  if (mget(cntx, cnty) == 1) residents += 1
  if (mget(cntx, cnty) == 2) residents += 1
  if (mget(cntx, cnty) == 3) residents += 1
  if (mget(cntx, cnty) == 4) residents += 2
  if (mget(cntx, cnty) == 5) residents += 2
  if (mget(cntx, cnty) == 6) residents += 2
  if (mget(cntx, cnty) == 7) residents += 3
  if (mget(cntx, cnty) == 8) residents += 3
  if (mget(cntx, cnty) == 9) residents += 3
	end
end
end

function count_energy()
energy = 0
-- firstly count energy made
-- by power plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 34) energy += 100
 end
end
-- next count energy lost to
-- zones
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 1) energy -= 1
  if (mget(cntx, cnty) == 2) energy -= 1
  if (mget(cntx, cnty) == 3) energy -= 1
  if (mget(cntx, cnty) == 4) energy -= 2
  if (mget(cntx, cnty) == 5) energy -= 2
  if (mget(cntx, cnty) == 6) energy -= 2
  if (mget(cntx, cnty) == 7) energy -= 3
  if (mget(cntx, cnty) == 8) energy -= 3
  if (mget(cntx, cnty) == 9) energy -= 3
  if (mget(cntx, cnty) == 10) energy -= 1
  if (mget(cntx, cnty) == 11) energy -= 1
  if (mget(cntx, cnty) == 12) energy -= 1
  if (mget(cntx, cnty) == 13) energy -= 2
  if (mget(cntx, cnty) == 14) energy -= 2
  if (mget(cntx, cnty) == 15) energy -= 2
  if (mget(cntx, cnty) == 16) energy -= 3
  if (mget(cntx, cnty) == 17) energy -= 3
  if (mget(cntx, cnty) == 18) energy -= 3
  if (mget(cntx, cnty) == 19) energy -= 1
  if (mget(cntx, cnty) == 20) energy -= 1
  if (mget(cntx, cnty) == 21) energy -= 1
  if (mget(cntx, cnty) == 22) energy -= 2
  if (mget(cntx, cnty) == 23) energy -= 2
  if (mget(cntx, cnty) == 24) energy -= 2
  if (mget(cntx, cnty) == 25) energy -= 3
  if (mget(cntx, cnty) == 26) energy -= 3
  if (mget(cntx, cnty) == 27) energy -= 3
 end
end
end

function count_money()
addcash = 0
-- firstly count losses
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 31) addcash -= 50
	 if (mget(cntx, cnty) == 32) addcash -= 50
	 if (mget(cntx, cnty) == 33) addcash -= 20
	 if (mget(cntx, cnty) == 34) addcash -= 20
	 if (mget(cntx, cnty) == 35) addcash -= 20
	 if (mget(cntx, cnty) == 36) addcash -= 20
	 if (mget(cntx, cnty) == 37) addcash -= 30
	 if (mget(cntx, cnty) == 38) addcash -= 50
	 if (mget(cntx, cnty) == 39) addcash -= 25
	 if (mget(cntx, cnty) == 40) addcash -= 10
  if (mget(cntx, cnty) == 41) addcash -= 10
	 if (mget(cntx, cnty) == 42) addcash -= 10
	 if (mget(cntx, cnty) == 43) addcash -= 10
	 if (mget(cntx, cnty) == 44) addcash -= 10
	 if (mget(cntx, cnty) == 45) addcash -= 75
  if (mget(cntx, cnty) == 46) addcash -= 75
  if (mget(cntx, cnty) == 47) addcash -= 75
  if (mget(cntx, cnty) == 65) addcash -= 20
  if (mget(cntx, cnty) == 66) addcash -= 20
  if (mget(cntx, cnty) == 67) addcash -= 20
 end
end
-- next count cash gained to
-- zones
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 1) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 2) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 3) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 4) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 5) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 6) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 7) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 8) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 9) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 10) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 11) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 12) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 13) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 14) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 15) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 16) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 17) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 18) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 19) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 20) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 21) addcash += 1 * taxpercent
  if (mget(cntx, cnty) == 22) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 23) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 24) addcash += 2 * taxpercent
  if (mget(cntx, cnty) == 25) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 26) addcash += 3 * taxpercent
  if (mget(cntx, cnty) == 27) addcash += 3 * taxpercent
 end
end
addcash += tourism
cash += addcash
end


function count_sewage()
sewage = 0
-- firstly count water made
-- by water plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 33) sewage += 300
 end
end
-- next count water lost to
-- zones
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 1) sewage -= 1
  if (mget(cntx, cnty) == 2) sewage -= 1
  if (mget(cntx, cnty) == 3) sewage -= 1
  if (mget(cntx, cnty) == 4) sewage -= 2
  if (mget(cntx, cnty) == 5) sewage -= 2
  if (mget(cntx, cnty) == 6) sewage -= 2
  if (mget(cntx, cnty) == 7) sewage -= 3
  if (mget(cntx, cnty) == 8) sewage -= 3
  if (mget(cntx, cnty) == 9) sewage -= 3
  if (mget(cntx, cnty) == 10) sewage -= 1
  if (mget(cntx, cnty) == 11) sewage -= 1
  if (mget(cntx, cnty) == 12) sewage -= 1
  if (mget(cntx, cnty) == 13) sewage -= 2
  if (mget(cntx, cnty) == 14) sewage -= 2
  if (mget(cntx, cnty) == 15) sewage -= 2
  if (mget(cntx, cnty) == 16) sewage -= 3
  if (mget(cntx, cnty) == 17) sewage -= 3
  if (mget(cntx, cnty) == 18) sewage -= 3
  if (mget(cntx, cnty) == 19) sewage -= 1
  if (mget(cntx, cnty) == 20) sewage -= 1
  if (mget(cntx, cnty) == 21) sewage -= 1
  if (mget(cntx, cnty) == 22) sewage -= 2
  if (mget(cntx, cnty) == 23) sewage -= 2
  if (mget(cntx, cnty) == 24) sewage -= 2
  if (mget(cntx, cnty) == 25) sewage -= 3
  if (mget(cntx, cnty) == 26) sewage -= 3
  if (mget(cntx, cnty) == 27) sewage -= 3
 end
end
end

function count_trash()
trash = 0
-- firstly count water made
-- by water plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 33) trash += 500
 end
end
-- next count water lost to
-- zones
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 1) trash -= 1
  if (mget(cntx, cnty) == 2) trash -= 1
  if (mget(cntx, cnty) == 3) trash -= 1
  if (mget(cntx, cnty) == 4) trash -= 2
  if (mget(cntx, cnty) == 5) trash -= 2
  if (mget(cntx, cnty) == 6) trash -= 2
  if (mget(cntx, cnty) == 7) trash -= 3
  if (mget(cntx, cnty) == 8) trash -= 3
  if (mget(cntx, cnty) == 9) trash -= 3
  if (mget(cntx, cnty) == 10) trash -= 1
  if (mget(cntx, cnty) == 11) trash -= 1
  if (mget(cntx, cnty) == 12) trash -= 1
  if (mget(cntx, cnty) == 13) trash -= 2
  if (mget(cntx, cnty) == 14) trash -= 2
  if (mget(cntx, cnty) == 15) trash -= 2
  if (mget(cntx, cnty) == 16) trash -= 3
  if (mget(cntx, cnty) == 17) trash -= 3
  if (mget(cntx, cnty) == 18) trash -= 3
  if (mget(cntx, cnty) == 19) trash -= 1
  if (mget(cntx, cnty) == 20) trash -= 1
  if (mget(cntx, cnty) == 21) trash -= 1
  if (mget(cntx, cnty) == 22) trash -= 2
  if (mget(cntx, cnty) == 23) trash -= 2
  if (mget(cntx, cnty) == 24) trash -= 2
  if (mget(cntx, cnty) == 25) trash -= 3
  if (mget(cntx, cnty) == 26) trash -= 3
  if (mget(cntx, cnty) == 27) trash -= 3
 end
end
end

function count_tourism()
tourism = 0
if (happiness > 50) then
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 45) tourism += flr(rnd(100))
	 if (mget(cntx, cnty) == 46) tourism += flr(rnd(100))
  if (mget(cntx, cnty) == 47) tourism += flr(rnd(100))
  if (mget(cntx, cnty) == 65) tourism += flr(rnd(50))
	 if (mget(cntx, cnty) == 66) tourism += flr(rnd(50))
  if (mget(cntx, cnty) == 67) tourism += flr(rnd(50))
 end
end
end
end

function count_water()
water = 0
-- firstly count water made
-- by water plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 33) water += 200
 end
end
-- next count water lost to
-- zones
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 1) water -= 1
  if (mget(cntx, cnty) == 2) water -= 1
  if (mget(cntx, cnty) == 3) water -= 1
  if (mget(cntx, cnty) == 4) water -= 2
  if (mget(cntx, cnty) == 5) water -= 2
  if (mget(cntx, cnty) == 6) water -= 2
  if (mget(cntx, cnty) == 7) water -= 3
  if (mget(cntx, cnty) == 8) water -= 3
  if (mget(cntx, cnty) == 9) water -= 3
  if (mget(cntx, cnty) == 10) water -= 1
  if (mget(cntx, cnty) == 11) water -= 1
  if (mget(cntx, cnty) == 12) water -= 1
  if (mget(cntx, cnty) == 13) water -= 2
  if (mget(cntx, cnty) == 14) water -= 2
  if (mget(cntx, cnty) == 15) water -= 2
  if (mget(cntx, cnty) == 16) water -= 3
  if (mget(cntx, cnty) == 17) water -= 3
  if (mget(cntx, cnty) == 18) water -= 3
  if (mget(cntx, cnty) == 19) water -= 1
  if (mget(cntx, cnty) == 20) water -= 1
  if (mget(cntx, cnty) == 21) water -= 1
  if (mget(cntx, cnty) == 22) water -= 2
  if (mget(cntx, cnty) == 23) water -= 2
  if (mget(cntx, cnty) == 24) water -= 2
  if (mget(cntx, cnty) == 25) water -= 3
  if (mget(cntx, cnty) == 26) water -= 3
  if (mget(cntx, cnty) == 27) water -= 3
 end
end
end

function count_time()
-- this function counts time.
timem += speed
if (timem >= 60) then
timeh += 1
timem = 0
randomize_cars()
count_residents()
destroy_fire()
happiness = flr(rnd(100))+1
if (energy <= 0) happiness -= 20
if (water <= 0) happiness -= 20
if (sewage <= 0) happiness -= 10
if (trash <= 0) happiness -= 10
if (firepower <= 0) happiness -= 10
if (crimepower <= 0) happiness -= 10
if (happiness < 0) happiness = 0
if (happiness > 100) happiness = 100
end                 
if (timeh >= 24) then
count_energy()
count_water()
count_sewage()
count_trash()
count_firepower()
count_crimepower()
count_tourism()
count_money()
howlongd += 1
disaster = flr(rnd(100))
if (disaster == 0) fire_disaster()
if (disaster == 1) earthquake_disaster()
if (disaster == 2) flood_disaster()
if (disaster == 3) crime_disaster()
if (disaster == 4) terrorist_disaster()
timeh = 0
end
if (howlongd >= 31) then
howlongm += 1
howlongd = 0
end
if (howlongm >= 12) then
howlongy += 1
howlongm = 0
end
end

function count_firepower()
firepower = 0
-- firstly count water made
-- by water plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 31) firepower += 100
 end
end
end

function count_crimepower()
crimepower = 0
-- firstly count water made
-- by water plants
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 31) crimepower += 100
 end
end
end

function randomize_cars()
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 75) then mset(cntx, cnty, 28) end
	 if (mget(cntx, cnty) == 78) then mset(cntx, cnty, 29) end
	 if (mget(cntx, cnty) == 28) then car = flr(rnd(2)) end
	 if (mget(cntx, cnty) == 28) then 
	  if (car == 1) mset(cntx, cnty, 75)
  end
  if (mget(cntx, cnty) == 29) then car = flr(rnd(2)) end
	 if (mget(cntx, cnty) == 29) then 
	  if (car == 1) mset(cntx, cnty, 78)
  end
	end
end
end

function crime_disaster()
	if (flr(rnd(100+crimepower)) == 0) cash -= 500
end

function terrorist_disaster()
	if (flr(rnd(100+crimepower)) == 0) then
	 rndx = flr(rnd(64))
	 rndy = flr(rnd(64))
	 sfx(3)
	 mset(rndx-1, rndy-1, 84)
	 mset(rndx-1, rndy, 84)
	 mset(rndx-1, rndy+1, 84)
	 mset(rndx, rndy-1, 84)
	 mset(rndx, rndy, 84)
	 mset(rndx, rndy+1, 84)
	 mset(rndx+1, rndy-1, 84)
	 mset(rndx+1, rndy, 84)
	 mset(rndx+1, rndy+1, 84)
	end
end

function fire_disaster()
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (flr(rnd(100+firepower)) == 0) mset(cntx, cnty, 84)
 end
end
end

function earthquake_disaster()
rndy = flr(rnd(64))
for cntx=0,64,1 do
	 mset(cntx, rndy, 49)
end
sfx(1)
end

function flood_disaster()
rndy = flr(rnd(64))
for cntx=0,64,1 do
	 mset(cntx, rndy, 51)
end
sfx(5)
end

function destroy_fire()
for cntx=0,64,1 do
	for cnty=0,64,1 do
	 if (mget(cntx, cnty) == 84) mset(cntx, cnty, 0)
 end
end
end

function reset_values()
firepower = 0 -- fire power
crimepower = 0 -- crime power
mapx = 0 -- map loop
mapy = 0 -- map loop
genx = 0 -- gen loop
geny = 0 -- gen loop
cntx = 0 -- county x
cnty = 0 -- county y
x = 32 -- actual x
y = 32 -- actual y
tile = 0 -- random tile
menusel = 0 -- selection
ismenu = 10 -- menu to show
cash = 500 -- cash
energy = 0 -- generated energy
water = 0 -- generated water
sewage = 0 -- generated sewage
trash = 0 -- generated trash
residents = 0 -- current resids.
tourists = 0 -- random tourism
taxpercent = 1 -- tax %
lastsel = 1 -- last building
lastset = 0 -- was last set?
timeh = 12 -- hours
timem = 0 -- minutes
car = 0 -- random cars
addcash = 0 -- cash added
howlongd = 0 -- city age in days
howlongm = 0 -- city age in months
howlongy = 0 -- city age in years
happiness = 0 -- happiness
speed = 1 -- game speed
palette = 0 -- palette
-- repalette
for x=0,15 do
 pal(x,(x+palette)%16,1)
end
end

function prg_main_menu()
-- this function is the program
-- part of the main menu
if (btnp(3)) menusel += 1
if (btnp(3)) sfx(0)
if (btnp(2)) menusel -= 1
if (btnp(2)) sfx(0)
if (menusel == 0) menusel = 8
if (menusel == 9) menusel = 1
if (btnp(4)) ismenu = 0
if (btnp(5)) then
sfx(4)
ismenu = menusel + 1 
end
end

function grp_main_menu()
-- this function is the graphic
-- part of the main menu
rectfill(0, 96, 128, 128, 4)
if (menusel == 1) then
 spr(4, 8, 106)
 print("build", 18, 107, 0)
end
if (menusel == 2) then
 spr(52, 8, 106)
 print("budget", 18, 107, 0)
end
if (menusel == 3) then
 spr(53, 8, 106)
 print("city stats", 18, 107, 0)
end
if (menusel == 4) then
 spr(59, 8, 106)
 print("energy", 18, 107, 0)
end
if (menusel == 5) then
 spr(60, 8, 106)
 print("water", 18, 107, 0)
end
if (menusel == 6) then
 spr(61, 8, 106)
 print("sewage", 18, 107, 0)
end
if (menusel == 7) then
 spr(62, 8, 106)
 print("trash", 18, 107, 0)
end
if (menusel == 8) then
 spr(63, 8, 106)
 print("options", 18, 107, 0)
end
-- here function ends
end

function prg_build_menu()
-- this function is the program
-- part of the main menu
if (lastset == 0) then
menusel = lastsel
lastset = 1
end
if (btnp(3)) menusel += 1
if (btnp(3)) sfx(0)
if (btnp(2)) menusel -= 1
if (btnp(2)) sfx(0)
if (btnp(5)) lastsel = menusel
if (menusel == 0) menusel = 39
if (menusel == 40) menusel = 1
if (btnp(4)) then
ismenu = 0
lastset = 0
end
if (btnp(5)) then
 lastsel = menusel
	if (menusel == 1) then
		if (cash >= 10) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 10
			 mset(x, y, 1+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 2) then
		if (cash >= 25) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 25
			 mset(x, y, 4+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end  
	if (menusel == 3) then
		if (cash >= 50) then
			if (residents >= 200) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 7+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 4) then
		if (cash >= 10) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 10
			 mset(x, y, 10+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 5) then
		if (cash >= 25) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 25
			 mset(x, y, 13+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 6) then
		if (cash >= 50) then
			if (residents >= 200) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 16+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
		if (menusel == 7) then
		if (cash >= 10) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 10
			 mset(x, y, 19+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 8) then
		if (cash >= 25) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 25
			 mset(x, y, 22+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 9) then
		if (cash >= 50) then
			if (residents >= 200) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 25+flr(rnd(3)))
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 10) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 28)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 11) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 29)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 12) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 30)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 13) then
		if (cash >= 100) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 31)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 14) then
		if (cash >= 100) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 32)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 15) then
		if (cash >= 100) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 33)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 16) then
		if (cash >= 100) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 34)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 17) then
		if (cash >= 100) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 35)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 18) then
		if (cash >= 100) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 36)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 19) then
		if (cash >= 100) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 37)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 20) then
		if (cash >= 150) then
			if (residents >= 250) then
				if (mget(x, y) == 0) then
			 cash -= 150
			 mset(x, y, 38)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 21) then
		if (cash >= 250) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 250
			 mset(x, y, 39)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 22) then
		if (cash >= 50) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 40)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 23) then
		if (cash >= 50) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 41)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 24) then
		if (cash >= 50) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 42)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 25) then
		if (cash >= 50) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 43)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 26) then
		if (cash >= 50) then
			if (residents >= 50) then
				if (mget(x, y) == 0) then
			 cash -= 50
			 mset(x, y, 44)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 27) then
		if (cash >= 500) then
			if (residents >= 250) then
				if (mget(x, y) == 0) then
			 cash -= 500
			 mset(x, y, 45)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 28) then
		if (cash >= 500) then
			if (residents >= 250) then
				if (mget(x, y) == 0) then
			 cash -= 500
			 mset(x, y, 46)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 29) then
		if (cash >= 500) then
			if (residents >= 250) then
				if (mget(x, y) == 0) then
			 cash -= 500
			 mset(x, y, 47)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 30) then
		if (cash >= 100) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 65)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 31) then
		if (cash >= 100) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 66)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 32) then
		if (cash >= 100) then
			if (residents >= 100) then
				if (mget(x, y) == 0) then
			 cash -= 100
			 mset(x, y, 67)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 33) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 68)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 34) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 69)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 35) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 70)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 36) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 71)
			 sfx(2)
			 end
			end
		end
	end 
	if (menusel == 37) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 72)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 38) then
		if (cash >= 5) then
			if (residents >= 0) then
				if (mget(x, y) == 0) then
			 cash -= 5
			 mset(x, y, 73)
			 sfx(2)
			 end
			end
		end
	end
	if (menusel == 39) then
			if (residents >= 0) then
				if (mget(x, y) > 0) then
			 mset(x, y, 0)
			 sfx(3)
			 end
			end
	end  
end
end

function grp_build_menu()
-- this function is the graphic
-- part of the main menu
rectfill(0, 96, 128, 128, 4)
if (menusel == 1) then
 spr(1, 8, 106)
 print("residential low density", 18, 98, 0)
 print("cheap homes for cheap", 18, 107, 0)
 print("people, elders, students", 18, 113, 0)
 print("-price 10 needs 0   resid.-", 18, 122, 0)
end
if (menusel == 2) then
 spr(4, 8, 106)
 print("residential mid density", 18, 98, 0)
 print("your standard flat", 18, 107, 0)
 print(" ", 18, 113, 0)
 print("-price 25 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 3) then
 spr(7, 8, 106)
 print("residential high density", 18, 98, 0)
 print("luxury homes for luxury", 18, 107, 0)
 print("snobs and movie stars", 18, 113, 0)
 print("-price 50 needs 200 resid.-", 18, 122, 0)
end
if (menusel == 4) then
 spr(10, 8, 106)
 print("commercial low density", 18, 98, 0)
 print("the small stores are", 18, 107, 0)
 print("pretty much extinct.", 18, 113, 0)
 print("-price 10 needs 0   resid.-", 18, 122, 0)
end
if (menusel == 5) then
 spr(13, 8, 106)
 print("commercial mid density", 18, 98, 0)
 print("killing economy...", 18, 107, 0)
 print("one supermarket at a time", 18, 113, 0)
 print("-price 25 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 6) then
 spr(16, 8, 106)
 print("commercial high density", 18, 98, 0)
 print("buy somethin' will ya?", 18, 107, 0)
 print("you will have a bad time!", 18, 113, 0)
 print("-price 50 needs 200 resid.-", 18, 122, 0)
end
if (menusel == 7) then
 spr(19, 8, 106)
 print("industrial low density", 18, 98, 0)
 print("the south african farmers", 18, 107, 0)
 print("need your help. build farms", 18, 113, 0)
 print("-price 10 needs 0 resid.  -", 18, 122, 0)
end
if (menusel == 8) then
 spr(22, 8, 106)
 print("industrial mid density", 18, 98, 0)
 print("make your chinese work", 18, 107, 0)
 print("for a rice bowl", 18, 113, 0)
 print("-price 25 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 9) then
 spr(25, 8, 106)
 print("industrial high density", 18, 98, 0)
 print("the doors 98 price has grew", 18, 107, 0)
 print("lately. place a picosoft hq", 18, 113, 0)
 print("-price 50 needs 200 resid.-", 18, 122, 0)
end
if (menusel == 10) then
 spr(28, 8, 106)
 print("road horizontal", 18, 98, 0)
 print("your typical road", 18, 107, 0)
 print(" ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 11) then
 spr(29, 8, 106)
 print("road vertical", 18, 98, 0)
 print("if you don't like", 18, 107, 0)
 print("horizontal roads ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 12) then
 spr(30, 8, 106)
 print("road crossing", 18, 98, 0)
 print("your typical crossing", 18, 107, 0)
 print(" ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 13) then
 spr(31, 8, 106)
 print("fire station", 18, 98, 0)
 print("if there's fire", 18, 107, 0)
 print("in your neighbourhood... ", 18, 113, 0)
 print("-price 100 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 14) then
 spr(32, 8, 106)
 print("police station", 18, 98, 0)
 print("...who you gonna call?", 18, 107, 0)
 print("the police! ", 18, 113, 0)
 print("-price 100 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 15) then
 spr(33, 8, 106)
 print("water silo", 18, 98, 0)
 print("no water? plop this baby", 18, 107, 0)
 print("and swim in your new pool ", 18, 113, 0)
 print("-price 100 needs 0   resd.-", 18, 122, 0)
end
if (menusel == 16) then
 spr(34, 8, 106)
 print("energy plant", 18, 98, 0)
 print("you should plop it if you", 18, 107, 0)
 print("don't want to live in 30's. ", 18, 113, 0)
 print("-price 100 needs 0   resd.-", 18, 122, 0)
end
if (menusel == 17) then
 spr(35, 8, 106)
 print("sewage processor", 18, 98, 0)
 print("processes your poop into", 18, 107, 0)
 print("even more poop. for plants. ", 18, 113, 0)
 print("-price 100 needs 0   resd.-", 18, 122, 0)
end
if (menusel == 18) then
 spr(36, 8, 106)
 print("waste storage", 18, 98, 0)
 print("you don't want to live in", 18, 107, 0)
 print("the close proximity of it. ", 18, 113, 0)
 print("-price 100 needs 0   resd.-", 18, 122, 0)
end
if (menusel == 19) then
 spr(37, 8, 106)
 print("primary school", 18, 98, 0)
 print("to avoid having more idiots", 18, 107, 0)
 print("in this beautiful city. ", 18, 113, 0)
 print("-price 100 needs 0   resd.-", 18, 122, 0)
end
if (menusel == 20) then
 spr(38, 8, 106)
 print("college", 18, 98, 0)
 print("make your residents wiser.", 18, 107, 0)
 print("there's no use in wisdom.", 18, 113, 0)
 print("-price 150 needs 250 resd.-", 18, 122, 0)
end
if (menusel == 21) then
 spr(39, 8, 106)
 print("town hall", 18, 98, 0)
 print("make your city a city.", 18, 107, 0)
 print("", 18, 113, 0)
 print("-price 250 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 22) then
 spr(40, 8, 106)
 print("park", 18, 98, 0)
 print("everyone needs a place", 18, 107, 0)
 print("to relax after work.", 18, 113, 0)
 print("-price 50 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 23) then
 spr(41, 8, 106)
 print("tennis court", 18, 98, 0)
 print("sport is good for your", 18, 107, 0)
 print("health and for you.", 18, 113, 0)
 print("-price 50 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 24) then
 spr(42, 8, 106)
 print("basketball court", 18, 98, 0)
 print("play street basketball", 18, 107, 0)
 print("on this cool court.", 18, 113, 0)
 print("-price 50 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 25) then
 spr(43, 8, 106)
 print("soccer field", 18, 98, 0)
 print("invite those football", 18, 107, 0)
 print("pseudo-fans with fireworks", 18, 113, 0)
 print("-price 50 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 26) then
 spr(44, 8, 106)
 print("skate park", 18, 98, 0)
 print("for those modern teens", 18, 107, 0)
 print("that want to be hony tawk.", 18, 113, 0)
 print("-price 50 needs 50  resid.-", 18, 122, 0)
end
if (menusel == 27) then
 spr(45, 8, 106)
 print("eiffel tower", 18, 98, 0)
 print("make your city a paris", 18, 107, 0)
 print("copy of your dreams.", 18, 113, 0)
 print("-price 500 needs 250 resd.-", 18, 122, 0)
end
if (menusel == 28) then
 spr(46, 8, 106)
 print("big ben", 18, 98, 0)
 print("make your city a london", 18, 107, 0)
 print("copy of your dreams.", 18, 113, 0)
 print("-price 500 needs 250 resd.-", 18, 122, 0)
end
if (menusel == 29) then
 spr(47, 8, 106)
 print("big casino", 18, 98, 0)
 print("make your city a vegas", 18, 107, 0)
 print("copy of your dreams.", 18, 113, 0)
 print("-price 500 needs 250 resd.-", 18, 122, 0)
end
if (menusel == 30) then
 spr(65, 8, 106)
 print("bus stop", 18, 98, 0)
 print("catch a bus before", 18, 107, 0)
 print("you will be late for it.", 18, 113, 0)
 print("-price 100 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 31) then
 spr(66, 8, 106)
 print("monorail stop", 18, 98, 0)
 print("a faster alternative", 18, 107, 0)
 print("for buses and trains", 18, 113, 0)
 print("-price 100 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 32) then
 spr(67, 8, 106)
 print("railway station", 18, 98, 0)
 print("import and export", 18, 107, 0)
 print("passengers (no stuff!)", 18, 113, 0)
 print("-price 100 needs 100 resd.-", 18, 122, 0)
end
if (menusel == 33) then
 spr(68, 8, 106)
 print("monorail horizontal", 18, 98, 0)
 print("your typical monorail", 18, 107, 0)
 print(" ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 34) then
 spr(69, 8, 106)
 print("monorail vertical", 18, 98, 0)
 print("the legends say it's", 18, 107, 0)
 print("faster than horizontal. ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 35) then
 spr(70, 8, 106)
 print("monorail crossing", 18, 98, 0)
 print("when you need to break phys.", 18, 107, 0)
 print("laws and cross rails. ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 36) then
 spr(71, 8, 106)
 print("rail horizontal", 18, 98, 0)
 print("your typical horizontal", 18, 107, 0)
 print("train rails. ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 37) then
 spr(72, 8, 106)
 print("rail vertical", 18, 98, 0)
 print("better than wolves...", 18, 107, 0)
 print("er... horizontal rails. ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 38) then
 spr(73, 8, 106)
 print("rail crossing", 18, 98, 0)
 print("when you need to break phys.", 18, 107, 0)
 print("laws and cross rails. ", 18, 113, 0)
 print("-price 5  needs 0   resid.-", 18, 122, 0)
end
if (menusel == 39) then
 spr(64, 8, 106)
 print("demolish", 18, 107, 0)
 print("-price 0  needs 0   resid.-", 18, 122, 0)
end
-- here function ends
end

function prg_budget_menu()
-- this function is the program
-- part of the budget menu
if (btnp(0)) taxpercent -= 1
if (btnp(1)) taxpercent += 1
if (taxpercent > 5) taxpercent = 5
if (taxpercent < 1) taxpercent = 1
if (btnp(4)) ismenu = 0
end

function grp_budget_menu()
-- this function is the graphic
-- part of the budget menu
rectfill(0, 96, 128, 128, 4)
print("taxes: 1"..taxpercent.."%", 8, 107, 0)
print("cash made: "..addcash.." $", 8, 113, 0)
-- here function ends
end

function prg_stats_menu()
-- this function is the program
-- part of the budget menu
if (btnp(4)) ismenu = 0
end

function grp_stats_menu()
-- this function is the graphic
-- part of the budget menu
rectfill(0, 0, 128, 128, 4)
print("city stats", 8, 8, 0)
print(howlongy.."y "..howlongm.."m "..howlongd.."d ", 8, 24, 0)
print("cash: "..cash.." $", 8, 40, 0)
print("energy: "..energy, 8, 48, 0)
print("water: "..water, 8, 56, 0)
print("sewage: "..sewage, 8, 64, 0)
print("trash: "..trash, 8, 72, 0)
print("residents: "..residents, 8, 88, 0)
print("tourists: "..tourists, 8, 96, 0)
print("happiness: "..happiness.."%", 8, 112, 0)
if (crimepower <= 0) then
print("we're lacking", 64, 8, 2)
print("police stations", 64, 16, 2)
end

if (crimepower <= 0) then
print("we're lacking", 64, 32, 2)
print("fire stations", 64, 40, 2)
end
-- here function ends
end

function prg_energy_menu()
-- this function is the program
-- part of the energy menu
if (btnp(4)) ismenu = 0
end

function grp_energy_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 96, 128, 128, 4)
print("energy: "..energy, 8, 107, 0)
-- here function ends
end

function prg_water_menu()
-- this function is the program
-- part of the energy menu
if (btnp(4)) ismenu = 0
end

function grp_water_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 96, 128, 128, 4)
print("water: "..water, 8, 107, 0)
-- here function ends
end

function prg_sewage_menu()
-- this function is the program
-- part of the energy menu
if (btnp(4)) ismenu = 0
end

function grp_sewage_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 96, 128, 128, 4)
print("sewage: "..sewage, 8, 107, 0)
-- here function ends
end

function prg_trash_menu()
-- this function is the program
-- part of the energy menu
if (btnp(4)) ismenu = 0
end

function grp_trash_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 96, 128, 128, 4)
print("trash: "..trash, 8, 107, 0)
-- here function ends
end

function prg_options_menu()
-- this function is the program
-- part of the option menu
for x=0,15 do
  pal(x,(x+palette)%16,1)
 end
if (btnp(0)) speed -= 1
if (btnp(1)) speed += 1
if (btnp(2)) palette -= 1
if (btnp(3)) palette += 1
if (speed > 10) speed = 10
if (speed < 1) speed = 1
if (palette > 15) palette = 15
if (palette < 0) palette = 0
if (btnp(4)) ismenu = 0
if (btnp(5)) _init()
end

function grp_options_menu()
-- this function is the graphic
-- part of the option menu
rectfill(0, 96, 128, 128, 4)
print("speed: "..speed, 8, 100, 0)
print("palette: "..palette, 8, 108, 0)
print("   to exit ", 8, 116, 0)
spr(81, 8, 114)
-- here function ends
end

function prg_title_menu()
-- this function is the title
-- screen
if (btnp(5)) then
 ismenu = 11
end
end

function grp_title_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 0, 128, 128, 0)
spr(54, 48, 32)
spr(55, 56, 32)
spr(56, 64, 32)
spr(57, 72, 32)
spr(58, 80, 32)
print("a city sim", 48, 42, 7)
print("press button", 36, 92, 7)
print("made by adrian09_01 for", 16, 112, 7)
print("devi ever's #citysimjam", 16, 120, 7)
spr(81, 89, 90)
menusel = 1
-- here function ends
end

function prg_map_menu()
-- this function is the title
-- screen
if (btnp(3)) menusel += 1
if (btnp(3)) sfx(0)
if (btnp(2)) menusel -= 1
if (btnp(2)) sfx(0)
if (btnp(1)) cash += 500
if (btnp(1)) sfx(0)
if (btnp(0)) cash -= 500
if (btnp(0)) sfx(0)
if (menusel == 0) menusel = 2
if (menusel == 3) menusel = 1
if (cash < 500) cash = 500
if (cash > 2000) cash = 2000
if (btnp(5)) then
 if (menusel == 1) then 
 generate_level()
 end
 if (menusel == 2) then
 music(0)
 ismenu = 0
 end
end
end

function grp_map_menu()
-- this function is the graphic
-- part of the energy menu
rectfill(0, 0, 128, 128, 4)
draw_minimap(32, 8)
rect(32, 7, 97, 73, 2)
print("start cash: "..cash, 33, 76, 0)
if (menusel == 1) then
 spr(82, 8, 106)
 print("generate a new map", 18, 107, 0)
end
if (menusel == 2) then
 spr(83, 8, 106)
 print("start a new game", 18, 107, 0)
end
end
__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcdcdcbbb82828bbbfafafbbbbbbbbbbbbbbbbbbbbbbbbbbbb8aabbbbbb94bbbbb2e2bb
b3b3bbbbbbbb4bbbbbbb3bbbbbbb8bbbbb82828bbb65656bbba9a9abbbcdcdcbbb82828bbbfafafbbbbbbbbbbbbbbbbbbbbbbbbbbbb999bbbbb9b94bbbba2abb
bb3bbbbbbbb494bbbbb3d3bbbbb878bbbb2c2c2bbb5c5c5bbb9c9c9bbbdddddbbb22222bbbaaaaabbb87878bbb87878bbb87878bbbbb6bbbbbbb94bbbbbbabbb
bbbbbbbbbb49994bbb3ddd3bbb87778bbb8c2c8bbb6c5c6bbbac9cabbbcdcdcbbb82828bbbfafafbbb87878bbb87878bbb87878bbb66666bbb66666bbb66666b
bbbbbbbbbbb999bbbbbdddbbbbb777bbbb2c2c2bbb5c5c5bbb9c9c9bbbcdcdcbbb82828bbbfafafbbb99999bbbdddddbbb66666bbbcdcdcbbb99999bbb77777b
bbbb3b3bbbb949bbbbbd4dbbbbb747bbbb82428bbb65456bbba949abbbdddddbbb22222bbbaaaaabbb9c4c9bbbdc4cdbbb6c4c6bbbcd1dcbbb9c4c9bbb7c4c7b
bbbbb3bbbbb949bbbbbd4dbbbbb747bbbb22422bbb55455bbb99499bbbcd1dcbbb82128bbbfa1afbbb99499bbbdd4ddbbb66466bbbcd1dcbbb99499bbb77477b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdd1ddbbb22122bbbaa1aabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bba9abbbbba9abbbbba9abbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbb5bbbbbbb5bbbbb88c88bbb82a28bbbeefeeb555555555555555555555555bbbb8bbb
bba9abbbbba9abbbbba9abbbb2222bbbb2222bbbb8888bbbbbbb5bbbbbbb5bbbbbbb5bbbbb8dc88bbb8a9a8bbbeaeaeb555555555555755555557555bbb8a8bb
b82828bbb65656bbba9a9abbbaaaabbbb9999bbbb3333bbbb2b252bbb5b555bbb6b656bbbb88d8dbbb2a9a2bbbeaaaeb555555555555755555557555bbb898bb
b2c2c2bbb5c5c5bbb9c9c9bbb2222b4bb2222b4bb8888b4bb222222bb555555bb666666bbbcdcdcbbb82a28bbbfafafb577777755555755557777775bb82828b
b8c2c8bbb6c5c6bbbac9cabbbaaaa494b9999494b3333494b2cdcd2bb5cdcd5bb6cdcd6bbbcdcdcbbb82828bbbfafafb555555555555755555557555bb2c2c2b
b2c2c2bbb5c5c5bbb9c9c9bbb2222949b2222949b8888949b224422bb554455bb664466bbbdddddbbb22222bbbaaaaab555555555555755555557555bb82428b
b82428bbb65456bbba949abbbaaaa949b9999949b3333949b224422bb554455bb664466bbbcd1dcbbb82128bbbfa1afb555555555555755555557555bb22422b
b22422bbb55455bbb99499bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdd1ddbbb22122bbbaa1aab555555555555555555555555bbbbbbbb
bbbaaabbbbbbbbbbbbbabbbbbbbbbbbbbbbbbbbbbbb282bbbbb282bb82828282bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2bbbbbbb9bbbb8b8b8bb
bbb1a1bbbb666bbbbbbaaabbbb5775bbbbbb2bbbbb8bab8bbb8bab8b2c2c2c2cbb3bbb3bb444544bb67bb76bbbbbbbbbb7bb5bbbbbbb2bbbbbb949bbb888282b
bbba1abbbb6c6bbbb2b2ba2bbb5bb5bbbbb136bbbb2aaa2bbb2aaa2b2c2c2c2cbb3bbb3bb499799bb6bbbb6b63377336b77555bbbbb2b2bbbb947a9bb8b8282b
bb82828bbb6c6bbbb222222bbb5bb5bbbb6789abbb82828b828282822c2c2c2cbb4bbb4bb577777bb677576b63733736b777556bbbb222bbbbb657bbb666666b
bb2c2c2bbb666bbbb2cdcd2bbb5bb5bbbdabcdebbb2c2c2b2c2c2c2c2c2c2c2cbbbb3bbbb499799bb655756b63733736b777766bbbb2b2bbbbb47abbb999999b
bb82428bbb4b4bbbb224422bb774477bbfef53cbbb82428b8282428282824282b44b3bbbb577777bb657556b63377336b777776bbbb222bbbbb4aabbb955459b
bb22422bbb4b4bbbb224422bb777777bbbbbbbbbbb22422b2222422222224222b22b4bbbb499999bb575775bbbbbbbbbb777777bbb2bbb2bbbb4aabbb999499b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbcccccccc000a00006666666622220000000000000000000000000000000000000000000000000000000000000000000088800888
bbbb5bbbbbbbbbbbb3b3b3b3c777cccc00aaaa0067777777a2a200000aaa000000000000aaa000000000000000000000000c0000000020000055555082200228
bbb567bbbbbbbbbbb3b3b3b3cccccccc0a0a000067778887a2a200000a00a00a000000000a0000000000000000a0000000ccc000000440000067676082000028
bb5667bbbbb33bbb34343434ccc777cc0a0a000067777887222244440aaa0000000000000a0000000000000000a000000c7ccc00000222000067676000000000
bb5667bbbb3bb3bb3b3b3b3bcccccccc00aaa00067778787a2a24a4a0a00000a00aa00a00a000a00a0a0aa0000aaaa000ccccc00004444000067676000000000
b566667bb3bbbb3b43434343c777cccc000a0a0067787777a2a24a4a0a00000a0a000a0a0a00a0a0aaa0a0a000000a000ccccc00002222200067676082000028
b566667bb3bbbb3bb3b3b3b3cccccccc000a0a0067877777222244440a00000a00aa00a00a000a00a0a0a0a000000a0000ccc000044444400067676082200228
bbbbbbbbbbbbbbbbb4b4b4b4cccccccc0aaaa00028777777a2a24a4a000000000000000000000000000000000000000000000000000000000000000088800888
00000a00bbbbbbbbbbbbbbbbbbbbbbbb66666666655555566b5bb5b622222222255555522b5bb5b2000000005555555555555555555555555555555555555555
0000a080bccccccbb888888bb999999bb5b5b5b56bbbbbb6bb5bb5bbb5b5b5b52b7bb7b2bb5775bb0009a000577eeee557766665577aaaa55577777555777775
0000a000bccccccbb888888bb999999bb5b5b5b56555555655bbbb55757575752555555255bbbb55009a7c005c7288e55c73bb655c7499a555cccc7555cccc75
00566000b166661bb266662bba6666abb5b5b5b56bbbbbb6bbb55bbbb5b5b5b52b7bb7b2b7b55b7b009aaa005c7288e55c73bb655c7499a555eeeee555666665
05666600b166661bb266662bba6666abb5b5b5b565555556bbb55bbbb5b5b5b525555552b7b55b7b0009a0005c7288e55c73bb655c7499a5552888e5553bbb65
05666600b166661bb266662bba6666abb5b5b5b56bbbbbb655bbbb55757575752b7bb7b255bbbb55002888005c7222e55c7333655c7444a5552888e5553bbb65
00566000b199991bb299992bba9999abb5b5b5b565555556bb5bb5bbb5b5b5b525555552bb5775bb00288800555555555555555555555555552222e555333365
00000000bbbbbbbbbbbbbbbbbbbbbbbb666666666bbbbbb66b5bb5b6222222222b7bb7b22b5bb5b2002888005555555555555555555555555555555555555555
5555555500111c000000000000000000bbb88bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5577777501ddddc00ffffff000000b30bb8998bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55cccc751dd77ddc00bb6b0000000b30b89aa98b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55aaaaa51d7dd7dc006ccb0000000b3089a77a980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
554999a51d7dd7dc00bcbb000b00b30089a77a980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
554999a51dd77ddc00b6b40003b0b30089aaaa980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
554444a50dddddc00ffffff0003b3000b899998b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555500dddc000000000000030000bb8888bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010800002b5701f5002b5003550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180000156701f670156701f670156701f670156701f670156701f670156701f670156701f670305003250030000300003000030000300000000000000000000000000000000000000000000000000000000000
010700000c570105700c0000c570105700c0000c570105700c5000c570105700c5000c570105700c0000c570105700c0000c0000c0000c00024000300000c0001800024000300000c00018000240003000000000
010600000c6701a670286701a6700c670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000241702b170000001460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c6700e6701c6701d6702b6702d6703b6703c670240002c000240002c000240002c000240002c000240002c0002400024000240002400000000000000000000000000000000000000000000000000000
000f00002807026000240002607024000240702d5002607028000280702850024070295002d5002807028500260702f500280702450026070265002407024500280702f500260702d50028070285002407024500
000f0000130501c7001f7001105021700100501a7000e05021700100502370010050187001c700100501d7001105024700130501f70011050217001005028700100501d7000e0501f7000c0501a7000c05023700
000f0000103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310103100e310
000f00000c62018600186000c62018600186000c6000c6201c600186001c6000c62021600186000c6201860021600006000c62000600006001e6000c6200060000600006000c6201860021600186000c62018600
001400001c7701c77000700007001c7701c7701e7701c770137001c7001c7701c7701e7701c77000700007001c7701c7701e7701a77000700007001a7701a7701c7701a770007001a7701a7701c770197701a770
001400001c7000070017750177501975000700177001770017750177501975000700007000070017750177501975000100001000010015750157501775000700007000070015750157501775000700107500e750
00140000007000070000700197500070000700007000070000700197500070000700007000070000700197500070000700007000070000700177500070017700007000070000700177500070000700177500e750
001400000060000600006000c63000600006000060000600006000c63000600006000060000600006000c63000600006000060000600006000c63000600006000060000600006000c6300c600006000c6300c630
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
03 06 07 08 09
03 0a 0b 0c 0d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
