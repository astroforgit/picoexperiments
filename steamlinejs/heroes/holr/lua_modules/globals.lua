                                                                   
                                                   
                                 
                                     

COLS = 5
ROWS = 5
NODE_W = 12
NODE_H = 10
GRID_X = 0
GRID_Y = 10

UNIT_MOVE_TIME = 0.5

KINDS = {
 spearman = {
  ap = 2,
  hp = 3,
  dmg = 2,
  dist = 1,
  gfx_name = "spearman"
 },
 archer = {
  ap = 1,
  hp = 3,
  dmg = 1,
  dist = 4,
  gfx_name = "archer"
 },
 swordsman = {
  ap = 2,
  hp = 4,
  dmg = 3,
  dist = 1,
  gfx_name = "swordsman"
 },
 beast = {
  ap = 3,
  hp = 3,
  dmg = 2,
  dist = 1,
  gfx_name = "beast"
 },
 ogre = {
  ap = 2,
  hp = 5,
  dmg = 4,
  dist = 1,
  gfx_name = "ogre"
 },
 skeleton = {
  ap = 1,
  hp = 3,
  dmg = 1,
  dist = 4,
  gfx_name = "skeleton"
 },
 dark = {
  ap = 2,
  hp = 4,
  dmg = 3,
  dist = 1,
  gfx_name = "dark"
 },
 demon = {
  ap = 2,
  hp = 2,
  dmg = 2,
  dist = 1,
  gfx_name = "demon"
 },
 sniper = {
  ap = 2,
  hp = 3,
  dmg = 1,
  dist = 5,
  gfx_name = "sniper"
 },
 warlock = {
  ap = 1,
  hp = 7,
  dmg = 1,
  dist = 3,
  summon = "demon",
  gfx_name = "warlock"
 },
 minibeast = {
  ap = 3,
  hp = 3,
  dmg = 1,
  dist = 1,
  gfx_name = "minibeast"
 }
}

BATTLES = {
 {
  name = "BEAST LAIR",
  units = {
   "minibeast",
   "minibeast"
  },
  reward = 50,
  env = "grass",
  trees = 3
 },
 {
  name = "RUINS",
  units = {
   "beast",
   "beast",
   "beast"
  },
  reward = 100,
  env = "grass",
  trees = 1
 },
 {
  name = "ELDER RUINS",
  units = {
   "demon",
   "demon",
   "demon",
   "demon",
   "demon"
  },
  reward = 110,
  env = "grass",
  trees = 2,
  req = "RUINS"
 },
 {
  name = "FOREST",
  units = {
   "beast",
   "beast",
   "beast",
   "beast",
   "minibeast"
  },
  reward = 120,
  env = "grass",
  trees = 3,
  req = "ELDER RUINS"
 }, 
 {
  name = "CRYPT",
  units = {
   "skeleton",
   "dark",
   "dark",
   "skeleton",
  },
  env = "dirt",
  trees = 1,
  reward = 120
 },
 {
  name = "DEEP FOREST",
  units = {
   "beast",
   "beast",
   "ogre",
   "beast",
   "beast"
  },
  reward = 150,
  env = "grass",
  trees = 3,
  req = "FOREST"
 }, 
 {
  name = "GRAVEYARD",
  units = {
   "skeleton",
   "dark",
   "dark",
   "dark",
   "skeleton"
  },
  env = "grass",
  trees = 1,
  reward = 160,
  req = "CRYPT"
 },
 {
  name = "MERRY MEN",
  units = {
   "sniper",
   "sniper",
   "ogre",
   "sniper",
   "sniper"
  },
  env = "grass",
  trees = 2,
  reward = 200,
  req = "GRAVEYARD",
  once = true
 },
 {
  name = "OGRE CAMP",
  units = {
   "beast",
   "ogre",
   "ogre",
   "ogre",
   "beast"
  },
  env = "grass",
  trees = 2,
  reward = 200,
  req = "MERRY MEN",
  once = true
 },
 {
  name = "WARLOCK",
  units = {
   "skeleton",
   "warlock",
   "demon",
   "skeleton",
   "demon"
  },
  env = "dirt",
  trees = 2,
  reward = 1000,
  req = "OGRE CAMP",
  final = true
 },
 [0] = {
  name = "PRELUDE",
  units = {
   "warlock"
  },
  reward = 1000,
  env = "grass",
  trees = 2
 }
}

PRICE = {
 tower = 100,
 workshop = 110,
 blacksmith = 130,
 spearman = 25
}

UPGRADE_REQ = {
 archer = {
  unit = "spearman",
  building = "workshop",
  cost = 40
 },
 swordsman = {
  unit = "spearman",
  building = "blacksmith",
  cost = 50
 }
}

JUST_BUILT = {}
UPGRADE_UNIT_I = -1
BATTLE_I = 0
DEFEATED = false

SNAPSHOT = {                   
 gold = 7777,
 buildings = {
  tower = true,
  workshop = true,
  blacksmith = true
 },
 units = {
  "archer",
  "swordsman",
  "swordsman",
  "swordsman",
  "archer",
 },
 battles_done = {["GRAVEYARD"]=true, ["MERRY MEN"]=true, ["OGRE CAMP"]=true},
}

INTRO = {
 "An evil warlock is\nsettled nearby",
 "No one feels\nsafe now",
 "And when reward\nwas offered..",
 "two heroes went\nto try their luck"
}

CREDIT_DELAY = 4.1
GODZILLA_DELAY = 20
CREDITS = {
 "The bad Warlock\nis no more",
 "He shuffled off\nhis mortal coil",
 "and became\nan ex warlock",
 "His minions\nscattered",
 "Here comes\none of them ",
 "That is not our\nproblem anymore",
 "We were paid\nfor the Warlock", 
 "THANKS FOR\nPLAYING!",
 "game by\nFil Shutenko",
 "made for\nLOWREZJAM 2021",
 "made with\nDEFOLD",
 "music made with\nBOSCA CEOIL",
 "pixel art\nmade with mouse",
 "font by\nJack Oatley",
 "THANKS FOR\nPLAYING!"
}

function reset_snapshot()
 SNAPSHOT = {
  gold = 100,
  buildings = {
   tower = false,
   workshop = false,
   blacksmith = false
  },
  units = {
   "spearman",
   "spearman"
  },
  battles_done = {},
 }
end

function party_strength(units)
 local s = 0
 for _, name in pairs(units) do
  local unit = KINDS[name]
  local unit_s = unit.ap*0.5 + unit.hp + unit.dmg + unit.dist*0.75
  if unit.summon then unit_s = unit_s + 10 end
  s = s + unit_s
 end
 return s
end