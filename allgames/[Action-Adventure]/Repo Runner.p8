pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
  key.init(key)
  level.init(level)
  -- ui.init(ui)
  -- stage.init(stage)
  player.init(player)
  dialogue.init(dialogue)
  encounter.init(dialogue)
  music(1,1)
end

function _draw()
  cls()

  if level.i == -1 then
    ui.drawstart(ui)
  else
    stage.draw(stage)
    if (ui.mode == "repo" or level.getlevel().repo) stage.drawrepo(stage)
    ui.draw(ui)
    if (ui.mode == "jobdone") ui.drawreview(ui)
    if (ui.mode == 'dialogue') dialogue.draw(dialogue)
    if (ui.mode == 'encounter') encounter.draw(encounter)
  end
  if (level.levelchanging) level.drawlevelchange(level)
end

function _update()

  if key[4].down then
    sfx(13,-1,1,1)
  end
  if key[4].up then
    sfx(13,-1,0,1)
  end
  key.update(key)
  if level.i == -1 then
    if key[4].up then
      level.next(level)
    end
  else
    if ui.mode == 'standby' then
      stage.driveinput(stage)
      stage.drive(stage)
      if key[4].up then
        ui.mode = "scanning"
        ui.scanner.timer = 0
        ui.scanner.car = stage.road[stage.getcntcar(stage)]
      end
    elseif ui.mode == "match" then
      if key[4].down then
      end
      if key[4].up then
        level.l[level.i].finishtime = stage.gettimeleft(stage)
        if stage.gettimeleft(stage) < level.getlevel().time/3 then
          ui.mode = "encounter"
          encounter.gen(encounter)
        else
          ui.mode = "repo"
          stage.setcarrepo(stage,stage.getcntcar(stage))
        end
      end
    elseif ui.mode == 'encounter' then
      encounter.update(encounter)
      if key[4].up then
        encounter.next(encounter)
      end
      if key[2].down or key[3].down then
        sfx(13,-1,1,1)
      end
    elseif ui.mode == 'timeup' then
      stage.driveofshame(stage)
    elseif ui.mode == "jobdone" then
      if key[4].up then
        level.next(level)
      end
    end
    ui.update(ui)
    stage.update(stage)
  end
  level.update(level)
end
-->8
player={}
function player.init(self)
  self.money = 0
  self.debt = 3000
end
-->8
ui={}
function ui.init(self,mode)
  self.mode = mode or "standby"
  self.scanner = {}
  self.scanner.timer = -1
  self.scanner.car = {}
end

function ui.update(self)
  if self.mode == 'dialogue' then
    dialogue.update(dialogue)
  end
  if self.mode == "scanning" then 
    self.scanner.timer += 1
    if self.scanner.timer > 48 then
      if self.scanner.car.lic == stage.targetlic then
        self.mode = "match"
        sfx(16,2)
      else
        self.mode = "standby"
        sfx(17,2)
      end
      self.scanner.timer = -1
    end
  end

  if self.mode == "repo" then
    stage.repotimer += 1
    if stage.repotimer < 132 and
      stage.gettimeleft(stage) < level.getlevel().time/4 and
      not level.getlevel().encounter
    then
      ui.mode = "encounter"
      encounter.gen(encounter)
    end
    if stage.repotimer > 256 then
      self.mode = "jobdone"
      player.money += level.getlevel().bounty
      player.money += ceil(level.getlevel().finishtime)
      sfx(2,2)
      music(-1,750)
    end
  end
end

function ui.drawstart(self)
  rectfill(0,0,127,127,1)
  pal(1,0)
  local clawt = mod(t(),2)
  stage.drawclaw(stage,84,
    animval(clawt,0,1,0,16) or
    animval(clawt,1,2,16,0))
  clawt = mod(clawt + .5,2)
  stage.drawclaw(stage,40,
    animval(clawt,0,1,0,16) or
    animval(clawt,1,2,16,0))
  clawt = mod(clawt + .5,2)
  stage.drawclaw(stage,-4,
    animval(clawt,0,1,0,16) or
    animval(clawt,1,2,16,0))
  pal()
  stage.drawcar(4,88,10,1)
  stage.drawcar(48,88,12,1)
  stage.drawcar(92,88,8,1)
  rectfill(0,120,127,127,0)
  local logoy = 38
  spr(192,20,logoy,11,4)
  -- spr(203,52,50,3,2)
  spr(235,44,logoy+26,5,2)
  local substr = 'press z to start'
  local subxy = cntstr(substr,0,0,127,127)
  print(substr,subxy[1],subxy[2]+20,
    animflash(1) and 7 or 1)
  local cred = 'BY JULIUS TARNG'
  local credxy = cntstr(cred,0,120,127,8)
  print(cred,credxy[1],credxy[2],5)
end
dialogue={}
function dialogue.init(self)
  dialogue.i = 0
  dialogue.d = {}
  dialogue.d[0] = {}
  dialogue.d[0].t = "welcome to your first day at repo co! i'm reapy and i'm your partner starting now!"
  dialogue.d[1] = {}
  dialogue.d[1].t = "at repo co, we repossess vehicles from our debtees who haven't paid up."
  dialogue.d[2] = {}
  dialogue.d[2].t = "check your dashboard for info about the target's color and license plate."
  dialogue.d[3] = {}
  dialogue.d[3].t = "drive with ‹‘, and press z to scan the plate."
  dialogue.d[4] = {}
  dialogue.d[4].t = "now lets find this car before the driver gets here!"
end
function dialogue.next(self)
  self.i += 1
  if self.i > #dialogue.d then
    self.i = #dialogue.d
    ui.mode = 'standby'
  end
end
function dialogue.prev(self)
  self.i -= 1
  if self.i < 0 then self.i = 0 end
end
function dialogue.update(self)
  if ui.mode == 'dialogue' and
    not level.levelchanging then
    if key[4].up or key[5].up or key[1].up then
      dialogue.next(self)
    end
    if key[0].up or key[2].up then
      dialogue.prev(self)
    end
  end
