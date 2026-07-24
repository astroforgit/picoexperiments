pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- dungeo: the lich queen
-- by cc

function mod16( x )
return x % 16
end

function d( sides )
if (sides < 2) then return sides end
return flr(rnd(sides)) + 1
end

function pickfrom( table )
return table[ d( #table ) ]
end

function copy( table )
local acopy = {}
for k,v in pairs( table) do
acopy[k] = v
end
return acopy
end

function round( c )
return flr( c + 0.499 )
end

function indexof( table, key )
for i = 1, #table do
if (table[i] == key) then return i end
end
return 0
end

function printr( str, x, y, c )
local w = 4 * #str
print( str, x-w, y, c )
end

function printc( str, x, y, c )
local w = 4 * #str
print( str, x-round( w/2 ), y, c )
end

function switchto( newcontroller )
isdirty = true
if (controller.blur != nil) then controller.blur() end
controller = newcontroller
if (controller.focus != nil) then controller.focus() end
end

function setactivehero( tohero )
activehero = tohero
isdirty = true
end

controller = {}

function _init()

cartdata("bdi_dungeo")

print( " ", 0, 70, 15 )

gamestate.newgame()

switchto( mainmenu ) -- controller_town )

end

function _update()

if (controller.update ~= nil) then controller.update() end

end

function _draw()

if (controller.draw ~= nil) then controller.draw() end

end

mainmenu = {
focus = function()
gamestate.newgame()
choice = 1
isdirty = true
mainmenu.options = {}
if (dget(0) == 1) then
add( mainmenu.options, { "load game", function()
gamestate.loadgame()
switchto( controller_town )
end })
end
add( mainmenu.options, { "new  game", function()
switchto( controller_town )
end })
end,
update = function()
if (btnp(2)) then
choice = max( 1, choice - 1 )
sfx(4)
isdirty = true
end
if (btnp(3)) then
choice = min( #mainmenu.options, choice + 1 )
sfx(4)
isdirty = true
end
if (btnp(4)) then
sfx(5)
mainmenu.options[ choice ][2]()
end
end,
draw = function()
if (not isdirty) then return end
isdirty = false
cls()
sspr( 0,32,64,32, 0, 0, 128, 64 )
printc( "can you defeat the lich queen?", 64, 60, 7 )
for i = 1, #mainmenu.options do
if (i == choice) then
printc( "> " .. mainmenu.options[i][1] .. " <", 64, 68 + i * 6, 10 )
else
printc( mainmenu.options[i][1], 64, 68 + i * 6, 5 )
end
end
printc( "arrow keys to select / move", 64, 95, 1 )
printc( "z to choose", 64, 101, 1 )
printc( "x to cancel", 64, 107, 1 )
end,
}



controller_camp = {

focus = function()
sfx(5)
setactivehero( 0 )
controller_choose_hero.show(
"examine who?",
function( hero )
controller_examine_hero.examine( hero )
end,
0, 0,
function()
switchto( controller_explore )
end
);
end

}

controller_examine_hero = {
examine = function( hero )
setactivehero( hero )
controller_examine_hero.hero = hero
controller_examine_hero.portrait = hero.portrait
local options = {}
add( options,
{ "stats",
function()
isdirty = true
controller_hero_stats.examine( controller_examine_hero.hero )
end })
if (hero.spellcaster) then
add( options,
{ "cast spell",
function()
controller_cast_spell_in_camp.choose( controller_examine_hero.hero )
end })
end
add( options,
{ "cancel",
function()
switchto( controller_camp )
end })
controller_modal.show(
"what to do?",
options,
controller_examine_hero.portrait[1], controller_examine_hero.portrait[2],
function()
switchto( controller_camp )
end )
end,
}

controller_camp_spell = {
}

controller_hero_stats = {
examine = function(hero)
controller_hero_stats.hero = hero
controller_hero_stats.portrait = hero.portrait
switchto( controller_hero_stats )
end,
update = function()
if (btnp(4) or btnp(5)) then
sfx(4)
controller_examine_hero.examine( controller_hero_stats.hero )
end
end,
draw = function()

if (not isdirty) then return end
isdirty = false

local hero = controller_hero_stats.hero

gamestate.draw()

rectfill( 0,0,66,66,0)
sspr(controller_hero_stats.portrait[1],controller_hero_stats.portrait[2],16,16,1,1,65,65)
rect( 0, 0, 66, 66, 2 )

rect( 66, 0, 127, 66, 2 )
rectfill( 66, 0, 127, 8, 2 )

printc( "lvl " .. hero.level .. " " .. hero.name, 96, 2, 7 )

local y = 10
y = controller_hero_stats.drawrow( y, "     xp: ", hero.xp, 6 )
y = controller_hero_stats.drawrow( y, " muscle: ", hero.strength, 6 )
y = controller_hero_stats.drawrow( y, " smarts: ", hero.intelligence, 6 )
y = controller_hero_stats.drawrow( y, "agility: ", hero.dexterity, 6 )
y = controller_hero_stats.drawrow( y, "   grit: ", hero.constitution, 6 )

printc( "+" .. hero.weapon .. " " .. hero.weaponname, 96, y, 6 )
y += 6

printc( "+" .. hero.armor .. " " .. hero.armorname, 96, y, 6 )
y += 6

if (hero.shieldname ~= "none") then
printc( "+" .. hero.shield .. " " .. hero.shieldname, 96, y, 6 )
end

rect( 0, 66, 127,127, 2 )

end,

drawrow = function( y, label, value, color )
print( "         " .. value, 70, y, color )
print( label, 70, y, 2 )
return y + 6
end,


}

monster = nil

controller_combat_start = {

focus = function()
incombat = true
monster = makemonster( camera.z )
sfx( 6 )
switchto( controller_choose_party_response )
end

}

controller_choose_party_response = {
focus = function()
controller_modal.show(
"you encounter\n" .. monster.number .. " " .. monster.name .. "s.",
{
{ "stand ground",
function()
switchto( controller_choose_options )
end },
{ "run away",
function()
if (d(100) > monster.chase) then
switchto( controller_explore )
else
switchto( controller_choose_options )
end
end },
}, monster.portraitx, monster.portraity )
end
}

controller_choose_options = {
focus = function()
controller_player_option.slot = 1
monster.active = monster.number
switchto( controller_player_option )
end,
}

controller_player_option = {
focus = function()
setactivehero( 0 )
if (monster.number < 1) then
if (monster.name == "lich") then
endgame.finish( "lich queen dead", "you win!", 96,80 )
else
switchto( controller_victory )
end
return
end
if (controller_player_option.slot > #gamestate.heroes) then
switchto( controller_enemy_attack )
return
end
local hero = gamestate.heroes[ controller_player_option.slot ]
if (not gamestate.isactive( hero )) then
controller_player_option.nextplayer()
return
end
setactivehero( hero )
local options = {}
add( options, {
"melee attack", function()
controller_player_option.domelee()
end
})
add( options, {
"defend", function()
controller_player_option.dodefend()
end
})
if (hero.spellcaster) then
add( options, {
"cast spell", function()
controller_player_option.dospellcast()
end
})
end
controller_modal.show(
hero.name .. "\nchoose action:",
options, monster.portraitx, monster.portraity )
end,
nextplayer = function()
controller_player_option.slot += 1
switchto( controller_player_option )
end,
dospellcast = function()
local hero = gamestate.heroes[ controller_player_option.slot ]
controller_cast_spell_in_combat.choose( hero )
end,
domelee = function()
local hero = gamestate.heroes[ controller_player_option.slot ]
local offense = hero.level + hero.strength + hero.weapon + 1
if (hero.attackbonus) then offense += hero.attackbonus end
controller_strike_enemy.strike( hero, offense, 0 )
end,
dodefend = function()
local hero = gamestate.heroes[ controller_player_option.slot ]
local defense = hero.level + hero.dexterity + hero.armor + 1
if (hero.shield ~= "none") then defense += hero.shield + 1 end
local options = { { "okay", function()
controller_player_option.nextplayer()
end } }
if (d(defense) > d(monster.offense)) then
sfx(8)
monster.active -= 1
controller_modal.show(
hero.name .. "\ndefends!",
options, monster.portraitx, monster.portraity )
else
sfx(7)
controller_modal.show(
hero.name .. "\nfails to\ndefend!",
options, monster.portraitx, monster.portraity )
end
end,
}

controller_strike_enemy = {
strike = function( hero, offense, attacktype )
local defense = monster.defense
if (attacktype ~= 0) then
defense = 0
end
local damage = d(offense) - d(defense)
if (damage < 1) then
sfx(7)
controller_modal.show(
hero.name .. "\nmisses!",
{
{ "okay", function()
controller_player_option.nextplayer()
end }
}, monster.portraitx, monster.portraity )
return
end
monster.hp -= damage
local t = hero.name .. " deals\n" .. damage .. " damage\n" .. "to " .. monster.name
if (monster.hp < 1) then
sfx(9)
t = t .. ",\nkilling it!\n" .. hero.name .. " gets\n" .. camera.z .. "xp!"
monster.number -= 1
monster.active -= 1
hero.xp += camera.z
monster.hp = monster.maxhp
else
sfx(8)
t = t .. "!"
end
controller_modal.show(
t,
{
{ "okay", function()
controller_player_option.nextplayer()
end }
}, monster.portraitx, monster.portraity )
end
}

controller_victory = {
focus = function()
setactivehero( 0 )
sfx( 10 )
override( chest )
controller_modal.show(
monster.name .. "s\nare defeated!",
{
{ "yay", function()
switchto( controller_explore )
controller_explore.didmove()
end }
}, monster.portraitx, monster.portraity )
monster = nil
end
}

controller_enemy_attack = {
focus = function()
local hero = gamestate.randomactiveplayer()
if (hero == nil) then
endgame.finish( "all heroes out", "you lose", 80,80 )
return
end
if (monster.active < 1) then
switchto( controller_choose_party_response )
return
end
monster.active -= 1
local offense = monster.offense  --  ramp monsters by enemy
offense += camera.z * camera.z -- ramp monsters by level
local defense = hero.level + hero.dexterity + hero.armor + hero.shield + 1
local damage = d(offense) - d(defense)
local t = monster.name .. "\nattacks\n" .. hero.name .. " and\n"
if (damage < 1) then
t = t .. "misses!"
sfx(7)
else
t = t .. "hits for " .. damage .. "\ndamage!\n"
if (monster.poisonous and d(100) < camera.z * 10) then
hero.condition = max( 1, hero.condition )
t = t .. hero.name .. " \npoisoned!"
end
if (monster.stones and d(100) < camera.z * 5) then
hero.condition = max( 2, hero.condition )
t = t .. hero.name .. " \npetrified!"
end
hero.hp = max( hero.hp - damage, 0 )
if (hero.hp == 0) then
t = t .. hero.name .. " dies!"
sfx(9)
else
sfx(8)
end
end
controller_modal.show(
t,
{
{ "okay", function()
controller_enemy_attack.nextmonster()
end }
}, monster.portraitx, monster.portraity )
return
end,
nextmonster = function()
switchto( controller_enemy_attack )
end,
}

controller_explore = {

update = function()
if (btnp(0)) then
camera.facing -= 1
if (camera.facing < 1) then camera.facing = 4 end
isdirty = true
sfx( 0 )
end
if (btnp(1)) then
camera.facing += 1
if (camera.facing > 4) then camera.facing = 1 end
isdirty = true
sfx( 0 )
end
if (btnp(2)) then
local forward = camtile( camera, 0, 1 )
local facing = facings[ camera.facing ]
local amount = 1
camera.x += facing.forward.dx * forward.tile.move
camera.y += facing.forward.dy * forward.tile.move
sfx( forward.tile.sfx )
isdirty = true
if (forward.tile.move > 0) then
controller_explore.didmove()
end
end
if (btnp(3)) then
local backward = camtile( camera, 0, -1 )
local canmovebackward = true
facing = facings[ camera.facing ]
camera.x -= facing.forward.dx * backward.tile.move
camera.y -= facing.forward.dy * backward.tile.move
sfx( backward.tile.sfx )
isdirty = true
if (backward.tile.move > 0) then
controller_explore.didmove()
end
end
if (btnp(5)) then
switchto( controller_camp );
end
end,

didmove = function()
camera.x = mod16( camera.x )
camera.y = mod16( camera.y )

for i = 1,#gamestate.heroes do
local hero = gamestate.heroes[i]
if (hero.condition == 2 and hero.hp > 0) then
if (d(100) < 10) then
hero.hp = max( 1, hero.hp - 1 )
end
end
end

thinghere = camtile( camera, 0, 0 )
if (thinghere.contents.sfx > 0) then
sfx( thinghere.contents.sfx )
end
if (thinghere.contents == upladder) then
switchto( controller_ladder_up )
return
end
if (thinghere.contents == downladder) then
switchto( controller_ladder_down )
return
end
if (thinghere.contents == chest) then
switchto( controller_open_chest )
return
end
if (thinghere.contents == fountain) then
switchto( controller_fountain )
return
end
if (thinghere.contents == empty) then
if (d(100) < 10) then
switchto( controller_combat_start )
return
end
end
end,

draw = function()
if (not isdirty) then return end
isdirty = false
drawmazeview()
gamestate.draw()
end,

}


controller_fountain = {

focus = function()
controller_modal.show(
"you find a\nfountain.\ndrink?",
{
{ "drink",
function()
controller_fountain.drink()
end },
{ "do not drink",
function()
switchto( controller_explore )
end },
}, 0, 0 )
end,
drink = function()

override( fountainx )
local val = d(4)
local t = "refreshing!"

if (val == 1) then
sfx(3)
t = "it heals\nyour group!"
for i = 1,#gamestate.heroes do
local hero = gamestate.heroes[ i ]
hero.condition = 0
hero.hp = min( gamestate.maxhp( hero ), hero.hp + d(10))
end
end

if (val == 2) then
local hero = pickfrom( gamestate.heroes )
if (hero.hp > 0 and camera.z > 1) then
if (hero.condition == 0) then
sfx(6)
hero.condition = 1
t = "oh no! it is\npoisonous!"
end
end
end

if (val == 3) then
sfx(7)
local found = d(10) + camera.z*2
t = "you find\n$" .. found .. "\nin the\nfountain!"
gamestate.gold += found
end

if (val == 4) then
sfx(3)
t = "it energizes\nyour group!"
for i = 1,#gamestate.heroes do
local hero = gamestate.heroes[ i ]
hero.mp = min( gamestate.maxmp( hero ), hero.mp + 5 )
end
end

controller_modal.notice(
t,
"okay",
0,0,
function()
switchto( controller_explore )
end
)
end,

}





gamestate = {

newgame = function()
contentoverrides = {}
gamestate.gold = 20
camera = { facing = 1, x = 1, y = 1, z = 1 }
gamestate.heroes = {}

add( gamestate.heroes,
{
name= "soldier",
hpperlevel= 5,
weaponname = "sword",
armorname = "chain",
shieldname = "shield",
portrait = { 16, 64 },
attackbonus = 10,
spellcaster = false,

icon = 192,
strength = 1,
intelligence = 1,
dexterity = 1,
constitution = 1,
hp = 16,
mp = 0,
condition = 0,
weapon = 0,
armor = 0,
shield = 0,
accessory = 0,
xp = 0,
level = 1,
class = 1
})
add( gamestate.heroes,
{
name= "rogue",
hpperlevel= 4,
weaponname = "knife",
armorname = "vest",
shieldname = "shield",
portrait = { 32, 64 },
attackbonus = 5,
spellcaster = false,

icon = 193,
strength = 1,
intelligence = 1,
dexterity = 1,
constitution = 1,
hp = 16,
mp = 0,
condition = 0,
weapon = 0,
armor = 0,
shield = 0,
accessory = 0,
xp = 0,
level = 1,
class = 2
})
add( gamestate.heroes,
{
name= "priest",
hpperlevel= 3,
weaponname = "mace",
armorname = "scale",
shieldname = "none",
portrait = { 48, 64 },
attackbonus = 4,
spellcaster = true,
icon = 194,

strength = 1,
intelligence = 1,
dexterity = 1,
constitution = 1,
hp = 15,
mp = 3,
condition = 0,
weapon = 0,
armor = 0,
shield = 0,
accessory = 0,
xp = 0,
level = 1,
class = 3
})
add( gamestate.heroes,
{
name= "mage",
hpperlevel= 2,
weaponname = "staff",
armorname = "robes",
shieldname = "none",
portrait = { 64, 64 },
attackbonus = 2,
spellcaster = true,

icon = 195,
strength = 1,
intelligence = 1,
dexterity = 1,
constitution = 1,
hp = 14,
mp = 3,
condition = 0,
weapon = 0,
armor = 0,
shield = 0,
accessory = 0,
xp = 0,
level = 1,
class = 4
})

end,

conditionlabel = function( hero )
if (hero.hp < 1) then return { "dead", 8 } end
if (hero.condition == 1) then return { "poisoned", 11 } end
if (hero.condition == 2) then return { "stone", 7 } end
return { "ok", 5 }
end,

isactive = function( hero )
if (hero.hp < 1) then return false end
if (hero.condition == 2) then return false end
return true
end,

randomactiveplayer = function()
local actives = {}
for i = 1,#gamestate.heroes do
local hero = gamestate.heroes[i]
if (gamestate.isactive( hero )) then
add( actives, hero )
end
end
if (#actives == 0) then return nil end
return actives[ d( #actives ) ]
end,

draw = function()

rectfill( 67, 0, 127, 66, 0 )
rect( 66, 0, 127, 66, 2 )

rectfill( 0, 67, 127, 127, 0 )

print( 'gold:', 70, 3, 5 )
printr( '$' .. gamestate.gold, 124, 3, 9 )

printc( 'hero', 15, 70, 5 )
printc( 'hp', 40, 70, 5 )
printc( 'mp', 68, 70, 5 )
printc( 'condition', 102, 70, 5 )
for i = 1,#(gamestate.heroes) do
local hero = gamestate.heroes[i]
if (activehero == hero) then
print( ">", 3, 66 + i * 12 + 4, 10 )
end
line( 3, 66 + i * 12, 124, 66 + i * 12, 1 )
spr( hero.icon, 10, 66 + i * 12 + 2 )
if ( hero.hp < 1 ) then
printc( "dead", 40, 66 + i*12 + 4, 8 )
else
printc( hero.hp .. "/" .. gamestate.maxhp( hero ), 40, 66 + i*12 + 4, 5 )
end
printc( hero.mp .. "/" .. gamestate.maxmp( hero ), 68, 66 + i*12 + 4, 5 )

local condition = gamestate.conditionlabel( hero )
printc( condition[1], 102, 66 + i*12 + 4, condition[2] )
end

rect( 0, 66, 127,127, 2 )

end,

maxhp = function( hero )
local hp = 10 + hero.constitution
local hpperlevel = 3
if (hero.class == 1) then hpperlevel = 5 end
if (hero.class == 2) then hpperlevel = 4 end
hp += hpperlevel * hero.level
if (hp > 99) then return 99 end
return hp
end,

maxmp = function( hero )
if (hero.class == 1) then return 0 end
if (hero.class == 2) then return 0 end
return hero.intelligence + hero.level * 2
end,

xptonextlevel = function( hero )
return (hero.level+1) * (hero.level+1) - hero.xp
end,

heal = function( hero, amount )
if (hero.hp < 1) then return end
hero.hp = min( hero.hp + amount, gamestate.maxhp( hero ))
end,

energize = function( hero, amount )
hero.mp = min( hero.mp + amount, gamestate.maxmp( hero ))
end,

savegame = function()

dset( 0, 1 )
dset( 1, gamestate.gold )
dset( 2, camera.x )
dset( 3, camera.y )
dset( 4, camera.z )

for slot=1,4 do
gamestate.savehero( slot, gamestate.heroes[ slot ] )
end

end,



loadgame = function()

gamestate.newgame()

if (dget(0) ~= 1) then return end

gamestate.gold = dget( 1 )
camera.x = dget( 2 )
camera.y = dget( 3 )
camera.z = dget( 4 )

for i = 1,4 do
gamestate.loadhero( i )
end

end,

savehero = function( heroslot, hero )

local base = (heroslot-1) * 14 + 5

if (hero == nil) then
dset( base, 0 )
return
end

dset( base, hero.icon )
dset( base + 1, hero.strength )
dset( base + 2, hero.intelligence )
dset( base + 3, hero.dexterity )
dset( base + 4, hero.constitution )
dset( base + 5, hero.hp )
dset( base + 6, hero.mp )
dset( base + 7, hero.condition )
dset( base + 8, hero.weapon )
dset( base + 9, hero.armor )
dset( base + 10, hero.shield )
dset( base + 11, hero.xp )
dset( base + 12, hero.level )

end,

loadhero = function( heroslot )

local hero = gamestate.heroes[ heroslot ]

local base = (heroslot-1) * 14 + 5
if (dget(base) == 0) then return nil end

hero.icon = dget( base )
hero.strength = dget( base + 1 )
hero.intelligence = dget( base + 2 )
hero.dexterity = dget( base + 3 )
hero.constitution = dget( base + 4 )
hero.hp = dget( base + 5 )
hero.mp = dget( base + 6 )
hero.condition = dget( base + 7 )
hero.weapon = dget( base + 8 )
hero.armor = dget( base + 9 )
hero.shield = dget( base + 10 )
hero.xp = dget( base + 11 )
hero.level = dget( base + 12 )

return hero

end

}
controller_ladder_down = {

focus = function()
controller_modal.show(
"you find a\nladder down.\nclimb down?",
{
{ "climb down", function()
isdirty = true;
camera.z += 1;
switchto( controller_explore )
end },
{ "stay", function()
switchto( controller_explore )
end },
}, 0, 0 )
end

}


controller_ladder_up = {

focus = function()
controller_modal.show(
"you find a\nladder up.\nclimb up?",
{
{ "climb up",
function()
if (camera.z == 1) then
switchto( controller_town )
else
camera.z -= 1
switchto( controller_explore )
end
end },
{ "stay",
function()
switchto( controller_explore )
end },
}, 0, 0 )
end

}



spells = {}

add( spells, {
name = "locate",
class = {3},
level = 1,
incombat = false,
outcombat = true,
cast= function( hero )
endspell(
"you are at:\n" ..
camera.x .. " east\n" ..
camera.y .. " south\n" ..
camera.z .. " down\n" ..
"facing " .. facings[ camera.facing ].label,
hero )
end
})

add( spells, {
name = "escape",
class = {4},
level = 5,
incombat = true,
outcombat = true,
cast= function( hero )
if (camera.z > 3) then
endspell( "escape spell\nfizzles!\noh, no!", hero )
return
end
sfx(3)
camera.x = 1
camera.y = 1
camera.z = 1
monster = nil
switchto( controller_town )
return
end
})

add( spells, {
name = "fleetfoot",
class = {3},
level = 1,
incombat = true,
outcombat = false,
cast= function( hero )
monster.chase = monster.chase - 50
endspell( "party's feet\nmove faster!", hero )
end
})

add( spells, {
name = "stunbolt",
class = {3,4},
level = 1,
incombat = true,
outcombat = false,
cast= function( hero )
monster.active -= 1
endspell( "you stun\n" .. monster.name .. "!", hero )
end
})

add( spells, {
name = "cure",
class = {3},
level = 3,
incombat = true,
outcombat = true,
cast= function( hero )
local portrait = spellportrait( hero )
controller_choose_hero.show(
"cure who?",
function( recipient )
if (recipient.hp < 1) then
endspell( "the spell\nfizzles!", hero )
return
end
recipient.condition = 0
recipient.hp = min( gamestate.maxhp( recipient ), recipient.hp + d(10))
endspell( "you heal them\na bit and\ncure any\nconditions!", hero )
end,
portrait.x, portrait.y,
function()
end
);
end
})

add( spells, {
name = "heal",
class = {3},
level = 2,
incombat = true,
outcombat = true,
cast= function( hero )
local portrait = spellportrait( hero )
controller_choose_hero.show(
"cure who?",
function( recipient )
if (recipient.hp < 1) then
endspell( "the spell\nfizzles!", hero )
return
end
recipient.hp = min( gamestate.maxhp( recipient ), recipient.hp + d(10) + hero.intelligence)
endspell( "you heal them\na bit and\ncure any\nconditions!", hero )
end,
portrait.x, portrait.y,
function()
end
);
end
})

add( spells, {
name = "allheal",
class = {3},
level = 5,
incombat = true,
outcombat = true,
cast= function( hero )
local portrait = spellportrait( hero )
for i=1,#gamestate.heroes do
local hero = gamestate.heroes[i]
hero.hp = min( gamestate.maxhp( hero ),
hero.hp + d( hero.intelligence + hero.level + 3 ))
end
endspell( "you heal\nthe party!", hero )
end
})

add( spells, {
name = "holy bolt",
class = {3},
level = 1,
incombat = true,
outcombat = false,
cast= function( hero )
local offense = hero.intelligence * 2 + 1
if (monster.isundead == true) then
offense = offense + hero.level * hero.level + 3
end
controller_strike_enemy.strike( hero, offense, 1 )
end
})

add( spells, {
name = "firebolt",
class = {4},
level = 1,
incombat = true,
outcombat = false,
cast= function( hero )
local offense = hero.level * 2 + hero.intelligence * 2 + 3
controller_strike_enemy.strike( hero, offense, 1 )
end
})

function spellportrait( hero )
local px = hero.portrait[1]
local py = hero.portrait[2]
if (monster ~= nil) then
px = monster.portraitx
py = monster.portraity
end
return { x = px, y = py }
end

function endspell( withtext, hero )
local portrait = spellportrait( hero )
local action = function()
switchto( controller_explore )
end
if (monster ~= nil) then
action = function()
controller_player_option.nextplayer()
end
end
controller_modal.notice(
withtext,
"continue",
portrait.x, portrait.y, action
)
end

function findspellsfor( hero )
local options = {}
for i = 1,#spells do
local spell = spells[i]
local addspell = true
if (indexof( spell.class, hero.class ) == 0) then addspell = false end
if (monster == nil and spell.outcombat == false) then addspell = false end
if (monster ~= nil and spell.incombat == false) then addspell = false end
if (spell.level > hero.mp) then addspell = false end
if (spell.level > hero.level) then addspell = false end
if (addspell) then
add( options, {
spell.level .. ": " .. spell.name, function()
hero.mp -= spell.level
spell.cast( hero )
end
})
end
end
return options
end

controller_cast_spell_in_combat = {
choose = function( hero )
local options = findspellsfor( hero )
if (#options == 0) then
controller_modal.notice(
"no spells\nyou can\ncast right\nnow.",
"okay",
monster.portraitx,
monster.portraity,
function()
switchto( controller_player_option )
end
)
return
end
controller_modal.show(
"cast spell?",
options,
monster.portraitx,
monster.portraity,
function()
switchto( controller_player_option )
end
)
end
}

controller_cast_spell_in_camp = {
choose = function( hero )
controller_cast_spell_in_camp.hero = hero
local options = findspellsfor( hero )
if (#options == 0) then
controller_modal.notice(
"no spells\nyou can\ncast right\nnow.",
"okay",
hero.portrait[1], hero.portrait[2],
function()
controller_examine_hero.examine( controller_cast_spell_in_camp.hero )
end
)
return
end
controller_modal.show(
"cast spell?",
options,
hero.portrait[1], hero.portrait[2],
function()
controller_examine_hero.examine( controller_cast_spell_in_camp.hero )
end
)
end
}

cls()

isdirty = true

camera = { facing = 1, x = 1, y = 1, z = 1 }

facings = {
{ forward = { dx = 1, dy = 0 }, left = { dx = 0, dy = 1 }, label = "east" },
{ forward = { dx = 0, dy = 1 }, left = { dx = -1, dy = 0 }, label = "south" },
{ forward = { dx = -1, dy = 0 }, left = { dx = 0, dy = -1 }, label = "west" },
{ forward = { dx = 0, dy = -1 }, left = { dx = 1, dy = 0 }, label = "north" }
}

contentoverrides = {}

map = {
{
"################",
"#<             #",
"#   ########## #",
"#   +        # #",
"# ########## # #",
"# ##> ##   # # #",
"# ##  ## f   # #",
"# ###s##   # # #",
"# #$  ###### # #",
"# #$ >###### # #",
"# ##########+# #",
"# f##f    f#   #",
"# ###>     #>  #",
"# #####++##### #",
"#              #",
"################",
},
{
"################",
"  ##f##   #   # ",
"f ## ## f # f # ",
"  ## ##   #   # ",
" ##   ## ### ###",
"+## < ##+###+###",
"  +   +         ",
"# ##############",
"# ###      +   #",
"# s #<##s### f #",
"# #>###$ # +   #",
"#+######## #####",
"#   #<  ## #<  #",
"# f ### ## ### #",
"#   ##f        #",
"################",
},
{
"################",
"#             ##",
"#+########f## ##",
"#   ###f##### ##",
"#   s    >### ##",
"#   ###f##### ##",
"#   #########+##",
"#+#+#######    #",
"# #   +        #",
"# ###+#####   f#",
"# #<      ###+##",
"#+###+### #    #",
"#   #   # +    #",
"#   +   #####+##",
"#f  #   +     ##",
"################",
},
{
"################",
"#####===########",
"#####=f=########",
"#####= ====#####",
"#####=   <=#####",
"#===== ====#####",
"#=$    =########",
"#===== ===######",
"#####=  f=######",
"#####== ==######",
"######= =#######",
"####=== ===#####",
"####=$   $=#####",
"####=======#####",
"################",
"################",
}
}

empty = { move = 1, sfx = 0 }
door = { tleft = 8, ttop = 0, transparent = -1, block = 0, move = 2, sfx = 2 }
secret = { tleft = 24, ttop = 0, transparent = -1, block = 0, move = 2, sfx = 2 }
wall = { tleft = 24, ttop = 0, transparent = -1, block = 0, move = 0, sfx = 1 }
wall2 = { tleft = 56, ttop = 16, transparent = -1, block = 0, move = 0, sfx = 1 }
chest = { tleft = 56, ttop = 0, transparent = 1, move = 1, sfx = 3 }
fountain = { tleft = 72, ttop = 0, transparent = 2, move = 1, sfx = 3 }
fountainx = { tleft = 72, ttop = 16, transparent = 2, move = 1, sfx = 0 }
downladder = { tleft = 88, ttop = 0, transparent = 3, move = 1, sfx = 3 }
upladder = { tleft = 104, ttop = 0, transparent = 3, move = 1, sfx = 3 }
vines1 = { tleft = 8, ttop = 16, transparent = 9, move = 1, sfx = 0 }
vines2 = { tleft = 24, ttop = 16, transparent = 9, move = 1, sfx = 0 }

darkening = {
{ 0,0,0,0,0,0 }, {1,1,1,0,0,0}, { 2,2,1,1,0,0 }, {3,3,3,1,1,0},
{ 4,2,2,1,1,0 }, {5,5,1,1,1,0}, { 6,6,13,5,1,0}, {7,7,6,13,1,0},
{ 8,8,2,2,1,0 }, {9,4,2,2,1,0}, {10,9,4,2,1,0}, {11,11,3,3,1,0},
{12,12,13,5,1,0}, {13,13,5,1,0,0}, {14,14,4,2,1,0}, {15,9,4,2,1,0} }

function tileat( x, y, z )
if (x < 0) then return tileat( x+16, y, z ) end
if (x >= 16) then return tileat( x-16, y, z ) end
if (y < 0) then return tileat( x, y+16, z ) end
if (y >= 16) then return tileat( x, y-16, z ) end
local glyph = sub( map[z][y+1], x+1, x+1 )

if (indexof( {" ","f",">","<","$","1","2"}, glyph ) > 0) then return empty end
if (glyph == "+") then return door end
if (glyph == "s") then return secret end
if (glyph == "=") then return wall2 end

return wall

end

function override( withwhat )
overrideat( camera.x, camera.y, camera.z, withwhat )
end

function overrideat( x, y, z, withwhat )

x = mod16(x)
y = mod16(y)

local here = contentsat( x, y, z )
if (here == downladder) then return end
if (here == upladder) then return end

local key = x .. ":" .. y .. ":" .. z
contentoverrides[ key ] = withwhat
end

function contentsat( x, y, z )

x = mod16(x)
y = mod16(y)

local glyph = sub( map[z][y+1], x+1, x+1 )

local key = x .. ":" .. y .. ":" .. z
if (contentoverrides[key] ~= nil) then return contentoverrides[key] end

if (glyph == "f") then return fountain end
if (glyph == ">") then return downladder end
if (glyph == "<") then return upladder end
if (glyph == "$") then return chest end
if (glyph == "1") then return vines1 end
if (glyph == "2") then return vines2 end
return empty

end

function camtile( cam, stepsleft, stepsforward )

local facing = facings[ cam.facing ]
local x = mod16(cam.x)
local y = mod16(cam.y)
local z = mod16(cam.z)

x = x + stepsforward * facing.forward.dx
y = y + stepsforward * facing.forward.dy
x = x + stepsleft * facing.left.dx
y = y + stepsleft * facing.left.dy

return { tile = tileat( x, y, z ), contents = contentsat( x, y, z ) }

end





function drawflat( projection, depth, tile )

if (tile == empty) then return end

for x=0,projection[width] do
ramp = x / projection[width]
height = round( (projection[left_height] + 0.5) * (1.0 - ramp) +
(projection[right_height] + 0.5) * ramp )
top = round( projection[left_top] * (1.0 - ramp) +
projection[right_top] * ramp)
for y=0,height do
vramp = y/height
c = sget( round( ramp * 15 ) + tile.tleft,
round( vramp * 15 ) + tile.ttop )
if (c ~= tile.transparent) then
c = darkening[c+1][depth+1]
pset( projection[left] + x, top + y, c )
end
end
end
end


function drawmazeview()

local tilehere

clip( 0, 0, 66, 66 )
rectfill( 0, 0, 66, 66, 0 )



front = 1
side = 2
contents = 3

for i=1, #projections do
local projection = projections[i]
projection[brush] = nil
local tile = camtile( camera, projection[to_left], projection[forward] )
if (projection[tiletype] == contents) then
projection[brush] = tile.contents
else
projection[brush] = tile.tile
end
end

local projectionsdrawn = 0


local shoulddraw = true
for i=1, #projections do
local thisprojection = projections[i]
if (thisprojection[brush] == empty) then
else
local visiblerange = {
max( 0, thisprojection[left] ),
min( 65, thisprojection[left] + thisprojection[width] )
}
for j=i+1, #projections do
local futureprojection = projections[j]
if (futureprojection[tiletype] == contents) then
elseif (futureprojection[brush] == empty) then
else
occlude( visiblerange, {
futureprojection[left],
futureprojection[left] + futureprojection[width]
})
end
end
if (visiblerange[2] > visiblerange[1]) then
projectionsdrawn += 1
drawflat( thisprojection, thisprojection[depth], thisprojection[brush] )
end
end

end

clip()

rect( 0, 0, 66, 66, 2 )

end

function occlude( visiblerange, overlapper )
if (overlapper[1] <= visiblerange[1]) then
visiblerange[1] = max( visiblerange[1], overlapper[2] )
end
if (overlapper[2] >= visiblerange[2]) then
visiblerange[2] = min( visiblerange[2], overlapper[1] )
end
end



controller_modal = {
notice = function( text, prompt, imagex, imagey, action )
controller_modal.show( text,
{ { prompt, action } },
imagex, imagey,
action
)
end,
show = function( textofchoice, choicelist, imagex, imagey, cancelaction )
controller_modal.text = textofchoice
controller_modal.choices = choicelist
controller_modal.imagex = imagex
controller_modal.imagey = imagey
controller_choose_sprite.cancel = cancelaction
switchto( controller_modal )
end,
focus = function()
choice = 1
isdirty = true
end,
update = function()
if (btnp(2)) then
choice = max( choice - 1, 1 )
sfx(4)
isdirty = true
end
if (btnp(3)) then
choice = min( choice + 1, #controller_modal.choices )
sfx(4)
isdirty = true
end
if (btnp(4)) then
isdirty = true
sfx(5)
controller_modal.choices[ choice ][2]()
end
if (btnp(5)) then
sfx(1)
if (controller_choose_sprite.cancel ~= nil) then
controller_choose_sprite.cancel()
end
end
end,
draw = function()
if (not isdirty) then return end
isdirty = false
rectfill( 0,0,66,66,0)
if (controller_modal.imagex == 0 and controller_modal.imagey == 0) then
drawmazeview()
else
sspr(controller_modal.imagex,controller_modal.imagey,16,16,1,1,65,65)
end
rect( 0, 0, 66, 66, 2 )
gamestate.draw()
print( controller_modal.text, 70, 10, 2 )
for i = 1, #controller_modal.choices do
local y = 66 - #controller_modal.choices*6 + i*6 - 7
if (i == choice) then
print( ">", 70, y, 10 )
print( controller_modal.choices[i][1], 75, y, 7 )
else
print( controller_modal.choices[i][1], 75, y, 5 )
end
end

showmonstercount()
end,
}

controller_choose_hero = {
show = function( textofchoice, choiceaction, imagex, imagey, cancelaction )
controller_choose_hero.choiceaction = choiceaction
local options = {}
for i = 1, #gamestate.heroes do
add( options, { gamestate.heroes[i].icon,
function( which )
controller_choose_hero.choiceaction( gamestate.heroes[ which ] )
end } )
end
controller_choose_sprite.show( textofchoice, options, imagex, imagey, cancelaction )
end,
}


controller_choose_sprite = {
show = function( textofchoice, choicelist, imagex, imagey, cancelaction )
controller_choose_sprite.text = textofchoice
controller_choose_sprite.choices = choicelist
controller_choose_sprite.imagex = imagex
controller_choose_sprite.imagey = imagey
controller_choose_sprite.cancel = cancelaction
switchto( controller_choose_sprite )
end,
focus = function()
choice = 1
isdirty = true
end,
update = function()
if (btnp(0)) then
choice = max( choice - 1, 1 )
sfx(4)
isdirty = true
end
if (btnp(1)) then
choice = min( choice + 1, #controller_choose_sprite.choices )
sfx(4)
isdirty = true
end
if (btnp(4)) then
isdirty = true
sfx(5)
controller_choose_sprite.choices[ choice ][2](choice)
end
if (btnp(5)) then
sfx(1)
if (controller_choose_sprite.cancel ~= nil) then
controller_choose_sprite.cancel()
end
end
end,
draw = function()
if (not isdirty) then return end
isdirty = false
rectfill( 0,0,66,66,0)
if (controller_choose_sprite.imagex == 0 and controller_choose_sprite.imagey == 0) then
drawmazeview()
else
sspr(controller_choose_sprite.imagex,controller_choose_sprite.imagey,16,16,1,1,65,65)
end
rect( 0, 0, 66, 66, 2 )
gamestate.draw()
print( controller_choose_sprite.text, 70, 10, 2 )
local totalwidth = #controller_choose_sprite.choices * 12
local x = 66 + 31 - totalwidth/2 + 1
local y = 54
for i = 1, #controller_choose_sprite.choices do
spr( controller_choose_sprite.choices[i][1], x, y )
if (i == choice) then
rect( x-2, y-2, x+9, y+9, 9 )
end
x = x + 12
end
showmonstercount()
end,
}


function showmonstercount()
if (monster ~= nil) then
rectfill( 33 - 5, 66 - 4, 33 + 4, 66 + 3, 0 )
rect( 33 - 5, 66 - 4, 33 + 5, 66 + 4, 2 )
printc( monster.number .. "", 34, 66-2, 8 )
end
end


endgame = {
finish = function(text1,text2,portraitx,portraity)
endgame.info = { text1, text2, portraitx, portraity }
setactivehero( 0 )
monster = nil
choice = -64
switchto( endgame )
end,
update = function()
if (btnp(5)) then switchto( mainmenu ) end
end,
draw = function()
local info = endgame.info
palt(0, false)
fadeout()
choice = min( 0, choice + 2 )
sspr(info[3],info[4],16,16,32,choice,64,64)
rect(32,choice,96,choice+64,5)
rectfill( 32, 64, 96, 78, 0 )
rect( 32, 64, 96, 78, 5 )
printc( info[1], 65, 66, 7 )
printc( info[2], 64, 66+6, 7 )
printc( "x: main menu", 65, 107, 5 )
end,
}

function fadeout()
for i=1,900 do
x = d(128)-1
y = d(128)-1
pset( x, y, darkening[pget( x, y )+1][4])
end
end

monsters = {
rat = {
name = "rat",
portraitx = 16,
portraity = 80,
number = 8,
numberperlevel = 1,
maxhp = 2,
hpperlevel = 1,
chase = 50,
offense = 2,
defense = 2,
},
snake = {
name = "snake",
portraitx = 32,
portraity = 80,
number = 1,
numberperlevel = 1,
maxhp = 5,
hpperlevel = 2,
chase = 50,
offense = 4,
defense = 4,
poisonous = 1
},
skeleton = {
name = "skeleton",
portraitx = 80,
portraity = 64,
number = 4,
numberperlevel = 1,
maxhp = 10,
hpperlevel = 2,
chase = 50,
offense = 5,
defense = 5,
isundead = true,
},
fanatic = {
name = "fanatic",
portraitx = 0,
portraity = 80,
number = 4,
numberperlevel = 1,
maxhp = 10,
hpperlevel = 2,
chase = 50,
offense = 4,
defense = 4,
},
orc = {
name = "orc",
portraitx = 96,
portraity = 64,
number = 3,
numberperlevel = 1,
maxhp = 12,
hpperlevel = 3,
chase = 50,
offense = 4,
defense = 4,
},
medusa = {
name = "medusa",
portraitx = 48,
portraity = 80,
number = 1,
numberperlevel = 0,
maxhp = 30,
hpperlevel = 5,
chase = 100,
offense = 10,
defense = 10,
stones = 1,
},
lich = {
name = "lich",
portraitx = 112,
portraity = 80,
number = 1,
numberperlevel = 0,
maxhp = 1000,
hpperlevel = 0,
chase = 200,
offense = 20,
defense = 20,
isundead = 1,
}
}

monstersbylevel = {
{ "rat", "orc", "fanatic" },
{ "rat", "skeleton", "orc" },
{ "skeleton", "orc", "snake", "medusa" },
{ "lich" },
}

function makemonster(forlevel)
local monstertype = pickfrom( monstersbylevel[ forlevel ] )
local monster = copy( monsters[ monstertype ] )
monster.number = d( monster.number ) + (forlevel - 1) * monster.numberperlevel
monster.maxhp += (forlevel - 1) * monster.hpperlevel
monster.hp = monster.maxhp
monster.offense += forlevel * 3
monster.defense += forlevel * 3
monster.chase += forlevel * 3
return monster
end

controller_open_chest = {

focus = function()
controller_modal.show(
"you find a\nchest.\nopen it?",
{
{ "open it",
function()
override( empty )
gamestate.gold += 7 + d(5) + 5 * camera.z
isdirty = true
switchto( controller_explore )
end },
{ "ignore it",
function()
switchto( controller_explore )
end },
}, 0, 0 )
end

}





front = 1
side = 2
contents = 3

to_left = 1
forward = 2
depth = 3
tiletype = 4
left = 5
width = 6
left_top = 7
right_top = 8
left_height = 9
right_height = 10
brush = 11


projections = {

{ 0, 5, 4, front, 29, 8, 29, 29, 8, 8 },      -- (0, 5 front)
{ -1, 4, 4, side, 26, 3, 26, 29, 14, 8 },      -- (-1 4 side)
{ -1, 4, 4, front, 13, 13, 26, 26, 14, 14 },    -- (-1 4 front)
{ 1, 4, 4, side, 37, 3, 29, 26, 8, 14 },      -- (1 4 side)
{ 1, 4, 4, front, 40, 13, 26, 26, 14, 14 },      -- (1 4 front)
{ 0, 4, 4, contents, 27, 12, 28, 28, 12, 12 },    -- (0 4, contents)
{ 0, 4, 3, front, 26, 14, 26, 26, 14, 14 },      -- (0 4, front)
{ -2, 3, 4, side, 1, 12, 22, 26, 22, 14 },      -- (-2 3, side)
{ 2, 3, 4, side, 53, 12, 26, 22, 14, 22 },      -- (2 3, side)
{ -1, 3, 3, contents, 1, 20, 24, 24, 20, 20 },    -- (-1 3, contents)
{ -1, 3, 3, side, 22, 4, 22, 26, 22, 14 },      -- (-1 3, side)
{ -1, 3, 3, front, 0, 22, 22, 22, 22, 22 },      -- (-1 3, front)
{ 1, 3, 3, contents, 45, 20, 24, 24, 20, 20 },    -- (1 3, contents)
{ 1, 3, 3, side, 40, 4, 26, 22, 14, 22 },      -- (1 3, side)
{ 1, 3, 3, front, 44, 22, 22, 22, 22, 22 },      -- (1 3, front)
{ 0, 3, 3, contents, 23, 20, 24, 24, 20, 20 },    -- (0 3, contents)
{ 0, 3, 2, front, 22, 22, 22, 22, 22, 22 },      -- (0 3, front)
{ -1, 2, 1, contents, -13, 28, 19, 19, 28, 28 },  -- (-1,2, contents)
{ -1, 2, 2, side, 17, 5, 17, 22, 32, 22 },      -- (-1 2, side)
{ -1, 2, 2, front, -14, 31, 17, 17, 32, 32 },    -- (-1,2, front)
{ 1, 2, 1, contents, 51, 28, 19, 19, 28, 28 },    -- (1,2, contents)
{ 1, 2, 2, side, 44, 5, 22, 17, 22, 32 },      -- (1 2, side)
{ 1, 2, 2, front, 49, 31, 17, 17, 32, 32 },      -- (1,2, front)
{ 0, 2, 1, contents, 19, 28, 19, 19, 28, 28 },    -- (0,2, contents)
{ 0, 2, 1, front, 17, 32, 17, 17, 32, 32 },      -- (0,2, front)
{ -1, 1, 1, contents, -37, 44, 11, 11, 44, 44 },  -- (-1, 1, contents)
{ -1, 1, 1, side, 9, 8, 9, 17, 48, 32 },      -- (-1, 1, side)
{ -1, 1, 1, front, -39, 48, 9, 9, 48, 48 },      -- (-1, 1 front)
{ 1, 1, 0, contents, 59, 44, 11, 11, 44, 44 },    -- (1, 1, contents)
{ 1, 1, 1, side, 49, 8, 17, 9, 32, 48 },      -- (1, 1, side)
{ 1, 1, 1, front, 57, 49, 9, 9, 48, 48 },      -- (1, 1 front)
{ 0, 1, 0, contents, 11, 44, 11, 11, 44, 44 },    -- (0, 1, contents)
{ 0, 1, 0, front, 9, 48, 9, 9, 48, 48 },      -- (0, 1 front)
{ -1, 0, 0, side, -2, 11, -2, 9, 70, 48 },      -- (-1,0,side)
{ 1, 0, 0, side, 57, 11, 9, -2, 48, 70 },      -- (1,0,side)
{ 0, 0, 0, contents, 4, 58, 4, 4, 58, 58 }      -- (0, 0 interior)

}

controller_town = {

focus = function()
setactivehero( 0 )
controller_modal.show(
"sleepy hollow.\nwhere to go?",
{
{ "blacksmith", function()
switchto( controller_smith )
end },
{ "inn", function()
switchto( controller_inn )
end },
{ "tavern", function()
switchto( controller_tavern )
end },
{ "temple", function()
switchto( controller_temple )
end },
{ "dungeon", function()
switchto( controller_explore )
end }
}, 0, 64 )
end,

}

controller_tavern = {
focus = function()
if (gamestate.gold < 5) then
controller_modal.notice(
"you do not have\nenough gold\n(costs $5.)",
"darn",
0, 64,
function()
switchto( controller_town )
end)
return
end
controller_tavern_review.player = 1
controller_modal.show(
"visit the\npub to reflect\non your\nexperiences\nand save game?\n(costs $5)",
{
{ "cheers!", function()
gamestate.gold -= 5
switchto( controller_tavern_review )
end
},
{ "not now", function()
switchto( controller_town )
end
}
},
0, 64,
function()
switchto( controller_town )
end)
return
end
}

controller_tavern_review = {
focus = function()
if (controller_tavern_review.player > #gamestate.heroes) then
gamestate.savegame()
switchto( controller_town )
return
end
local hero = gamestate.heroes[ controller_tavern_review.player ]
setactivehero( hero )
controller_tavern_review.hero = hero
controller_tavern_review.player += 1
local tolevel = gamestate.xptonextlevel( hero )
if (tolevel > 0) then
controller_modal.notice(
hero.name .. " needs\n" ..
tolevel .. "xp\nto level up.",
"okay",
0, 64,
function()
switchto( controller_tavern_review )
end)
return
end
controller_tavern_review.hero.level += 1
controller_modal.show(
hero.name .. "\nlevels up!\nhuzzah!",
{
{ "+1 muscle", function()
controller_tavern_review.hero.strength += 1
switchto( controller_tavern_review )
end
},
{ "+1 smarts", function()
controller_tavern_review.hero.intelligence += 1
switchto( controller_tavern_review )
end
},
{ "+1 agility", function()
controller_tavern_review.hero.dexterity += 1
switchto( controller_tavern_review )
end
},
{ "+1 grit", function()
controller_tavern_review.hero.constitution += 1
switchto( controller_tavern_review )
end
},
},
0, 64,
function()
switchto( controller_tavern_review )
end)
end,
}

controller_temple = {
focus = function()
setactivehero( 0 )
controller_choose_hero.show(
"examine who?",
function( hero )
controller_temple.offerhealing( hero )
end,
0, 64,
function()
switchto( controller_town )
end
);
end,
offerhealing = function( hero )
setactivehero( hero )
controller_temple.hero = hero
local cost = 0
local t = hero.name .. " needs:\n"
if (hero.hp < 1) then
cost += max(100, hero.level * hero.level * 10)
t = t .. " * raising\n"
end
if (hero.condition == 1) then
cost += max(10, hero.level * 10)
t = t .. " * detox\n"
end
if (hero.condition == 2) then
cost += max(50, hero.level * hero.level * 5)
t = t .. " * destone\n"
end
if (cost == 0) then
controller_modal.notice(
"that hero\nappears fine.",
"okay",
0, 64,
function()
switchto( controller_temple )
end)
return
end
t = t .. "\ncost: $" .. cost
if (cost > gamestate.gold) then
t = t .. "\nnot enough\ngold!"
controller_modal.notice(
t,
"darn",
0, 64,
function()
switchto( controller_temple )
end)
return
end
controller_temple.cost = cost
controller_modal.show(
t,
{
{ "okay do it", function()
controller_temple.confirm()
end },
{ "never mind", function()
switchto( controller_temple )
end },
}, 0, 64,
function()
switchto( controller_temple )
end )
end,
confirm = function()
local hero = controller_temple.hero
if (hero.hp < 1) then
hero.hp = 1
end
gamestate.gold -= controller_temple.cost
hero.condition = 0
controller_modal.notice(
"the priests\nlay hands and\nchant.\n\nsuccess!",
"thanks",
0, 64,
function()
switchto( controller_temple )
end)
return
end,
}

controller_smith = {
focus = function()
setactivehero( 0 )
controller_choose_hero.show(
"who enters?",
function( hero )
controller_smith.enter( hero )
end,
0, 64,
function()
switchto( controller_town )
end
);
end,
enter = function( hero )
controller_smith_chosen.hero = hero
switchto( controller_smith_chosen )
end,
}

controller_smith_chosen = {
focus = function()
local hero = controller_smith_chosen.hero
setactivehero( hero )
local options = {}
add( options, {
hero.weaponname .. " $" .. controller_smith_chosen.costtoimproveweapon( hero ),
function()
controller_smith_chosen.improveweapon()
end })
add( options, {
hero.armorname .. " $" .. controller_smith_chosen.costtoimprovearmor( hero ),
function()
controller_smith_chosen.improvearmor()
end })
if( hero.shieldname ~= "none" ) then
add( options, {
"shield $" .. controller_smith_chosen.costtoimproveshield( hero ),
function()
controller_smith_chosen.improveshield()
end })
end
add( options, { "leave",
function()
switchto( controller_smith )
end })
controller_modal.show( "what item\nto improve?", options, 0, 64, function()
switchto( controller_smith )
end );
end,
costtoimproveweapon = function( hero )
return (hero.weapon + 1) * (hero.weapon + 1) * 10
end,
costtoimprovearmor = function( hero )
return (hero.armor + 1) * (hero.armor + 1) * 10
end,
costtoimproveshield = function( hero )
return (hero.shield + 1) * (hero.shield + 1) * 5
end,
improveweapon = function()
local cost = controller_smith_chosen.costtoimproveweapon( controller_smith_chosen.hero )
if (gamestate.gold < cost) then
controller_smith_chosen.reject();
return
end
gamestate.gold -= cost
local hero = controller_smith_chosen.hero
hero.weapon += 1
controller_modal.show(
"the smith\nimproves your\nweapon!",
{
{ "yay", function()
switchto( controller_smith )
end }
}, 0, 64 )
end,
improvearmor = function()
local cost = controller_smith_chosen.costtoimprovearmor( controller_smith_chosen.hero )
if (gamestate.gold < cost) then
controller_smith_chosen.reject();
return
end
gamestate.gold -= cost
local hero = controller_smith_chosen.hero
hero.armor += 1
controller_modal.show(
"the smith\nimproves your\narmor!",
{
{ "yay", function()
switchto( controller_smith )
end }
}, 0, 64 )
end,
improveshield = function()
local cost = controller_smith_chosen.costtoimproveshield( controller_smith_chosen.hero )
if (gamestate.gold < cost) then
controller_smith_chosen.reject();
return
end
gamestate.gold -= cost
local hero = controller_smith_chosen.hero
hero.shield += 1
controller_modal.show(
"the smith\nimproves your\nshield!",
{
{ "yay", function()
switchto( controller_smith )
end }
}, 0, 64 )
end,
reject = function()
controller_modal.show(
"you do not\nhave the money\nto pay!",
{
{ "oops", function()
switchto( controller_smith )
end }
}, 0, 64 )
end,
}

controller_inn = {

focus = function()

if (gamestate.gold < 10) then
controller_modal.show(
"naughty nymph\nyou don't have\nenough gold to\nstay here.\nit costs $10.\nsorry!",
{
{ "leave", function()
switchto( controller_town )
end }
}, 0, 64 )
else
controller_modal.show(
"naughty nymph\nwant to stay?\nit costs $10",
{
{ "stay night", function()
controller_inn.stay()
end },
{ "leave", function()
switchto( controller_town )
end }
}, 0, 64 )
end

end,

stay = function()
contentoverrides = {}
gamestate.gold -= 10
for i = 1,#gamestate.heroes do
gamestate.heal( gamestate.heroes[i], 99 )
gamestate.energize( gamestate.heroes[i], 99 )
end
controller_modal.show(
"naughty nymph\n\nyou stay the\nnight and wake\nup refreshed!",
{
{ "ok", function()
switchto( controller_town )
end }
}, 0, 64 )
end,


}
__gfx__
00000000111111111111111111111111111111110000000000000000111111111111111122222222222222223333333333333333000000000000000000000000
00000000166655666655666116665566665566610666556666533660111111111111111122222222222222223333333333333333301104000040110300000000
007007001666556666556661166655666655666106665566665b3660111111111111111122222222222222223333333333333333330004244240003300000000
000770001550000000000551155555555555555105555555555305501111111111111111222227c2222222223333333333333333333304000040333300000000
0007700015602222222205611566655666655661056665566663566011111111111111112222c22c2c7222223333333333333333333304244240333300000000
0070070015602444444205611566655666655661056665566b30566011111111111111112222722cc22c22223333333333333333333304000040333300000000
0000000015502444444205511555555555555551055555555305555011111111111111112222c205502722223333333333333333333304033040333300000000
0000000016502444444206511666556666556661066655666355666011110000000111112222c205602c22223333333333333333333330333303333300000000
00000000165024444442065116665566665566610666556333b56660111020444440111122000000000000223333303333033333333333333333333300000000
00000000155024444442055115555555555555510555555b00355550111042044444011120665665665665023333040330403333333333333333333300000000
00000000156024444662056115666556666556610566655066335660111002044044011122015555555510223333040000403333333333333333333300000000
00000000156024444662056115666556666556610566655666035660111020000a00011122201111111102223333042442403333333333333333333300000000
000000001550244444420551155555555555555105555555555b5550111024040a04011122220000000022223333040000403333333333333333333300000000
00000000165024444442065116665566665566610666556666536660111024044044011122222201502222223300042442400033333333333333333300000000
00000000165024444442065116665566665566610666556666506660100002044444011122222015660222223011040000401103333333333333333300000000
00000000155024444442055115555555555555510555555555555550110000000000011122220155566022220000000000000000333333333333333300000000
0000000090b333333333bb0990bb333333333b090000080560000000222222222222222222222222222222220000000000000000000000000000000000000000
00000000990300b000030099903030bb0b003b0900009005600980002fff44ffff44fff222222222222222220000000000000000000000000000000000000000
00000000990300a0303b09999030b3030a0030a00000a005600a00002fff44ffff44fff222222222222222220000000000000000000000000000000000000000
00000000990b0900303009990a0903030090b9090006660560666000244444444444444222222222222222220000000000000000000000000000000000000000
000000009990b090303b099990990303090b0999000055011055000024fff44ffff44ff222222222222222220000000000000000000000000000000000000000
000000009990b090b00b09999990b00b090b0999000001556650000024fff44ffff44ff222222220022222220000000000000000000000000000000000000000
0000000099903090b00b0999990a090b090309990000000000000000244444444444444222222205502222220000000000000000000000000000000000000000
000000009903090a0030999999909900a003099900000000000000002fff44ffff44fff222222205602222220000000000000000000000000000000000000000
0000000099903090990a0999999999990030999900000000000000002fff44ffff44fff222000000000000220000000000000000000000000000000000000000
000000009990b099999099999999999990b099990000000000000000244444444444444220665665665665020000000000000000000000000000000000000000
00000000990a09999999999999999999990a0999000000000000000024fff44ffff44ff222015555555510220000000000000000000000000000000000000000
0000000099909999999999999999999999909999000000000000000024fff44ffff44ff222201111111102220000000000000000000000000000000000000000
00000000999999999999999999999999999999990000000000000000244444444444444222220000000022220000000000000000000000000000000000000000
000000009999999999999999999999999999999900000000000000002fff44ffff44fff222222201502222220000000000000000000000000000000000000000
000000009999999999999999999999999999999900000000000000002fff44ffff44fff222222015660222220000000000000000000000000000000000000000
00000000999999999999999999999999999999990000000000000000244444444444444222220155566022220000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaa990009999900aaa0aa0000099a0000aaa99909aaaaaaa0000999000000000000000000000000000000000000000000000000000000000000000000000
000aaa09990009990000a000aa00000a000aaa0000900aaa00090099909990000000000000000000000000000000000000000000000000000000000000000000
000aa900990009aa0000a000aa90000a00aaa00000000aaa00000099000990000000000000000000000000000000000000000000000000000000000000000000
000aa90099900aaa0000a000a999000a00aaa00000000aaa00900999000999000000000000000000000000000000000000000000000000000000000000000000
000a990099900aaa0000a0009099a00a00a9900000000aaa9990099900099a000000000000000000000000000000000000000000000000000000000000000000
000a990099a00aaa0000a000900aaa0a0099900aaaa00aaa0090099900099a000000000000000000000000000000000000000000000000000000000000000000
000999009aa00aaa000090009000aaaa00999000aaa00aa90000099900099a000000000000000000000000000000000000000000000000000000000000000000
00099900aaa00aaa0000900090000aaa00099000aaa00a99000909990009aa000000000000000000000000000000000000000000000000000000000000000000
00099900aaa000a990090000a00000a900099a00aaa0099900090999000aaa000000000000000000000000000000000000000000000000000000000000000000
00099a00aaa000099990000aaa00000900000aaaaaa0999999990999000aaa000000000000000000000000000000000000000000000000000000000000000000
0009aa00aa0000000000000000000000000000000000000000000099000aa0000000000000000000000000000000000000000000000000000000000000000000
000aaa0aaa000000000000000000000000000000000000000000009990aaa0000000000000000000000000000000000000000000000000000000000000000000
009aaaaaa0009999999aaaaaaaa99999aaaaaaaa9999999999990000aaa000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa09009099900000a000a009900a00a000000990090090999099a0a0009000000000000000000000000000000000000000000000000000000000000000000
000a009009090000000a00090900a0a00a00000900909009090009000aa009000000000000000000000000000000000000000000000000000000000000000000
000a009999099900000a0009090000aaaa0000090090900909990aaa0a0a09000000000000000000000000000000000000000000000000000000000000000000
000a009009090000000a00090a00a0a00a0000090090900909000a000a0099000000000000000000000000000000000000000000000000000000000000000000
000900900909aa00000aa90900aa00a00900000099000990099a0aaa0a0009000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000244400056000000000000000000000000000000a700b33f3f33b00000dd000000000000000000000000000000000000000000001000
00000000000000000000244444005670000111100011100000000000000a00903f3f3f3b00000ddc000000007770000000000000000000000100011111000000
00000000000001000000222422005670001111110110011100000000000900a03f3f43333b000dcc000000067676000000000000bbb00b00000011ccc1100010
0000100000010000000027027000567000111111101100000000000000009a0034f4f3ff3000dddd0000000670600000a000000333b3b30010011cc7cc110000
0010000000500000000024444400567000072074000000000000000000009700b34f4ff30000dddd00000005677700007a09000818bb30001001cc7a7cc11000
05000000004444200000020004005670004424410011110000000000000044400b4fff3b000ccccc00024405060600009790000bbbb3000000011cc7a7cc1000
044442000444444206666024400056700011111001111111000444400004222000444300555555550000220040000000094b00a11a300000000011ccc7cc1000
44444420001111105666600000005670000111100111100000244444000444400b00000dd55000050006000044440000903bb0333303bb0000100111ccc11100
01111100005a5a505666660566005670000000000000011100222422000042200004400d55fffff000660040420000000033b00000333bb0100000011111c100
05a5a50000555550566666055660567000011901100000110027027000090000000441000044f44f00000244206600000003040033033bbb100001000001c100
35555533333333335666660555095670042429777777701100244244000998800d0401600007e076006090220005560000300340000330bb110000000011c100
33333349994443305566660055509999a42429666666100100220004009988000d100166006feff6000960000000006000331034033003b311110000111cc100
05555555599954405566660005500000a4242955550000000002004400998000011001d66066666600957600000006560033100040003bb301c111001c1c1101
0004444444499994555566000006556002220900000100000902244099998000001101d1606eee6520005760000006060003103304bb0b310111c11111c11000
0000000005555550055550050500665000000000110004448900000099988000000101d1d0566650222005760000000000000000003bb0000001cccc11110010
000000000000000005555050500655600000000000004242880889900988000000001111110555010020005700000000000000033033b00010011cc110000000
0009000077777700000002ee2200000000000000000000000000003bbbb000000000000000000000000000000000000000000001111000000000000000c00000
00029077aaaaaa700000000ee22000000000bbbbb0000000bbbb0333333bb0000000000000000000000000000000000000000001c1170000000000000c7c0650
000027aaaa000aa70000000445442222000bb033bb000000333bb33000333ba00000000000000000000006666660500000000001111110000000000000c00656
00fff9a000000000000000454442eee00033bb003bb000003033300333033337000000000000000000066666666605000000000011c110000567770000000656
04f4f29000000000005004444400ee00003bb30703b3000000330003300000000000000000000000006666666666605000000000011110005567777006006506
04ff409000ffff000005045440112200033b333000bb300030030ff00f03000000000000000000000060066060066050000000000071c0005566777700655656
9944402004fff4f005004444070224020bb03b233bbbbb000303070f700bb0000000000000000000006060606060605000000000001110005555655700065060
29040e00044f44f0005544441022440503b03b822333bb300300fffeff033b000000000000000000006006606006605000077770001c10005500700700105500
00000e00007e0780000444442224420003b033b82203333033b0fffff0033bb0000000000000000030606060606660500077500700c100205500700701060010
00288ee00888888000ee444118222020033a03338226006033b00feef00033b00000000000000000306666666666605007775000501000000066507001506010
002888e0028888800088428202820005033ba0033887007003b000ff000003b00000000000000000006660000006605007776775000060100005050001006010
002288ee0228880000656500200004400033ba9003333000033bb00000300bb00000000000000000006004442240600307765006500600200500000011050210
0002888e0022200000006082004404440003bba90000000000333ba00100bb000000000000000000300222444444003006665006000560000050505101000210
0002288ee00000ee244000000064060400033baa900000000100a337010bba000000000000000000004444444444200305555550005600102006660101002210
00002228882ff2e8622420220060060600003bbaa900000011000070011707000000000000000000022440004442203300555550555002202000000001102110
00000022282002226060000000000006000033baa900000011101000111010000000000000000000004400444420030000000000000000002102102010102100
0000000600000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044006640110004204400a400dc00f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000440060104400004044090400ff0dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06655150001111140999990040ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066550000001100604089000f4dcd0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0661100000011000020aa000040dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006101000010100004089900040dc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000505000050500002088900040ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000d0700d070100000a00000000010001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001b170111700d1701320009200082000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000151701a1701e170231701d17016170101700c170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000b7700d7700f77011770157701a7702377030700090000800008000187001b7001e7002170023700277002a7002c7000b0000d0001000013000190001d00000000000000000000000000000000000000
000800001404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000210702b070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001a3701a370193701637016370113700c3700c370063701d3001d3001d300103001030010300103000f3000f3001030010300103001030010300103000f3000f3000e3000e3000c1000b1000000000000
000300001b7301d7301d7201971015710127100d72008710066000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000100101201015020190301e040230502867026670256501c6300c610036100261001610016100161000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000f210112201322016230192401c2501f250222502667026670246702366022650216401f6401e6301d6301c630196301662012620106200f6200b6200761006610066100561002610016100160001600
001000001c3401c1201a3401a1201c3401c12028440284402844012100080000a00013100131001310012100000001a000191001d10021100251002a1002a1002f0002c000280000000000000000000000000000
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