end
function dialogue.draw(self,t,sx,sy,sw,sh)
  local x = 0
  local y = 0
  local h = 32
  local w = 32
  rectfill(0,y,127,y+h,0)
  if sx and sy and sw and sh then
    local clr = stage.road[stage.targeti].clr
    pal(13,clr)
    pal(4,12)
    sspr(sx,sy,sw,sh,1,1,w,h,true)
    pal()
  else
    drawscanner(1,y)
  end
  local dx = w+2
  local dp = 4
  rectfill(dx,y,127,y+h,15)
  pal(1,15)
  spr(116,w-6,y+h-3,1,1,true)
  pal(1,0)
  spr(116,dx,y)
  pal()
  spr(116,120,y,1,1,true)
  spr(116,120,y+h-8,1,1,true,true)
  pset(dx-1,y+h,1)
  pset(dx,y+h,1)
  local d = dialogue.d[dialogue.i]
  -- local name = d.n
  -- print(name,dx+dp,y+dp,7)
  local dw = 127-dx-dp-dp
  local t = wwrap(t and t or d.t,dw)
  print(t,dx+dp,y+dp,1)
  -- border
  line(0,y+h,127,y+h,1)
  -- rect(0,y,w+1,y+h,1)
  -- frame the main window
  spr(116,1,y+h+1)
  spr(116,119,y+h+1,1,1,true)
end

function ui.drawreview(self)
  local l = level.getlevel()
  if l.repo then
    local y = 22
    local ftime =tostr(l.finishtime)
    local bounty = "$"..l.bounty
    local bonus = "$"..ceil(l.finishtime)
    local total = "$"..player.money
    dialogue.draw(dialogue,
      'good job! you earned '..bounty..
      ', with a bonus '..bonus..
      ' for your time of '..ftime..
      '. see you tmrw!')
  else
    dialogue.draw(dialogue,
      'the target got away... try harder tomorrow...'
    )
  end
end

function ui.draw(self)
  local padx = 3
  local dashx = 0
  local dashh = 26
  local dashy = 127-dashh
  --dash
  rectfill(dashx,dashy,127,127,1)
  local wellh = 14
  -- round UI corners
  spr(116,1,9)
  spr(116,119,9,1,1,true)
  spr(116,1,127-dashh-8,1,1,false,true)
  spr(116,119,127-dashh-8,1,1,true,true)
  --color
  if dialogue.i > 1 then
    -- rectfill(dashx,dashy-6,dashx+18,dashy,1)
    -- print('TRGT',dashx+2,dashy-5,7)
    local clrrect = drawcolor(
      2,
      dashy+padx,
      wellh,wellh,
      stage.targetclr)
    --license
    local licrect = drawlicense(
      clrrect[3]+padx,
      dashy+padx,
      59,wellh,
      stage.targetlic)
    --button
    if dialogue.i > 2 then
      local showscan = self.mode=='standby' or self.mode=='scanning'
      local showrepo = self.mode=="match" or self.mode=="repo" or self.mode=="encounter" or (self.mode=="jobdone" and level.getlevel().repo)
      local flashbut = self.mode=='match'
      drawbut(licrect[3]+padx,
        dashy+padx,
        122-padx-licrect[3]-padx+9,
        wellh,
        (self.mode=="match" or self.mode=='standby') and key[4].held,
        showrepo,
        flashbut)
    end
  end
  --scanne
  drawscanner((128-32)/2,dashy-32)
  -- timer and money 
  rectfill(0,0,127,8,1)
  local l = level.getlevel()
  local t = l.repo and l.finishtime or max(stage.gettimeleft(stage),0)
  spr(118,2,2)
  print(t,8,2,7)
  drawmoney(player.money,2,2)
  rectfill(0,8,0,127,1)
  rectfill(127,8,127,127,1)

end
function drawmoney(val,xinset,y)
  local moneyx = 127-(#tostr(val)*4)-4
  spr(117,moneyx-xinset,y)
  print(val,moneyx +6 - xinset,y,7)
end
function drawbut(x,y,w,h,active,repo,flash)
  if repo then
    local flash = flash and animflash(1)
    pal(1,flash and 14 or 8)
    pal(6,14)
  else
    pal(1,3)
    pal(6,11)
  end
  pal(2,1)
  spr(69,x,y,1,2)
  sspr(6*8-1,32,1,16,x+8,y,31,16)
  spr(74,x+w-9,y,1,2)
  if active then
    fillp(0b1010010110100101)
    local clrbit = repo and 0x8e or 0x3b
    rectfill(x+2,y+2,x+w-4,y+h-1,clrbit)
    rectfill(x+4,y+1,x+w-5,y+h,clrbit)
    fillp()
  end
  -- label
  pal(6,1)
  pal(7,1)
  local repooff = repo and 7 or 0
  sspr(13*8-1,32+repooff,18,4,x+20,y+6)
  pal(6,7)
  pal(7,7)
  sspr(13*8-1,32+repooff,18,4,x+20,y+5)
  -- icon
  pal(11,active and 3 or 11)
  if repo then spr(107,x+3,y,2,2)
  else spr(109,x+3,y,2,2) end
  -- print('scan',x+15,y+5,7)
  pal()
  local labelxy = cntstr('PRESSZ',x,y,w,h,true)
  print("PRESS Z",labelxy[1]-1,y+h+2,7)
end
function drawlicense(x,y,w,h,id)
  rectfill(x,y,x+w,y+h,7)
  local idxy = cntstr(id,x,y,w,h)
  print(id,idxy[1],idxy[2]+1,1)
  local labelxy = cntstr('LIC',x,y,w,h,true)
  print("LIC",labelxy[1],y+h+2,7)
  spr(116,x,y)
  spr(116,x+w-7,y,1,1,true)
  spr(116,x,y+h-7,1,1,false,true)
  spr(116,x+w-7,y+h-7,1,1,true,true)
  return {x,y,x+w,y+h}
end
function drawcolor(x,y,w,h,clr)
  rectfill(x,y,x+w,y+h,clr)
  print("CLR",x+2,y+h+2,7)
  spr(116,x,y)
  spr(116,x+w-7,y,1,1,true)
  spr(116,x,y+h-7,1,1,false,true)
  spr(116,x+w-7,y+h-7,1,1,true,true)
  return {x,y,x+w,y+h}
end
function drawscanner(x,y)
  if ui.mode == 'match' or
    ui.mode == 'repo' or
    ui.mode == 'encounter' or
    (ui.mode == 'scanning' and animflash(.2)) then
    pal(8,11)
  end
  spr(64,x,y,4,4)
  pal()
  if ui.mode == 'scanning' then
    drawscanlines(y)
    local scanx = x+16+(cos(t())*13)
    rectfill(scanx,y+15,scanx,y+24,11)
  elseif ui.mode == 'repo' then
    print("TOWING", x+4,y+17,11)
  elseif ui.mode == 'encounter' then
    local s = 102
    if encounter.current.i == 1 then
      s = encounter.current.resi == 1 and 101
        or 104
    end
    spr(s,x+(2*8)-4,y+16)
  elseif ui.mode == 'jobdone' then
    -- keep here to prevent license rendering
  elseif ui.scanner.car.lic then
    if ui.scanner.car.lic == "" then
      print("NO CAR", x+4,y+17,11)
    else
      print(ui.scanner.car.lic,x+5,y+18,0)
      print(ui.scanner.car.lic,x+4,y+17,ui.scanner.car.clr)
    end
  end
  if ui.mode == 'dialogue' or ui.mode == 'jobdone' then
    local s = 101
    if ui.mode == 'dialogue' then
      s = animflash(1) and 101 or 102
      if dialogue.i == 3 then
        s = animflash(1) and 101 or 103
      end
    elseif level.getlevel().repo then
      s = 103
    else
      s = 104 
    end
    spr(s,x+(2*8)-4,y+16)
  end
end
function drawscanlines(y)
  local x = 63
  local xoff = stage.getcaroffset(stage)
  local t = ui.scanner.timer
  if (t==1) sfx(10)
  local y2 = animval(t,0,12,y-30,y-30) or 
    animval(t,12,24,y-30,y-30) or
    animval(t,24,32,y-30,y-2) or 
    y-2
  local x2 = animval(t,0,12,x,x) or
    animval(t,12,24,x,x-18) or
    animval(t,24,36,x-18,x-18) or
    animval(t,36,48,x-18,x) or
    x
  if mod(t,3) == 0 then
    line(x,y+9,x2+xoff,y2+2,11)
    line(127-x,y+9,127-x2+xoff,y2+2,11)
  end
end
-->8
level={}
function level.init(self)
  self.i = -1
  self.l = {}
  self.l[0] = {}
  self.l[0].time = 20
  self.l[0].roadlength = 30
  self.l[0].bounty = 150
  self.l[0].finishtime = 0
  self.l[0].repo = false
  self.l[0].multicolor = false
  self.l[0].encounter = false
  self.l[1] = {}
  self.l[1].time = 20
  self.l[1].roadlength = 60
  self.l[1].bounty = 300
  self.l[1].repo = false
  self.l[1].multicolor = false
  self.l[1].encounter = false
  self.levelchanging = false
  self.levelchangetime = 0
  self.levelchangepaused = false
  self.genlevels(self)
end
function level.getlevel()
  return level.l[level.i]
end
function level.genlevels(self)
  for i=2,99 do
    self.l[i] = {}
    self.l[i].time = 30
    self.l[i].roadlength = max(60 + (10*i),128)
    self.l[i].bounty = self.l[i].roadlength * 4
    self.l[i].repo = false
    self.l[i].multicolor = true
    self.l[i].encounter = false
  end
end
function level.next(self)
  if not self.levelchanging then
    self.levelchangetime = 0
    self.levelchanging = true
    music(-1,750)
    sfx(-2,0)
    sfx(-2,1)
    sfx(-2,2)
    sfx(-2,3)
  end
end
function level.update(self)
  if self.levelchanging then
    if self.levelchangetime == 35 and
      not self.levelchangepaused then
      sfx(13)
      self.levelchangepaused = true

      if self.i > -1 then
        if level.getlevel().encounter and encounter.current and encounter.current.i > 0 and
            encounter.current.type == 'mad' and
            encounter.current.resi == 1 then
          player.money -= 650
        elseif stage.luck <.05 then
          player.money -= 800
        elseif stage.luck>.05 and stage.luck<.1 then
          player.money -= 500
        end
        if self.getlevel().repo == false then
          player.money -= 100
        end
      end
    end
    if self.levelchangetime == 35 then
      if key[4].up then
        self.levelchangepaused = false
      end
    end
    if not self.levelchangepaused then
      self.levelchangetime += 1
    end
    if self.levelchangetime == 36 and not self.levelchangepaused then
      if player.money >= player.debt then
        _init()
      else
        -- actually change level
        self.i += 1
        if self.i > #self.l then
          self.i = 0
        end

        ui.init(ui,(self.i == 0) and 'dialogue')
        stage.init(stage)
        music(0,1)
      end
    elseif self.levelchangetime == 84 then
      self.levelchanging = false
    end
  end
end

function level.drawlevelchange(self)
  local y = animval(self.levelchangetime,0,36,0,132)
    or animval(self.levelchangetime,36,48,132,132)
    or animval(self.levelchangetime,48,84,132,0)
  rectfill(0,0,127,y,0)
  rectfill(0,y+2,127,y+2,0)
  if self.levelchangepaused then
    -- rectfill(0,0,127,64,15)
    local s = "day "..(self.i + 2).."\n\n"
    if self.i == -1 then
      s = s.."citizen, you have an outstanding debt. "..
        "\n\nsince you are unable to pay, you are now employed "..
        "by repo co. work hard as a repo runner!"
    elseif player.money >= player.debt then
      s = s.."congratulations, you have paid off your debt.\n\n"..
      "see you next time..."
    else
      if self.getlevel().repo then 
        if level.getlevel().encounter and encounter.current and encounter.current.i > 0 and
          encounter.current.type == 'mad' and
          encounter.current.resi == 1 then
          s=s.."your nose was broken. the e.r. charged you $650 to fix it."
        elseif stage.luck <.025 then
          s = s.."your child is sick. the medicine costs $800."
        elseif stage.luck>.024 and stage.luck<.05 then
          s = s.."you crashed your car on your way home. it costs $500 to repair."
        end
      else
        s = s.."you have been docked $100 for your failure today."
      end
    end
    print(wwrap(s,112),8,8,7)

    print("debt",8,93,7)
    drawmoney(player.debt,8,93)
    print("collected",8,100,7)
    drawmoney(player.money,8,100)
    line(8,107,119,107,7)
    print("remaining",8,110,7)
    drawmoney(max(player.debt-player.money,0),8,110)
  end
end
-->8
stage={}
function stage.init(self)
  self.road = {}
  self.pos = 0
  self.acc = 0
  self.carw = 38
  self.repotimer = 0
  self.timeuptimer = 0
  self.timeuppos = 0
  self.luck = (level.i == 0) and 1 or rnd(1)
  self.validcolors = {2,3,6,8,9,10,12,13}
  self.targetclr = self.validcolors[flr(rnd(#self.validcolors)) + 1]

  -- gen road
  local curlevel = level.getlevel()
  local roadlength = curlevel.roadlength
  for i = 0,roadlength do
    self.road[i] = {}
    local r = rnd(1)
    if i==0 or i==2 or  r < .5 or i==roadlength then
      local carclr = self.validcolors[flr(rnd(#self.validcolors)) + 1]
      while carclr == self.targetclr do
         carclr = self.validcolors[flr(rnd(#self.validcolors)) + 1] 
      end
      self.road[i].clr = carclr -- car
      self.road[i].lic = genlic()
    else
      self.road[i].clr = 0 -- empty
      self.road[i].lic = ""
    end
    self.road[i].timer = rnd(curlevel.time)+curlevel.time
    self.road[i].driveawaytimer = 0
    self.road[i].dir = rnd(1)>.5
    self.road[i].spd = rnd(.10) + .10
    self.road[i].peepanimtimer = 0
    self.road[i].repo = false
  end

  -- gen target license
  self.targetlic = genlic()

  -- insert target
  self.targeti = flr(rnd(#self.road))
  self.road[self.targeti].clr = self.targetclr
  self.road[self.targeti].lic = self.targetlic
  self.road[self.targeti].timer = 30*level.getlevel().time/4
  self.road[self.targeti].spd = .25

  -- advanced levels, set 3 cars as same color
  if curlevel.multicolor then
    for i=0,2 do
      local rndi = flr(rnd(#self.road))
      while rndi == self.targeti or self.road[rndi].clr == 0 do
        rndi = flr(rnd(#self.road)) 
      end
      self.road[rndi].clr = self.targetclr
    end
  end
end
function stage.update(self)
  if level.levelchanging or
    ui.mode == 'dialogue' or
    ui.mode == 'encounter' then
    return
  end
  for i=0,#self.road do
    local car = self.road[i] 
    if car.timer > 0 then
      self.road[i].timer -= car.spd
    elseif car.timer <= 0 then
      car.driveawaytimer += 1
    end
    if i == self.targeti and car.timer == 0 and
      not level.getlevel().repo then
      self.settimeup(self)
    end
    self.road[i].peepanimtimer += car.spd 
  end
  if ui.mode == 'timeup' then
    self.timeuptimer += 1
    if self.timeuptimer >= 128 then
      ui.mode = 'jobdone'
      if self.timeuptimer == 128 then
        sfx(3,2)
        music(-1,750)
      end
    end
  end
end
function stage.draw(self)
  local y = 68
  -- sspr(104,0,2,32,0,8,127,32)
  -- sspr(108,0,2,32,0,33,127,32)
  -- rectfill(0,40,127,64,14)
  -- road
  rectfill(0,y,128,y+1,5)
  local shift = mod(self.pos,4)
  if shift == 0 then
    fillp(0b1100001111000011)
  elseif shift == 1 then
    fillp(0b0110100101101001)
  elseif shift == 2 then
    fillp(0b0011110000111100)
  elseif shift == 3 then
    fillp(0b1001011010010110)
  end
  rectfill(0,y+2,127,y+2,5)
  shift = mod(self.pos,2)
  if shift == 0 then
    fillp(0b1010010110100101)
  else
    fillp(0b0101101001011010)
  end
  rectfill(0,y+3,127,y+4,5)
  fillp()
  rectfill(0,y+5,128,128,0)
  -- cars
  local carw = 32
  for i=0,#self.road do
    local car = self.road[i]
    if car.clr > 0 then
      local carx = (i*(self.carw)) + 48
      if not car.repo and not (i == self.targeti and self.timeuptimer >= 128) then
        local engine =
          (i == self.targeti and self.timeuptimer > 48 and self.timeuptimer < 64 and mod(car.driveawaytimer,2) == 0)
          and 1 or 0
        self.drawcar(
          carx + self.pos,
          y-carw + engine,
          car.clr,
          i == self.targeti and animval(self.timeuptimer,64,128,1,0) or 1)
      end
      if car.timer then
        local dirflip = car.dir and 1 or -1
        if car.timer <= 0 and self.targeti == i then 
          self.drawpeepatcar(self,
            carx+self.pos,
            car.clr,
            not car.repo,
            car.repo or ui.mode == 'encounter',
            false,
            car.peepanimtimer
            )
        elseif car.timer > 0 then
          self.drawpeep(self,
            carx + (car.timer*10*dirflip)+ self.pos,
            car.clr,
            car.dir,
            car.spd,
            car.peepanimtimer)
        end
      end
    end
  end
end
function stage.drawpeep(self,x,clr,dir,spd,t)
  s = flr(mod(t,6))
  p = 128
  if s == 0 then p = 128 end
  if s == 1 then p = 130 end
  if s == 2 then p = 132 end
  if s == 3 then p = 134 end
  if s == 4 then p = 136 end
  if s == 5 then p = 138 end
  pal(13,clr)
  pal(4,12)
  spr(p,x,36,2,4,dir)
  pal()
end
function stage.drawpeepatcar(self,x,clr,isthere,isrepo,isgone,t)
  pal(13,clr)
  pal(4,12)
  p = 140
  if isgone then
    p = 140
    spr(p,x,36,2,4)
  elseif isrepo then
    local t = mod(t,4)
    local y = animval(t,0,.7,36,32) or
      animval(t,.7,1.4,32,36) or
      36
    p = 142
    spr(p,x,y,2,4)
  elseif self.timeuptimer <= 48 then
    p = 128
    spr(p,x,36,2,4)
  end
  pal()
end
function stage.getcntcar(self)
  local i = (-self.pos+(self.carw/2))/self.carw
  return flr(i)
end
function stage.getcaroffset(self)
  return mod(self.pos-(self.carw/2),self.carw)-(self.carw/2)
end

function stage.drawcar(x,y,clr,scale)
  local car = 3
  local carw = 4
  pal(13,clr)
  -- spr(car, x, y, carw, carw)
  local scalew = 32*(scale and scale or 1)
  sspr(16,0,32,32,x+(16-(scalew/2)),y+(32-scalew),scalew,scalew)
  pal()
end
function stage.drawrepo(self)
  local t = self.repotimer
  local xoff = self.getcaroffset(self)
  if (t==1) sfx(11,3)
  if (t==196) sfx(-2,3)
  local shipy = animval(t,0,48,0,10) or
    animval(t,48,204,10,10) or
    animval(t,204,240,10,-1)
    or -1
  rectfill(0,0,127,shipy+8,6)
  if t > 56 and t < 192 then
    if (t==57 or t==191) sfx(12,2)
    local doorh = animval(t,56,72,0,2)
      or 2
    rectfill(45+xoff,10+8,82+xoff,10+8-doorh,1)
  end
  if t > 68 and t < 192 then
    if (t==116) sfx(12,2)
    local clawy = animval(t,68,116,-12,39) or
      animval(t,116,132,39,39) or
      animval(t,132,180,39,-20)
      or -20
    -- spr(7,64-(3*8)+xoff,clawy,6,2)
    -- rectfill(62+xoff,0,65+xoff,clawy-2,6)
    self.drawclaw(self,64-(3*8)+xoff,clawy)
  end
  if t < 192 then
    local cary = animval(t,0,132,36,36) or
      animval(t,132,180,36,-23)
      or -23
    self.drawcar(48+xoff,cary,self.targetclr)
    rectfill(45+xoff,8,82+xoff,shipy-2+8,6)
  end
end
function stage.drawclaw(self,x,y)
  spr(7,x,y,6,2)
  rectfill(x+22,0,x+25,y-2,6) 
end
function stage.setcarrepo(self,i,setfalse)
  ui.repotimer = 0
  if setfalse then
    self.road[i].repo = false
    level.l[level.i].repo = false
  else
    self.road[i].repo = true
    level.l[level.i].repo = true
  end
end
function stage.settimeup(self)
  ui.mode = "timeup"
  self.timeuppos = self.pos
end

function stage.driveinput(self)
  if key[0].held then self.acc += 1 end
  if key[1].held then self.acc -= 1 end
end

function stage.drive(self)
  if not key[0].held and not key[1].held then
    if self.acc>0 then self.acc -= 1 
    elseif self.acc<0 then self.acc += 1 end
  end
  self.acc = max(min(self.acc,16),-16)
  local s = flr(cvtrng(abs(self.acc),0,16,8,16))
  if (abs(self.acc) > 0) sfx(14,-1,s,2)
  -- map bounds
  self.pos += self.acc
  local maxpos = (-self.carw*(#self.road))
  if self.pos>0 then
    self.pos = 0
    self.acc = 0
  elseif self.pos<maxpos then
    self.pos = maxpos
    self.acc = 0
  end
end

function stage.driveofshame(self)
  local t = self.timeuptimer
  local dest = -(self.targeti * self.carw)
  self.pos = flr(animval(t,0,64,self.timeuppos,dest)
    or dest)
  if (t==48) sfx(12,2)
  if (t==49) sfx(14)
end
function stage.gettimeleft(self)
  return flr(self.road[self.targeti].timer/30*4*10)/10
end
-->8
encounter={}
function encounter.init(self)
  self.current = {}
end

function encounter.gen(self)
  -- type: aggressive, sad, normal
  -- dialogue1: callout
  -- dialogue2: question
  -- response: options for player
  -- dialogue3: response to response
  local e = {
    type = self.gentype(self),
    d = {},
    res = {
      'repo their car',
      'let them go'
    },
    i = 0,
    resi = 1
  }
  e = self.gendialoguefortype(self,e,e.type)
  self.current = e

  music(1,1)
  sfx(-2,3)
  sfx(15,2)
end

function encounter.gentype(self)
  local t = {'normal','mad','sad'}
  local i = ceil(rnd(3))
  return t[i]
end

function encounter.gendialoguefortype(self,e,type)
  local d1 = {
    normal='excuse me... what are you doing?',
    mad='hey, what the hell?! get away from my car!',
    sad='oh no... oh no...'}
  local d2 = {
    normal="you're repossessing my car? please, i need to pick up my kids.",
    mad="repossessing my car? why don't you repossess my fist?!",
    sad="please! my mother is in the hospital and i need to pay those bills."
  }
  local d3 = {
    normal="give me a week and i swear i'll pay you back",
    mad="(they raise their fists and walk toward your car)",
    sad="can you pretend you didn't see me?"
  }
  local d3 = {
    normal={
      'you lowlife... hope you drive off a cliff...',
      'oh, that worked? thanks!'
    },
    mad={
      '(you eat a knuckle sandwich and pass out. their car is towed anyway)',
      '(they hop in their car and flip their middle finger at you...)'
    },
    sad={
      "no! please! noooooooo! (they fall to their knees...)",
      "thank you thank you thank you thank you thank you-"
    }
  }
  e.d[0] = d1[type]
  e.d[1] = d2[type]
  e.d[2] = d3[type]
  return e
    -- normal={
    --   'sorry, i have a family, too',
    --   '(ignore them)',
    --   "i'll be back next week"
    -- },
    -- mad={
    --   '(punch them first)',
    --   '(ignore them)',
    --   '(put your guard up)'
    -- },
    -- sad={
    --   "sorry, i need the money",
    --   "(ignore them)"
    --   "okay"
    -- }}
end

function encounter.update(self)
  -- keep animating person
  if stage.road[stage.targeti].timer > 0 then
    stage.road[stage.targeti].timer -= 1
  end
  stage.road[stage.targeti].peepanimtimer += stage.road[stage.targeti].spd 
  
  if self.current.i == 1 then
    if key[2].down then
      self.current.resi = 1
    elseif key[3].down then
      self.current.resi = 2
    end
  end
end

function encounter.draw(self)
  local t = self.current.d[self.current.i]
  if self.current.i == 2 then
    t = t[self.current.resi]
  end
  local sy = animflash(1) and 0 or 16
  dialogue.draw(dialogue,t,0,sy,16,16)
  if self.current.i == 1 then
    self.drawresponse(self)
  end
end

function encounter.drawresponse(self)
  local padx = 3
  local dashx = 0
  local dashh = 25
  local dashy = 127-dashh
  rectfill(dashx,dashy,127,127,1)
  local resh = 9
  -- rectfill(dashx+padx,dashy+padx,127-padx,dashy+padx+resh,15)
  pal(1,self.current.resi == 1 and 3 or 15)
  pal(6,self.current.resi == 1 and 7 or 15)
  spr(105,dashx+padx,dashy+padx,1,2)
  sspr(76,48,1,resh,dashx+padx+8,dashy+padx,127-padx-padx-15,resh)
  spr(105,127-padx-7,dashy+padx,1,2,true)
  pal()
  local r1 = self.current.res[1]
  local sxy = cntstr(r1,dashx+padx,dashy+padx,127-padx-padx,resh)
  print(r1,sxy[1],sxy[2],self.current.resi == 1 and 7 or 1)
  -- rectfill(dashx+padx,dashy+padx+resh+2,127-padx,127-padx,15)
  pal(1,self.current.resi == 2 and 3 or 15)
  pal(6,self.current.resi == 2 and 7 or 15)
  local b2y = dashy+padx+resh+2
  spr(105,dashx+padx,b2y,1,2)
  sspr(76,48,1,resh,dashx+padx+8,b2y,127-padx-padx-15,resh)
  spr(105,127-padx-7,b2y,1,2,true)
  pal()
  local r2 = self.current.res[2]
  local s2xy = cntstr(r2,dashx+padx,dashy+padx+resh+2,127-padx-padx,resh)
  print(r2,s2xy[1],s2xy[2],self.current.resi == 2 and 7 or 1)
  -- selection
  local sely = (self.current.resi == 1) and sxy[2] or s2xy[2]
  local bounce = cos(t())*1.5
  print(">",dashx+padx+padx+2+bounce,sely,7)
  print("<",127-padx-padx-4-bounce,sely,7)
end

function encounter.next(self)
  self.current.i += 1
  if self.current.i > #self.current.d then
    level.l[level.i].encounter = true
    if self.current.resi == 1 then
      ui.mode = "repo"
      if not level.getlevel().repo then
        stage.setcarrepo(stage,stage.getcntcar(stage))
      end
    else
      stage.setcarrepo(stage,stage.getcntcar(stage),true)
      stage.settimeup(stage)
    end
  end
end
-->8
key={}
function key.init(self)
  local base = {}
  base.down = false -- pulse on key down
  base.held = false -- is down
  base.up = false -- pulse on key up
  self[0] = shallowcopy(base)
  self[1] = shallowcopy(base)
  self[2] = shallowcopy(base)
  self[3] = shallowcopy(base)
  self[4] = shallowcopy(base)
  self[5] = shallowcopy(base)
end
function key.update(self)
  for i=0,#self do
    if btn(i) then
      -- if wasn't held and now is
      if not self[i].held then self[i].down = true
      else self[i].down = false end
      self[i].held = true
    else
      -- -- if was held and now its not
      if self[i].held then self[i].up = true
      else self[i].up = false end
      self[i].held = false
    end
  end
end

-->8
function mod(a,b)
  return a - flr(a/b)*b
end
function shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end
function cntstr(str,x,y,w,h,small)
  local charh = small and 4 or 5
  local newx = x+(w-(4*#str)-1)/2
  local newy = y+(h-charh)/2
  return {newx,newy}
end
function rndchar()
  local char="abcdefghijklmnopqrstuvwxyz"
  local i = ceil(rnd(26))
  return sub(char,i,i)
end
function rndnum()
  return flr(rnd(10))
end
function genlic()
  return rndchar()..rndchar()..'-'..rndnum()..rndnum()..rndnum()
end
function animval(t,tstart,tend,vstart,vend)
  if t >= tstart and t < tend then
    return cvtrng(t,tstart,tend,vstart,vend)
  end
end
function animflash(frames)
  return mod(t(),frames) < frames/2
end
function cvtrng(v,min1,max1,min2,max2)
  -- range to 0-1
  local progress = (v-min1)/(max1-min1)
  -- 0-1 to range
  return (progress*(max2-min2)) + min2
end
--https://pastebin.com/NS8rxMwH
--word wrap (string, char width)
function wwrap(s,width)
local w = flr(width/4)
 retstr = ""
 lines = strspl(s,"\n")
 for i=1,count(lines) do
  linelen=0
  words = strspl(lines[i]," ")
  for k=1, count(words) do
   wrd=words[k]
   if (linelen+#wrd>w)then
    retstr=retstr.."\n"
    linelen=0
   end
   retstr=retstr..wrd.." "
   linelen+=#wrd+1
  end
  retstr=retstr.."\n"
 end
 return retstr
end

--string split(string, seperator)
function strspl(s,sep)
 ret = {}
 bffr=""
 for i=1, #s do
  if (sub(s,i,i)==sep)then
   add(ret,bffr)
   bffr=""
  else
   bffr = bffr..sub(s,i,i)
  end
 end
 if (bffr!="") add(ret,bffr)
 return ret
end
__gfx__
00011111111000000000000000000000000000000000000000000000000000000000000000000066660000000000000000000000000000000000000000000000
00111111111100000000000000000000000000000000000000000000000000000000000000006766767600000000000000000000000000000000000000000000
01111111111110000000000000000000000000000000000000000000000000000000000000060006600060000000000000000000000000000000000000000000
01111111111111000000000000000000000000000000000000000000000000000000000000600066760006000000000000000000000000000000000000000000
01111111111111100000000000000000000000000000000000000000000000000000000006000006600000600000000000000000000000000000000000000000
01144444111111100000000000000000000000000000000000000000000000000000000060000076760000060000000000000000000000000000000000000000
01144444111111100000000000000000000000000000000000000000000000077666666666600760066007766666666660000000000000000000000000000000
01414441441411100000000000000000000000000000000000000000000000766666666666666607607666666666666666000000000000000000000000000000
00444444441411100000000000000000000000000000000000000000000000610000000000000606606000000000000016000000000000000000000000000000
00444444444411100000000000000000000000000000000000000000000000610000000000000000000000000000000016000000000000000000000000000000
00444444444111100000000000000000000000000000000000000000000000610000000000000000000000000000000016000000000000000000000000000000
00041114444111100000006dddddddddddddddd6d600000000000000000000610000000000000000000000000000000016000000000000000000000000000000
000444444411111000000611111111111111111111d0000000000000000006610000000000000000000000000000000016600000000000000000000000000000
0000144444111110000061111111111111111111111d000000000000000006610000000000000000000000000000000016600000000000000000000000000000
0000d44444dd1100110d111111111111111111111111d01100000000000007610000000000000000000000000000000016600000000000000000000000000000
000dddddddddd000111d111111111111111111111111d11100000000000000060000000000000000000000000000000060000000000000000000000000000000
00011111111000000066d6ddddddddddddddddddd6d6dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111111111000006ddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111111111000a88888dddddddddddddddddddd88888800000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111111111100988888dddddddddddddddddddd88888900000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111111111110199999dd1111111111111111dd99999100000000000000000000000000000000000000000000000000000000000000000000000000000000
0114444411111110d11111dd6666666666666666dd11111d00000000000000000000000000000000000000000000000000000000000000000000000000000000
0114444411111110dddddddd6070070700070707dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
0141444144141110dddddddd6777777777777777dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
0044444444141110dddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
0044444444441110ddddddddddddddddddddddddddddddd100000000000000000000000000000000000000000000000000000000000000000000000000000000
004411144441111001ddddddddddddddddddddddddddd11000000000000000000000000000000000000000000000000000000000000000000000000000000000
00041114444111100011111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044444441111100001111000000000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001444441111100005555000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d44444dd11000005555000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dddddddddd0000005555000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066666666666666666666666666666666666666000000000000000000000766076607660700700000000
00000000000000000000000000000000000000000006611111111111111111111111111111111111111660000000000000000000602060006060670600000000
00000000000000000000000000000000000000000061111111111111111111111111111111111111111116000000000000000000006060006760626600000000
00000000000000000000000000000000000000000061111111111111111111111111111111111111111116000000000000000000666066706060600600000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000000000000000000000000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000000000000000000000000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000000000000000000000000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000766076607660766600000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000626067006260620600000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000660060006660600600000000
00000000000000000000000000000000000000000611111111111111111111111111111111111111111111600000000000000000606066606000666700000000
00000000000000666600000000000000000000000061111111111111111111111111111111111111111116000000000000000000000000000000000000000000
00000000000006888860000000000000000000000061111111111111111111111111111111111111111116000000000000000000000000000000000000000000
00666666666666666666666666666600000000000006611111111111111111111111111111111111111660000000000000000000000000000000000000000000
06666666666666666666666666666660000000000000066666666666666666666666666666666666666000000000000000000000000000000000000000000000
66611111111111111111111111111666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66111111111111111111111111111166000000000000000000000000000000000000000000666666000000000000000000000000000000000000000000000000
66111111111111111111111111111166000000000b0000b00b0000b00b0000b00b0000b0061111110000000000000006000000000000000b0000000000000000
6611111111111111111111111111116600000000000000000000000000000b000000000061111111000000000000000600000000000000000000000000000000
66111111111111111111111111111166000000000000000000000000000000b0000000006111111100000000000000060000000000000bbbbb00000000000000
66111111111111111111111111111166000000000000000000bbbb000000000000000000611111110000000000000660660000000000b00b00b0000000000000
66111111111111111111111111111166000000000b0000b00b0000b00b0000b000bbbb0061111111000000000000666666600000000b000b000b000000000000
661111111111111111111111111111660000000000bbbb0000bbbb0000bbbb000b0000b061111111000000000006600000660000000b0000000b000000000000
661111111111111111111111111111660000000000000000000000000000000000000000061111110000000000060000000600000b0bbb0b0bbb0b0000000000
666111111111111111111111111116661111000007aa000007170000000000000000000000666666000000000066000000066000000b0000000b000000000000
0666666666666666666666666666666011000000799a900077177000000000000000000000000000000000000006000000060000000b000b000b000000000000
0066666666666666666666666666660010000000a9aa9000771170000000000000000000000000000000000000060000000600000000b00b00b0000000000000
0000000011111111111111110000000010000000aaa790007777700000000000000000000000000000000000000660000066000000000bbbbb00000000000000
00000000666666666666666600000000000000000999000007770000000000000000000000000000000000000000000000000000000000000000000000000000
000111111666661111666661111110000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000000000000
01111111111111166111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000004011400000000
000001100000000000001111000000000000011000000000000001100000000000001111000000000000011000000000000001100000000000d01111d0000000
00001111000000000001111100000000000011110000000000001111000000000001111100000000000011110000000000001114000000000d011111dd000000
00011111000000000001114410000000000111110000000000011111000000000001114410000000000111110000000000011111d00000000d0111441d000000
000111441000000000001144000000000001114410000000000111441000000000001144000000000001114410000000000111441d000000dd0011440dd00000
000011440000000000001440000000000000114400000000000011440000000000001440000000000000114400000000000011440dd00000dd0014480d000000
000014400000000000001ddd000000000000144000000000000014400000000000001ddd00000000000014400000000000001440dd0000000dd01ddddd000000
00001ddd0000000000000ddd0000000000001ddd0000000000001ddd0000000000000ddd0000000000001ddd0000000000001ddddd00000000ddddddd0000000
0000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000000ddddd0000000000ddddd00000000
0000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd00000000000ddddd000000000000dddd00000000
0000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd0000000000dddddd000000000000dddd00000000
000ddddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd000000000dd0dddd000000000000dddd00000000
000ddddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd00000000000ddddd000000000dd0dddd000000000000dddd00000000
000d0ddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd00000000000ddddd0000000000dddddd000000000000dddd00000000
000d0ddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd00000000000ddddd00000000000ddddd000000000000dddd00000000
000d0ddd000000000000dddd000000000000dddd000000000000dddd000000000000dddd00000000000ddddd0000000000004ddd000000000000dddd00000000
000d0ddd0000000000001d110000000000000ddd0000000000000ddd0000000000001d11000000000000dddd0000000000000ddd0000000000000ddd00000000
000d11110000000000001141000000000000111d000000000000111d0000000000001141000000000000d1110000000000001111000000000000111100000000
00041111000000000000111100000000000011140000000000001111400000000000111100000000000041110000000000001111000000000000111100000000
00001111000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000
00001111000000000000011100000000000011110000000000001111000000000000011100000000000011110000000000001111000000000000111100000000
00000111000000000000011100000000000001110000000000000111000000000000011100000000000001110000000000000111000000000000011100000000
00000111000000000000011100000000000001110000000000000111000000000000011100000000000001110000000000000111000000000000011100000000
00000111000000000000011100000000000001110000000000000111000000000000011100000000000001110000000000000111000000000000011100000000
00001111000000000000111100000000000001110000000000001111000000000000111100000000000001110000000000001111000000000000111100000000
00001111000000000000111100000000000001110000000000001111000000000000111100000000000001110000000000001111000000000000111100000000
00001101000000000000111000000000000001110000000000001101000000000000111000000000000001110000000000001101000000000000110100000000
00001001000000000000101000000000000001110000000000001001000000000000101000000000000001110000000000001001000000000000100100000000
00001001000000000000101000000000000001110000000000001001000000000000101000000000000001110000000000001001000000000000100100000000
00001001000000000000501000000000000001010000000000001001000000000000501000000000000001010000000000001001000000000000100100000000
00001001000000000000501000000000000001055000000000001001000000000000501000000000000001055000000000001001000000000000100100000000
00005505500000000000005500000000000005500000000000005505500000000000005500000000000005500000000000005505500000000000550550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077707707007770770007700000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007ccc7cc7c77ccc7cc707cc70000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007cc7cccccc7c77c77cc7cc700000000000000000
00007777777777777777700000007777777777770007777777777777777700000077777777777777700000000777c7c7cc7c77c77cccc7000000000000000000
0007888888888888888887000007888888888888707888888888888888887000078888888888888887000000007cc7c7c77cccc7cc7cc7000000000000000000
0078888888888888888888700078888888888888878888888888888888888700788888888888888888700000077c7777c7cc77c7c707c7000000000000000000
00078888888888888888888707888888888888887078888888888888888888778888888888888888888700007ccc707cc7c707c7c707c7000000000000000000
000077888777777777788887078887777777777700077888777777777788887788887777777777788887000007770007777007c7700070000000000000000000
00000788870000000007888707888700000000000000788870000000077888778887000000000007888700000000000000000070000000000000000000000000
00000788870000000007888707888700000000000000788870000000007888778887000000000007888700000000000000000000000000000000000000000000
00000788870000000007888707888700000000000000788870000000007888778887000000000007888700000000000000000000000000000000000000000000
00000788870000000007888707888700000000000000788870000000007888778887000000000007888700000000000000000000000000000000000000000000
00000788870000000007888707888700000000000000788870000000077888778887000000000007888700000000000000000000000000000000000000000000
00000788877777777778888707888777777777700000788877777777778888778887000000000007888700000000000000000000000000000000000000000000
00007888888888888888888707888888888888870007888888888888888888778887000000000007888700000000000000000000000000000000000000000000
00078888888888888888887000788888888888887078888888888888888887078887000000000007888700000000000000000000000000000000000000000000
00007888888888888888770007888888888888870007888888888888888877078887000000000007888700000077777707777777077777077777777777700000
000007888777777778888700078887777777777000007888777777777777700788870000000000078887000077cccccc7c77c7c777ccc777cc7cccccccc70000
00000788870000000788887007888700000000000000788870000000000000078887000000000007888700007cc7c77c7c77c7cc77c7cc77c7cc777c77c70000
00000788870000000078888707888700000000000000788870000000000000078887000000000007888700007777c77c7c77c7cc77c7cc77c7c7777c77c70000
0000078887000000007888870788870000000000000078887000000000000007888700000000000788870000007cccc7c77c77c7ccc7c7ccc7ccc7cccc700000
0000078887000000007788870788870000000000000078887000000000000007888700000000000788870000007c77c7c77c7c77cc7c77cc7cc777c77c700000
000007888700000000078887078887000000000000007888700000000000000788870000000000078887000077cc77c7c77c7c777c7c777c7c777cc77c777000
00000788870000000007888707888700000000000000788870000000000000078887000000000077888700007cc777cc7ccccc777c7c777c7ccccc777ccc7700
00000788870000000007888707888877777777770000788870000000000000078888777777777778888700007777007777777770770770777777777077777000
00000788870000000007888877888888888888887000788870000000000000078888888888888888888700000000000000000000000000000000000000000000
00000788870000000007888887788888888888888700788870000000000000007888888888888888887000000000000000000000000000000000000000000000
00000078700000000000788870078888888888887000078700000000000000000788888888888888870000000000000000000000000000000000000000000000
00000007000000000000077700007777777777770000007000000000000000000077777777777777700000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
e3e3e3e3e3e3e3e30000e3e3e3e3e3e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e3e3e3e3e3e3e30000000000e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c002004073040033f7053f70504655040733f20500000040733f705040033f705046553f7053f7053f705040733f205040733f2050465504073040733f70504073040730407304073046553f7050460504053
010c00000e0521305211052150521305218052150521a0521a0521a0001a0521a0001d05221052240520000026052260522605226052240522405226052260522604226042260322603226022260222601226015
010c00001a0521505218052130521505211052130520e0520e0521a0000e0521a0000e0520e0520e0520e05202051020420203202025020020200202002020022600226002260022600226002260022600226005
010c00000204009020050100c0440202005010090400c0240201009040050200c0140204005020090100c0140704007010110400e0100c046090360c0260e01604046070260b0160c04604026070160b0460c016
010c00200e0401502011010180440e0201101015040180240e0101504011020180140e04011020150101801413040130101d0401a0101804615036180261a0161004613026170161804610026130161704618016
010c00001a0401d0201f0102104024020210101f0401d0201a0101d0401f0202101024040210101f0401d0101a0401d0201f010210401800021040130001d0201a0101d0401f0202101024040210101f0401d010
010c00200e0401302011010150401302018010150401a0200e0101304011020150101304018010150401a0100e0401302011010150401302018010150401a0200e0101304011020150101304018010150401a010
010c0000260202d03500000000002602029035000002d025260202d035000000000021020000001f0350000026020210350000024035260201f035000002d03526020290352b020290352d020290350000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000240161a016240161a016240161a016240161a016240161a016240161a0162400026000240002600024000260002400026000000000000000000000000000000000000000000000000000000000000000
0108000800734007340073400734007340073400734007340c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c6350c635000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002476518765307052470500503006030070300103002030030300403005030060300703001030020300303004030050300603007030010300203003030040300503006030070300103002030030300403
0107000000074000740007400074000740007400074000740007402074040740507407074090740b0740c0740c0740c0740c0740c0640c0640c0540b054090440704405044040440204400034000340003400034
011000001a1431a1421a1421a1421a1421a1450c6050c605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002455030550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c25500255005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
03 01 42 43 44
00 01 04 43 44
00 01 04 05 44
01 01 04 07 08
02 01 04 06 07
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
