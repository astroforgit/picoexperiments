pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function clamp(v, low, hi)
    return max(low, min(hi, v))
end

function frac(v)
    return v - flr(v)
end

function randInt(low, hi)
    return flr(rnd(hi + 1 - low) + low)
end

function randFloat(low, hi)
    return rnd(hi - low) + low
end

function absorbTable(dest, source)
    for k,v in pairs(source) do
        dest[k] = v
    end
end


vec2mt = {
    __add = function(v1,v2)
        return vec2(v1.x + v2.x, v1.y + v2.y)
    end,
    __sub = function(v1,v2)
        return vec2(v1.x - v2.x, v1.y - v2.y)
    end,
    __unm = function(self)
        return vec2(-self.x, -self.y)
    end,
    __mul = function(s,v)
        return vec2(s * v.x, s * v.y)
    end,
    __len = function(self)
        return sqrt(self.x * self.x + self.y * self.y)
    end,
    __eq = function(v1,v2)
        return v1.x == v2.x and v1.y == v2.y
    end,
    __tostring = function(v)
        return "(" .. v.x .. "," .. v.y .. ")"
    end,
    dot = function(v1,v2)
        return v1.x * v2.x + v1.y * v2.y
    end,
    alignment = function(v1,v2)
        return v1:dot(v2) / (#v1 * #v2)
    end,
    normalize = function(v)
        len = #v
        if (len == 0) return
        v.x /= len
        v.y /= len
    end,
    clamp = function(v, low, hi)
        v.x = clamp(v.x, low, hi)
        v.y = clamp(v.y, low, hi)
    end
}
vec2mt.__index = vec2mt

function vec2(x,y)
    return setmetatable({x = x, y = y},vec2mt)
end


rectanglemt = {
    __add = function(r,v)
        return rectangle(r.min + v, r.max + v)
    end,
    width = function(r)
        return r.max.x - r.min.x
    end,
    height = function(r)
        return r.max.y - r.min.y
    end,
    overlaps = function(r1, r2)
        return (r1.max.x >= r2.min.x and
            r1.min.x <= r2.max.x and
            r1.max.y >= r2.min.y and
            r1.min.y <= r2.max.y)
    end,
    __tostring = function(r)
        return "[" .. tostring(r.min) .. " | " .. tostring(r.max) .. "]"
    end,
}
rectanglemt.__index = rectanglemt

function rectangle(min, max)
    return setmetatable({min = min, max = max}, rectanglemt)
end



function tileWorldToScreen(v)
    return vec2(flr(v.x * 8 - 4), flr(v.y * 8 - 4))
end

function drawSprite(n, v)
    palt(0)
    flipX = n < 0
    n = abs(n)
    flipY = n > 256
    if (flipY) n -= 256
    palt(fget(n), true)
    screenPos = tileWorldToScreen(v)
    spr(n, screenPos.x, screenPos.y, 1, 1, flipX, flipY)
end

function startAnim(anim,frameTime,dontLoop)
    animData = {
        t = 0,
        frameTime = frameTime,
        anim = anim,
        dontLoop = dontLoop,
        numFrames = #anim
    }

    if (animData.anim.right != nil) animData.numFrames = #anim.right
    return animData
end

function pauseAnimAtStart(animData)
    animData.t = 0
    animData.frameTime = -1
end

function updateAnim(animData)
    if (animData.frameTime < 0) return
    animData.t += 1
    if animData.t / animData.frameTime >= animData.numFrames then
        if animData.dontLoop then
            animData.t = -(animData.numFrames - 1)
            animData.frameTime = -1
        else
            animData.t = 0
        end
    end
end

angleLookups =
{
    {
        key="right"
    },
    {
        key="diag"
    },
    {
        key="up"
    },
    {
        key="diag",
        flipX=true
    },
    {
        key="right",
        flipX=true
    },
    {
        key="diag",
        flipX=true,
        flipY=true
    },
    {
        key="up",
        flipY=true
    },
    {
        key="diag",
        flipY=true
    },
}
function drawAnim(animData, pos, dir)
    frame = 1 + flr(animData.t / animData.frameTime)
    frames = animData.anim
    if animData.anim.right != nil then
        angle = atan2(dir.x, dir.y)
        if animData.anim.diag != nil then
            angleLookupIndex = 1 + flr(frac(angle + 0.0625 + 0.001) * 8)
        else
            angleLookupIndex = 1 + 2 * flr(frac(angle + 0.125 + 0.001) * 4)
        end
        lookupResult = angleLookups[angleLookupIndex]
        sprite = animData.anim[lookupResult.key][frame]
        
        if (lookupResult.flipY) sprite += 256 * sgn(sprite)
        if (lookupResult.flipX) sprite *= -1
    else
        sprite = animData.anim[frame]
    end
    drawSprite(sprite,pos)
end


function updateGameObjects(table)
    for gameObject in all(table) do
        gameObject:update()
    end
end

function drawGameObject(gameObject)
    drawAnim(gameObject.anim, gameObject.pos)
end

function drawGameObjects(table)
    foreach(table, drawGameObject)
end

function moveTowards(gameObject, target)
    offsetToTarget = target - gameObject.pos
    distToTarget = #offsetToTarget
    speed = gameObject.speed
    if (gameObject.speedMult != nil) speed *= gameObject.speedMult
    if distToTarget < speed then
        gameObject.pos = target
        gameObject.vel = offsetToTarget
        return true
    else
        gameObject.vel = (speed / distToTarget) * offsetToTarget
        gameObject.pos += gameObject.vel
        return false
    end
end


function initEffects()
    effects = {}
end

function effectDataCircle(center, radius, color)
    return {
        center=center,
        radius=radius,
        color=color,
        draw=drawEffectCircle
    }
end

function effectDataLightning(color, segments)
    return {
        color=color,
        segments=segments,
        draw=drawEffectLightning
    }
end

function effectDataPixelSpray(pos, color, dir, coneAngle, speedMin, speedMax, emissionRate, particleLife)
    return {
        pos=pos,
        color=color,
        angle=atan2(dir.x, dir.y),
        halfAngle=coneAngle / 2,
        speedMin=speedMin,
        speedMax=speedMax,
        emissionRate=emissionRate,
        emissionCounter=rnd(1),
        particleLife=particleLife,
        update=updateEffectPixelSpray
    }
end

function effectDataParticle(pos, color, vel)
    return {
        color=color,
        pos=pos + rnd(1) * vel,
        vel=vel,
        update=updateParticle,
        draw=drawParticle
    }
end

function createEffect(lifetime, data, attachObject)
    newEffect = {}
    newEffect.lifetime = lifetime
    newEffect.update = updateEffect
    newEffect.data = data
    newEffect.attachObject = attachObject
    add(effects, newEffect)
    return newEffect
end

function updateEffect(effect)
    effect.lifetime -= 1
    if effect.lifetime == 0 or (effect.attachObject and effect.attachObject.dead) then
        del(effects, effect)
    elseif effect.data.update then
        effect.data.update(effect)
    end
end

function updateEffectPixelSpray(effect)
    data = effect.data

    if (effect.attachObject) data.pos = effect.attachObject.pos

    data.emissionCounter += data.emissionRate
    while (data.emissionCounter > 1) do
        data.emissionCounter -= 1
        angle = data.angle + randFloat(-data.halfAngle, data.halfAngle)
        vel = randFloat(data.speedMin, data.speedMax) * vec2(cos(angle), sin(angle))

        col = data.color
        if (type(col)!="number") col = rnd(col)

        particle = createEffect(data.particleLife, effectDataParticle(data.pos, col, vel))
        particle.drawLayer = effect.drawLayer
    end
end

function drawEffectCircle(effect)
    circ(effect.data.center.x * 8, effect.data.center.y * 8, effect.data.radius * 8, effect.data.color)
end

function drawEffectLightning(effect)
    color(effect.data.color)
    v1 = 8 * effect.data.segments[1]
    v2 = 8 * effect.data.segments[2]
    line(v1.x, v1.y, v2.x, v2.y)
    for i=3,#effect.data.segments do
        v = 8 * effect.data.segments[i]
        line(v.x, v.y)
    end
end

function updateParticle(effect)
    effect.data.pos += effect.data.vel
end

function drawParticle(effect)
    pset(effect.data.pos.x*8, effect.data.pos.y*8, effect.data.color)
end

function drawEffect(effect)
    if (currentEffectDrawLayer == effect.drawLayer and effect.data.draw) effect.data.draw(effect)
end

function drawEffects()
    foreach(effects, drawEffect)
    foreach(particles, drawParticle)
end


function dump(any, depth)
    local thisDepth = depth or 0
    local indent = ""
    for i=1,thisDepth do indent = indent .. " " end
    if type(any)=="function" then 
        return "function" 
    end
    if any==nil then 
        return "nil" 
    end
    if type(any)=="string" then
        return any
    end
    if type(any)=="boolean" then
        if any then return "true" end
        return "false"
    end
    if type(any)=="table" then
        local str = "\n" .. indent .. "{"
        for k,v in pairs(any) do
            str=str.."\n"..indent.." "..dump(k, thisDepth + 1).." : "..dump(v, thisDepth + 1)
        end
        return str.."\n" .. indent .. "}"
    end
    if type(any)=="number" then
        return ""..any
    end
    return any:__tostring()
end

function drawDebugStats()
    print(flr(100 * stat(0) / 2048) .. "% mem", 1, 1, 0)
    print(flr(100 * stat(1)) .. "% cpu", 1, 6, 0)
    print(stat(7) .. " fps", 1, 11, 0)
end


function showCredits()
    _update60 = updateCredits
    _draw = drawCredits
end

function updateCredits()
    if (btnp(4) or btnp(5)) sfx(29) showTitleScreen()
end

function drawCredits()
    cls()
    drawHudRect(rectangle(vec2(0, 2), vec2(127, 127)))
    drawTitle(24,0)

    color(7)

    print("a GAME BY",46,19)
    print("bILL cLARK",44,26)

    print("bUILT wITH",44,37)
    print("pICO-8",52,44)
    print("aSEPRITE",48,51)

    print("tHANK yOU",44,62)
    print("sARAH, jONATHAN, AND rYAN",14,69)

    credits =
        "tHANKS FOR PLAYING!\n" ..
        "tELL ME WHAT YOU THINK.\n" ..
        "\n" ..
        "@lt_randolph\n" ..
        "ltrandolph games ON yOUtUBE\n" ..
        "DISCORD.GG/ezgfcd5\n"

    print(credits,8,85)
end


enemySquidAnim = {
    up={38,39,40,-38,-39,-40},
    right={41,42,43,41+256,42+256,43+256}
}

enemyTurtleAnim = {
    up={54,54,55,55,56,56,57,54,54,54,54},
    right={58,58,59,59,60,60,61,58,58,58,58},
}

enemyBasic = {
    anim = enemySquidAnim,
    animSpeed = 8,
    speed = 0.025,
    health = 20,
    deathFXColor = 3
}
enemyTough = {
    anim = enemySquidAnim,
    animSpeed = 8,
    speed = 0.02,
    health = 50,
    paletteSwaps = {[3]=1},
    deathFXColor = 1
}

enemyHeavy = {
    anim = enemyTurtleAnim,
    animSpeed = 8,
    speed = 0.01,
    health = 150,
    deathFXColor = 13
}

enemyBoss = {
    anim = enemyTurtleAnim,
    animSpeed = 12,
    speed = 0.005,
    health = 500,
    lives = 2,
    paletteSwaps = {[13]=0,[6]=8,[5]=1},
    deathFXColor = 0
}

lastLaneSpawn = 1

function createEnemy(enemyDef)
    local newEnemy = {}
    newEnemy.waypointIndex = 0
    newEnemy.pathIndex = 0
    chooseNextWaypoint(newEnemy)
    newEnemy.pos = newEnemy.waypoint
    newEnemy.vel = vec2(1, 0)
    newEnemy.speed = enemyDef.speed * levelEnemySpeedMultiplier
    newEnemy.anim = startAnim(enemyDef.anim, ceil(enemyDef.animSpeed / levelEnemySpeedMultiplier))
    newEnemy.update = updateEnemy
    newEnemy.health = flr(enemyDef.health * levelEnemyHealthMultiplier)
    newEnemy.maxHealth = newEnemy.health
    newEnemy.stunTicks = 0
    newEnemy.dotTicks = 0
    newEnemy.speedMultTicks = 0
    newEnemy.paletteSwaps = enemyDef.paletteSwaps
    newEnemy.deathFXColor = enemyDef.deathFXColor
    newEnemy.lives = enemyDef.lives or 1
    chooseNextWaypoint(newEnemy)
    add(enemies, newEnemy)
end

function chooseNextWaypoint(enemy)
    enemy.waypointIndex += 1
    if enemy.waypointIndex > #mapWaypoints then
        del(enemies, enemy)
        lives = max(0, lives - enemy.lives)
        sfx(41, 3)
        if (lives == 0) showEndDisplay(false)
        return
    end

    waypointList = mapWaypoints[enemy.waypointIndex]

    if waypointList[1].x == nil then
        if enemy.waypointIndex == 1 then
            lastLaneSpawn = (lastLaneSpawn % 2) + 1
            enemy.pathIndex = lastLaneSpawn
        else
            if (enemy.pathIndex == 0) enemy.pathIndex = randInt(1, 2)
        end
        waypointList = waypointList[enemy.pathIndex]
    else
        enemy.pathIndex = 0
    end
    
    enemy.waypoint = rnd(waypointList)
end

function dealEnemyDamage(enemy, amount, suppressSFX)
    enemy.health -= amount
    if enemy.health <= 0 then
        onEnemyDeath(enemy)
        sfx(36,3)
    elseif not suppressSFX then
        sfx(35)
    end
end

function updateEnemy(enemy)
    if enemy.speedMultTicks > 0 then
        enemy.speedMultTicks -= 1
        if (enemy.speedMultTicks == 0) enemy.speedMult = 1
    end

    if enemy.dotTicks > 0 then
        enemy.dotTicks -= 1
        if enemy.dotTicks == 0 then
            enemy.dotRemaining -= 1
            dealEnemyDamage(enemy, 1, true)
            if (enemy.dotRemaining > 0) enemy.dotTicks = enemy.dotInterval
        end
    end

    if enemy.stunTicks > 0 then
        enemy.stunTicks -= 1
        return
    end

    arrived = moveTowards(enemy, enemy.waypoint)
    if (arrived) chooseNextWaypoint(enemy)
    updateAnim(enemy.anim)
end

timerToSpawn = 0
delayWaveBy = 0
function updateEnemies()
    if delayWaveBy > 0 then
        if (#enemies == 0 and waveSpawnCount == 0) timerToSpawn = delayWaveBy
        delayWaveBy = 0
    end
    if timerToSpawn == 0 then
        createEnemy(currentWave.enemy)
        waveSpawnCount += 1
        if waveSpawnCount == currentWave.spawnCount then
            beginNextWave()
        else
            timerToSpawn = currentWave.spawnDelay
        end
    elseif (waveSpawnCount > 0 or (slottedTowerCount > 0 and #enemies == 0)) then
        timerToSpawn -= 1
    end

    updateGameObjects(enemies)
    
    if timerToSpawn < 0 and #enemies == 0 and lives > 0 then
        showEndDisplay(true)
    end
end

function drawEnemy(enemy)
    if (enemy.paletteSwaps != nil) pal(enemy.paletteSwaps)

    drawAnim(enemy.anim, enemy.pos, enemy.vel)
    pal()
end

function drawEnemyHealthBar(enemy)
    if enemy.health < enemy.maxHealth then
        topCorner = tileWorldToScreen(enemy.pos)
        rectfill(topCorner.x, topCorner.y - 2, topCorner.x + 7, topCorner.y - 2, 0)
        rectfill(topCorner.x, topCorner.y - 2, topCorner.x + 7 * (enemy.health / enemy.maxHealth), topCorner.y - 2, 11)
    end
end

function drawEnemies()
    foreach(enemies, drawEnemy)
    foreach(enemies, drawEnemyHealthBar)
end

currentWaves = nil
currentWaveIndex = 0
currentWave = nil
waveSpawnCount = 0
function beginEnemyWaves(waves)
    currentWaves = waves
    currentWaveIndex = 1
    beginEnemyWave(currentWaves[currentWaveIndex])
end

function beginEnemyWave(wave)
    currentWave = wave
    timerToSpawn = wave.delay
    waveSpawnCount = 0
end

function beginNextWave()
    if currentWaveIndex == #currentWaves then
        timerToSpawn = -1
    else
        currentWaveIndex += 1
        beginEnemyWave(currentWaves[currentWaveIndex])
    end
end

function onEnemyDeath(enemy)
    del(enemies, enemy)
    enemy.dead = true
    killsTowardsItem += 1
    if killsTowardsItem >= killsPerItem then
        killsTowardsItem -= killsPerItem
        addItemToInventory()
        inventoryPlayEffectOnNewItem()
    end
    createEffect(4, effectDataPixelSpray(enemy.pos, enemy.deathFXColor, vec2(1, 0), 1, 0.05, 0.12, 8.5, 10))
end


endDisplayVictory = nil

function showEndDisplay(won)
    endDisplayVictory = won
    _update60 = updateEndDisplay

    for i=0,2 do sfx(-1) end
    music(-1, 100)
    if won then
        sfx(30)

        wasntFinished = beatenLevels != 126
        beatenLevels |= 1 << previousLevelNum
        nowFinished = beatenLevels == 126
        justFinished = (wasntFinished and nowFinished)

        dset(0, beatenLevels)
    end
    if (not won) sfx(31)
end

function updateEndDisplay()
    updateLivesDisplay()

    if btnp(4) or btnp(5) then
        if justFinished then
            showCredits()
            justFinished = false
        else
            showLevelSelect()
        end
        endDisplayVictory = nil
    end
end

function drawEndDisplay()
    if (endDisplayVictory == nil) return
    palt(0b0000000000000010)
    x = flr((gameWidth - 56) / 2)
    y = flr((128 - 16) / 2)

    sprite = 199
    if (endDisplayVictory) sprite = 192
    for row=1,2 do
        for col=1,7 do
            spr(sprite, x, y)
            x += 8
            sprite += 1
        end
        x -= 56
        y += 8
        sprite += 9
    end
end


gamePaused = false

maxLives = 5
lives = maxLives

function _init()
    showTitleScreen()
    cartdata("ltrandolph_crafdefense")
    beatenLevels = dget(0)
    
    menuitem(3, "reset progress", resetProgress)
end

function beginGame(level)
    beginLevel(level)
    music(1, 0, 3)

    _update60 = updateDefault
    _draw = drawDefault
    addGameMenuItems()
end

function addGameMenuItems()
    menuitem(1, "restart level", restartLevel)
    menuitem(2, "main menu", showTitleScreen)
end

function removeGameMenuItems()
    menuitem(1)
    menuitem(2)
end

function resetProgress()
    backupBeatenLevels = beatenLevels
    beatenLevels = 0
    dset(0, beatenLevels)
    menuitem(3, "undo reset", restoreProgress)
end

function restoreProgress()
    beatenLevels = backupBeatenLevels
    dset(0, beatenLevels)
    menuitem(3, "reset progress", resetProgress)
end

function updateDefault()
    if not gamePaused then
        updateEnemies()
        updateGameObjects(towers)
        updateGameObjects(projectiles)
        updateGameObjects(lingeringProjectiles)
        updateGameObjects(effects)
    end
    updateHud()
end

function drawDefault()
    cls()
    clip(1, 1, gameWidth, 126)
    camera(-1,1)
    drawMap()
    
    drawTowers()
    drawEnemies()
    drawProjectiles()
    drawLingeringProjectiles()
    palt()
    drawEffects()
    drawGameSpaceHud()

    clip()
    camera()
    drawHud()

    drawEndDisplay()
end


hudWidth = 15
gameWidth = 128 - hudWidth

hudModeDefault = 0
hudModeTowerBuild = 1
hudModeInventorySelect = 2

sideHudRect = rectangle(vec2(gameWidth, 0), vec2(127, 127))
heartHudRect = rectangle(vec2(125 - maxLives * 10, 0), vec2(127, 12))

heartAnim = {1,2,3,4,5}
heartAnims = {}

function getSelectedVerticalList(current, maxVal, allowZero, preventLoop)
    was = current
    if (not preventLoop) current += maxVal
    
    if (btnp(3)) current += 1
    if (btnp(2)) current -= 1

    if preventLoop then
        current = min(maxVal, current)
        if allowZero then
            current = max(0, current)
        else
            current = max(1, current)
        end
    else
        if allowZero then
            current = (current + 1) % (maxVal + 1)
        else
            current = (current - 1) % maxVal + 1
        end
    end

    if (was != current) sfx(27)

    return current
end

function initHud()
    hudMode = hudModeDefault
    for i=1,maxLives do
        heartAnims[i] = startAnim(heartAnim, -1)
    end
end

function updateHud()
    if hudMode == hudModeDefault then
        updateSelection()
    elseif hudMode == hudModeTowerBuild then
        updateTowerBuild()
    elseif hudMode == hudModeInventorySelect then
        updateInventorySelect()
    end
    updateLivesDisplay()
end

lastHudLives = maxLives
function updateLivesDisplay()
    if lives < lastHudLives then
        for i=lives+1,lastHudLives do
            heartAnims[i] = startAnim(heartAnim, 2, true)
        end
    elseif lives > lastHudLives then
        for i=lastHudLives+1,lives do
            heartAnims[i] = startAnim(heartAnim, -1)
        end
    end
    lastHudLives = lives
    for heart in all(heartAnims) do
        updateAnim(heart)
    end
end

function drawGameSpaceHud()
    drawSelection()
end

function drawHudRect(hudRect)
    rectfill(hudRect.min.x, hudRect.min.y, hudRect.max.x, hudRect.max.y, 1)
    rect(hudRect.min.x + 1, hudRect.min.y + 1, hudRect.max.x - 1, hudRect.max.y - 1, 6)
    rect(hudRect.min.x, hudRect.min.y, hudRect.max.x, hudRect.max.y, 0)
end

function drawSelectionBox(location, active, small)
    sprite = 9
    if (active) sprite = 10
    if (small) sprite -= 2
    spr(sprite, location.x, location.y)
end

inventoryPositions = {}
function drawHud()
    drawHudRect(sideHudRect)

    x = sideHudRect.min.x + 4
    y = heartHudRect.max.y + 3
    for i = 1,10 do
        rectfill(x, y, x + 6, y + 6, 0)
        if (i <= #inventory) spr(inventory[i].sprite, x, y)
        if (i == inventorySelectIndex) spr(8, x, y)
        inventoryPositions[i] = vec2(x, y)
        y += 10
    end
    
    if inventorySelectIndex >= 0 then
        rectfill(x, y, x + 6, y + 6, 0)
        spr(6, x, y)
        if (0 == inventorySelectIndex) spr(8, x, y)
    end

    drawHudRect(heartHudRect)
    x = heartHudRect.min.x + 7
    y = heartHudRect.min.y + 7
    for i=1,maxLives do
        drawAnim(heartAnims[i], vec2(x / 8, y / 8))
        x += 10
    end
    
    if (hudMode == hudModeTowerBuild or hudMode == hudModeInventorySelect) drawTowerBuild()

    currentEffectDrawLayer = "hud"
    drawEffects()
    currentEffectDrawLayer = nil
end

function inventoryPlayEffectOnNewItem()
    pos = inventoryPositions[#inventory]
    hudEffect = createEffect(14, effectDataPixelSpray(0.125 * (pos + vec2(4, 4)), 7, vec2(1, 0), 1, 0.04, 0.1, 8.5, 10))
    hudEffect.drawLayer = "hud"
end


function showInstructions()
    _update60 = updateInstructions
    _draw = drawInstructions
end

function updateInstructions()
    if (btnp(4) or btnp(5)) sfx(29) showTitleScreen()
end

function drawInstructions()
    cls()
    drawHudRect(rectangle(vec2(0, 2), vec2(127, 127)))
    drawTitle(24,0)

    color(7)

    instructions = "wELCOME TO cRAFdEFENSE!\n" ..
        "\n" ..
        "yOU MUST PROTECT mACgUFFIN\n" ..
        "lANDING zONE FROM ALIENS.\n" ..
        "\n" ..
        "uSE THE LATEST DEVICES FROM\n" ..
        "mODtECH dEFENSE cONSORTIUM.\n" ..
        "\n" ..
        "- sELECT A TOWER WITH Ž.\n" ..
        "- pLACE A MODULE IN THE tARGET\n" ..
        "  SLOT TO SET THE FIRE MODE.\n" ..
        "- MODULES CAN ALSO ADD fLIGHT\n" ..
        "  BEHAVIOR AND IMPACT eFFECTS.\n" ..
        "- wATCH FOR ALIENS CARRYING\n" ..
        "  MORE MODULES.\n" ..
        "\n" ..
        "tRY ALL THE COMBINATIONS."

    print(instructions,4,19)
end


inventorySelectIndex = -1

function activateInventorySelect()
    inventorySelectIndex = min(#inventory, 1)
    hudMode = hudModeInventorySelect
end

function initInventory(itemCount)
    inventory = {}
    for i=1,itemCount do
        addItemToInventory()
    end
end

function addItemToInventory()
    add(inventory, createItem())
end

function updateInventorySelect()
    if btnp(5) then
        hudMode = hudModeTowerBuild
        sfx(29)
        inventorySelectIndex = -1
    elseif btnp(4) then
        towerBuildSlotItem(inventorySelectIndex)
        hudMode = hudModeTowerBuild
        sfx(25)
        inventorySelectIndex = -1
    else
        inventorySelectIndex = getSelectedVerticalList(inventorySelectIndex, #inventory, true)
    end
end


function showLevelSelect()
    _update60 = updateLevelSelect
    _draw = drawLevelSelect
    selectedLevel = 1
end

function updateLevelSelect()
    levelX = (selectedLevel - 1) % 3
    levelY = (selectedLevel - 1) \ 3
    if (btnp(0)) levelX = max(0, levelX - 1)
    if (btnp(1)) levelX = min(2, levelX + 1)
    if (btnp(2)) levelY = max(0, levelY - 1)
    if (btnp(3)) levelY = min(1, levelY + 1)

    newSelectedLevel = 1 + levelX + levelY * 3
    if newSelectedLevel != selectedLevel then
        selectedLevel = newSelectedLevel
        sfx(27)
    end

    if btnp(5) then
        sfx(29)
        showTitleScreen()
        return
    end
    if btnp(4) then
        level = levels[selectedLevel]
        accessible = (beatenLevels & level.requiredLevels) == level.requiredLevels
        if accessible then
            sfx(28)
            beginGame(level)
            return
        end
    end
end

function drawLevelSelect()
    cls()
    drawHudRect(rectangle(vec2(4, 4), vec2(123, 123)))

    print("lEVEL sELECT", 40, 12, 7)

    for levelNum=1,#levels do
        level = levels[levelNum]

        accessible = (beatenLevels & level.requiredLevels) == level.requiredLevels

        if accessible then
            pal()
        else
            pal(15, 6)
            pal(4, 5)
            pal(2, 5)
            pal(8, 6)
            pal(14, 7)
        end
        palt(0b0100000000000000)

        zeroBased = levelNum - 1
        x = 24 + (zeroBased % 3) * 32
        y = 30 + (zeroBased \ 3) * 40
        spr(level.miniMap, x, y)
        spr(level.miniMap + 1, x + 8, y)
        spr(level.miniMap + 16, x, y + 8)
        spr(level.miniMap + 17, x + 8, y + 8)

        if selectedLevel == levelNum then
            spr(11, x-1, y-1)
            spr(11, x+9, y-1, 1, 1, true)
            spr(11, x-1, y+9, 1, 1, false, true)
            spr(11, x+9, y+9, 1, 1, true, true)
        end

        if beatenLevels & (1 << levelNum) != 0 then
            spr(13, x, y + 17)
            spr(14, x + 8, y + 17)
            spr(29, x, y + 25)
            spr(30, x + 8, y + 25)
        else
            spr(12, x, y + 17)
            spr(12, x + 8, y + 17, 1, 1, true)
            spr(12, x, y + 25, 1, 1, false, true)
            spr(12, x + 8, y + 25, 1, 1, true, true)
        end
    end
    pal()

    if beatenLevels == 126 then
        print("cONGRATULATIONS!", 32, 114, 7)
    end
end


function createLingeringProjectile(projectile, hitEnemy)
    if (projectile.dead) return

    newLP = {}
    newLP.pos = projectile.pos
    if (hitEnemy) newLP.pos = 0.5 * newLP.pos + 0.5 * hitEnemy.pos
    newLP.remainingTicks = 110

    newLP.impactDamageMultiplier = projectile.impactDamageMultiplier

    newLP.anim = projectile.anim
    newLP.replaceColor = projectile.replaceColor
    newLP.buff = projectile.buff

    newLP.update = updateLingeringProjectile

    newLP.hitEnemies = {}
    if hitEnemy != nil then
        projectileApplyToEnemy(newLP, hitEnemy)
        newLP.hitEnemies[hitEnemy] = true
    end

    add(lingeringProjectiles, newLP)

    projectile.dead = true
    del(projectiles, projectile)
    sfx(32)
end

function updateLingeringProjectile(lp)
    lp.remainingTicks -= 1
    if (lp.remainingTicks == 0) destroyLingeringProjectile(lp)
    
    for enemy in all(enemies) do
        offset = enemy.pos - lp.pos
        if abs(offset.x) < 0.75 and abs(offset.y) < 0.75 and lp.hitEnemies[enemy] == nil then
            projectileApplyToEnemy(lp, enemy)
            lp.hitEnemies[enemy] = true
        end
    end

    updateAnim(lp.anim)
end

function destroyLingeringProjectile(lp)
    createEffect(3, effectDataPixelSpray(lp.pos, lp.replaceColor, vec2(1, 0), 1, 0.05, 0.12, 4.5, 8))
    del(lingeringProjectiles, lp)
end

function drawLingeringProjectile(lp)
    pal(projectileReplaceColor, lp.replaceColor)
    drawAnim(lp.anim, lp.pos)
end

function drawLingeringProjectiles()
    foreach(lingeringProjectiles, drawLingeringProjectile)
    pal(projectileReplaceColor, projectileReplaceColor)
end



animProjectileDefault = {32}
projectileReplaceColor = 14

projectileSpeed = 0.1

function createProjectile(startPos, target, attackItem, impactItem, buffItem, suppressSound)
    local newProjectile = {}
    newProjectile.startPos = startPos
    newProjectile.pos = startPos
    newProjectile.aliveTicks = 0

    if target.finalRadius != nil then
        absorbTable(newProjectile, target)
    elseif target.x == nil then
        newProjectile.waypoints = target
        newProjectile.waypointIndex = 1
        newProjectile.target = target[1]
    else
        newProjectile.target = target
    end
    newProjectile.speed = projectileSpeed

    if (attackItem.attackSpeedMultiplier) newProjectile.speed *= attackItem.attackSpeedMultiplier

    newProjectile.impactDamageMultiplier = 1
    if impactItem != nil then
        newProjectile.impact = impactItem.impact
        newProjectile.impactDamageMultiplier = impactItem.impactDamageMultiplier or newProjectile.impactDamageMultiplier
        newProjectile.arrive = impactItem.arrive
        newProjectile.anim = startAnim(impactItem.projectileAnim, impactItem.projectileAnimRate)
        newProjectile.replaceColor = impactItem.unbuffedProjectileColor
        if (impactItem.projectileSFX and not suppressSound) sfx(impactItem.projectileSFX)
        newProjectile.noDeathFX = impactItem.projectileNoDeathFX
        newProjectile.deathSFX = impactItem.projectileDeathSFX
    else
        newProjectile.impact = projectileDefaultImpact
        newProjectile.arrive = destroyProjectile
        newProjectile.anim = startAnim(animProjectileDefault, 8)
        newProjectile.replaceColor = 9
        if (not suppressSound) sfx(39)
        newProjectile.deathSFX = 40
    end

    newProjectile.update = updateProjectile

    if buffItem != nil then
        newProjectile.buff = buffItem.buff
        newProjectile.replaceColor = buffItem.projectileColor
    end

    newProjectile.hitEnemies = {}

    add(projectiles, newProjectile)
end

function impactPassthrough(projectile, enemy)
    if projectile.hitEnemies[enemy] == nil then
        projectileApplyToEnemy(projectile, enemy)
        projectile.hitEnemies[enemy] = true
    end
end

function projectileApplyToEnemy(projectile, enemy)
    if (projectile.buff != nil) projectile.buff(projectile, enemy)
    damage = 10
    damage *= projectile.impactDamageMultiplier

    dealEnemyDamage(enemy, damage)
end

function projectileDefaultImpact(projectile, enemy)
    projectileApplyToEnemy(projectile, enemy)
    destroyProjectile(projectile, true)
end

function destroyProjectile(projectile, preventSFX)
    if (projectile.deathSFX and not preventSFX) sfx(projectile.deathSFX)
    if not projectile.noDeathFX then
        createEffect(3, effectDataPixelSpray(projectile.pos, projectile.replaceColor, projectile.vel, 0.1, 0.1, 0.25, 5.5, 8))
    end
    del(projectiles, projectile)
end

function updateProjectile(projectile)
    projectile.aliveTicks += 1

    if projectile.currentAngle != nil then
        alpha = projectile.aliveTicks / projectile.duration
        radius = alpha * projectile.finalRadius
        projectile.currentAngle += projectile.angleRate
        lastPos = projectile.pos
        projectile.pos = projectile.startPos + radius * vec2(sin(projectile.currentAngle), cos(projectile.currentAngle))
        projectile.vel = projectile.pos - lastPos
        arrived = alpha >= 1
    else
        arrived = moveTowards(projectile, projectile.target)
    end
    
    for enemy in all(enemies) do
        offset = enemy.pos - projectile.pos
        if abs(offset.x) < 0.7 and abs(offset.y) < 0.7 then
            projectile:impact(enemy)
        end
    end

    if arrived then
        if projectile.waypoints != nil and projectile.waypointIndex < #projectile.waypoints then
            projectile.waypointIndex += 1
            projectile.target = projectile.waypoints[projectile.waypointIndex]
        else
            projectile:arrive()
        end
    end

    updateAnim(projectile.anim)
end

function drawProjectile(projectile)
    pal(projectileReplaceColor, projectile.replaceColor)
    drawAnim(projectile.anim, projectile.pos, projectile.vel)
end

function drawProjectiles()
    foreach(projectiles, drawProjectile)
    pal(projectileReplaceColor, projectileReplaceColor)
end


function initMap(mapX, mapY)
    mapWaypoints = {}
    for x=-1,14 do
        for y=-1,16 do
            tile = mget(mapX + 1 + x, mapY + 1 + y)
            mapFlags = fget(tile)
            if mapFlags != 0 then
                topFlags = mapFlags \ 64
                bottomFlags = mapFlags % 64
                if bottomFlags < 16 then
                    if (mapWaypoints[bottomFlags] == nil) mapWaypoints[bottomFlags] = {}
                    if topFlags != 0 then
                        if (mapWaypoints[bottomFlags][topFlags] == nil) mapWaypoints[bottomFlags][topFlags] = {}
                        add(mapWaypoints[bottomFlags][topFlags], vec2(x + 0.5, y + 0.5))
                    else
                        add(mapWaypoints[bottomFlags], vec2(x + 0.5, y + 0.5))
                    end
                    tile = 128
                elseif bottomFlags == 32 or bottomFlags == 33 then
                    createTower(vec2(x + 0.5, y + 0.5))
                    tile = bottomFlags + 96
                end
            end
            if (x >= 0 and x <= 13 and y >= 0 and y <= 15) mset(x, y, tile)
        end
    end
end

function drawMap()
    map(0,0,
        0,0,
        14,16)
end



function updateSelection()
    delta = vec2(0,0)
    if (btn(0)) delta.x -= 0.5
    if (btn(1)) delta.x += 0.5
    if (btn(2)) delta.y -= 0.5
    if (btn(3)) delta.y += 0.5

    if (delta.x == 0 and selectionVel.x != 0) delta.x = -sgn(selectionVel.x) / 2
    if (delta.y == 0 and selectionVel.y != 0) delta.y = -sgn(selectionVel.y) / 2

    selectionVel += delta
    selectionVel:clamp(-1.5, 1.5)

    delta = 0.125 * selectionVel

    if #selectionVel > 0 then
        for tower in all(towers) do
            offset = tower.pos - selectionLocation
            dist = #offset
            distAlpha = dist / 1.5
            if distAlpha > 0 and distAlpha < 1 then
                deltaLength = #delta

                shiftedCosine = max(0, 0.5 + offset:alignment(selectionVel))
                
                shift = shiftedCosine * 0.75 * (1 - distAlpha)

                delta += (shift / dist) * offset
                delta = (deltaLength / #delta) * delta
            end
        end
    end

    selectionLocation += delta
    selectionLocation.x = clamp(selectionLocation.x, 0.5, 13.5)

    minY = 0.5 + clamp((selectionLocation.x - 9) / 0.75, 0, 1.25)
    selectionLocation.y = clamp(selectionLocation.y, minY, 15.5)

    if (btnp(4)) attemptSelect()
end

function attemptSelect()
    for tower in all(towers) do
        if #(selectionLocation - tower.pos) < 0.8 then
            sfx(28)
            selectionLocation = tower.pos
            startTowerBuild(tower)
        end
    end
end

function drawSelection()
    drawSelectionBox(tileWorldToScreen(selectionLocation), hudMode == hudModeDefault, false)
end


function showTitleScreen()
    _update60 = updateTitleScreen
    _draw = drawTitleScreen
    showMenu = false
    music(-1, 100)
    removeGameMenuItems()
end

function updateTitleScreen()
    if showMenu then
        if btnp(4) then
            sfx(28)
            titleScreenOptionSelected()
            return
        elseif btnp(5) then
            sfx(29)
            showMenu = false
        end
        selectedMenuOption = getSelectedVerticalList(selectedMenuOption, 3, false, true)
    else
        if btnp(4) then
            sfx(26)
            showMenu = true
            selectedMenuOption = 1
        end
    end
end

function drawTitle(startX, startY)
    palt(0b0000000000001000)
    for y=0,1 do
        for x=0,9 do
            spr(224 + x + 16 * y, startX + 8 * x, startY + 8 * y)
        end
    end
end

menuOptions = {
    {
        text="start",
        startX=55,
        endX=66
    },
    {
        text="instructions",
        startX=40,
        endX=79
    },
    {
        text="credits",
        startX=50,
        endX=69
    }
}

function drawTitleScreen()
    cls(12)
    rectfill(0, 100, 127, 127, 4)
    pal(15,12)
    map(0, 18, 0, 35, 16, 11)
    pal()
    
    drawTitle(24, 20)

    color(0)
    if showMenu then
        posY = 58
        for i=1,#menuOptions do
            menuOption = menuOptions[i]
            if selectedMenuOption == i then
                spr(234, menuOption.startX-3, posY-2)
                spr(235, menuOption.endX+3, posY-2)
            end
            print(menuOption.text, menuOption.startX, posY)
            posY += 8
        end
    else
        print("press Ž", 48, 66)
    end
end

function titleScreenOptionSelected()
    if selectedMenuOption == 1 then
        showLevelSelect("titleScreen")
    elseif selectedMenuOption == 2 then
        showInstructions()
    else
        showCredits()
    end
end


animEmptyTower = {16}

attackSlot = 1
impactSlot = 2
buffSlot = 3

maxSlotCooldown = 60

towerReplaceColorImpact = 11
towerReplaceColorBuff = 15

function createTower(pos)
    local newTower = {}
    newTower.pos = pos
    newTower.anim = startAnim(animEmptyTower, 8)
    newTower.update = updateTower
    newTower.timeToFire = -1
    newTower.slotCooldown = 0
    newTower.slots = {}
    add(towers, newTower)
end

function slotItemInTower(tower, item, slot)
    if (item == tower.slots[slot]) return

    tower.slots[slot] = item
    if slot == attackSlot then
        tower.timeToFire = item.attackTime \ 4
        tower.anim = startAnim(item.anim, 8)
    end

    tower.slotCooldown = maxSlotCooldown

    delayWaveBy = 60
end

function updateTower(tower)
    if tower.slotCooldown > 0 then
        tower.slotCooldown -= 1
    elseif tower.slots[attackSlot] == nil then
        tower.timeToFire = 0
    elseif tower.timeToFire > 0 then
        tower.timeToFire -= 1
        if (tower.timeToFire == 0) towerFire(tower)
    end
    updateAnim(tower.anim)
end

function towerFire(tower, suppressSound)
    extraRange = tower.slots[impactSlot] and tower.slots[impactSlot].extraRange
    attack = tower.slots[attackSlot].attack(tower, extraRange)

    tower.timeToFire = tower.slots[attackSlot].attackTime

    if (attack == nil) return

    createProjectile(tower.pos, attack.target,
        tower.slots[attackSlot], tower.slots[impactSlot], tower.slots[buffSlot],
        suppressSound)

    if attack.attackTime then
        if attack.attackTime == 0 then
            towerFire(tower, true)
        else
            tower.timeToFire = attack.attackTime
        end
    end
end

function replaceTowerColor(tower, slot, destColor, sourceColorKey)
    if tower.slots[slot] then
        pal(destColor, tower.slots[slot][sourceColorKey])
    elseif tower.slots[attackSlot] then
        pal(destColor, tower.slots[attackSlot][sourceColorKey .. "Default"])
    else
        pal(destColor, destColor)
    end
end

function drawTower(tower)
    replaceTowerColor(tower, impactSlot, towerReplaceColorImpact, "towerImpactColor")
    replaceTowerColor(tower, buffSlot, towerReplaceColorBuff, "towerBuffColor")

    drawAnim(tower.anim, tower.pos)
    if tower.slotCooldown > 0 then
        topCorner = tileWorldToScreen(tower.pos)
        rectfill(topCorner.x, topCorner.y - 2, topCorner.x + 7, topCorner.y - 2, 0)
        rectfill(topCorner.x, topCorner.y - 2, topCorner.x + 7 * (tower.slotCooldown / maxSlotCooldown), topCorner.y - 2, 12)
    end
end

function drawTowers()
    foreach(towers, drawTower)
    pal(towerReplaceColorImpact, towerReplaceColorImpact)
    pal(towerReplaceColorBuff, towerReplaceColorBuff)
end


buildingTower = nil
towerBuildRectangle = nil
selectedTowerSlot = -1

function startTowerBuild(tower)
    buildingTower = tower
    hudMode = hudModeTowerBuild
    gamePaused = true
    selectedTowerSlot = 1

    minCorner = vec2(0, 0)
    if (tower.pos.x < 7) minCorner.x = 41
    if (tower.pos.y < 8) minCorner.y = 73
    maxCorner = minCorner + vec2(71, 54)

    towerBuildRectangle = rectangle(minCorner, maxCorner)
end

function updateTowerBuild()
    if btnp(5) then
        buildingTower = nil
        gamePaused = false
        hudMode = hudModeDefault
        sfx(29)
    elseif btnp(4) then
        sfx(28)
        activateInventorySelect()
    elseif buildingTower.slots[attackSlot] != nil then
        selectedTowerSlot = getSelectedVerticalList(selectedTowerSlot, 3)
    end
end

function towerBuildSlotItem(itemIndex)
    if buildingTower.slots[selectedTowerSlot] != nil then
        add(inventory, buildingTower.slots[selectedTowerSlot])
        buildingTower.slots[selectedTowerSlot] = nil
    end
    
    if itemIndex != 0 then
        item = inventory[itemIndex]
        deli(inventory, itemIndex)
        slotItemInTower(buildingTower, item, selectedTowerSlot)
        if (selectedTowerSlot == attackSlot) slottedTowerCount += 1
    elseif selectedTowerSlot == attackSlot then
        selectedTowerSlot = impactSlot
        towerBuildSlotItem(0)
        selectedTowerSlot = buffSlot
        towerBuildSlotItem(0)
        selectedTowerSlot = attackSlot
        
        buildingTower.anim = startAnim(animEmptyTower, 8)
        
        slottedTowerCount -= 1
    end
end

function drawTowerSlot(x, y, i, text, tooltipKey, enabled)
    color(5)
    if (enabled) color(0)
    rectfill(x, y, x + 6, y + 6)

    item = buildingTower.slots[i]
    if selectedTowerSlot == i then
        if (hudMode == hudModeInventorySelect) item = inventory[inventorySelectIndex]

        if (item != nil) spr(item.sprite, x, y)

        drawSelectionBox(vec2(x, y), hudMode == hudModeTowerBuild, true)
        if tooltipKey != nil and item != nil then
            print(item[tooltipKey], towerBuildRectangle.min.x + 4, towerBuildRectangle.min.y + 32, 6)
        end
    else
        if (item != nil) spr(item.sprite, x, y)
    end

    color(5)
    if (enabled) color(6)
    print(text, x + 9, y + 1)
end

function drawTowerBuild()
    hasAttack = buildingTower.slots[attackSlot] != nil

    drawHudRect(towerBuildRectangle)
    x = towerBuildRectangle.min.x + 4
    y = towerBuildRectangle.min.y + 4
    drawTowerSlot(x, y, attackSlot, "tARGET", "tooltipAttack", true)
    y += 9
    drawTowerSlot(x, y, impactSlot, "fLIGHT", "tooltipImpact", hasAttack)
    y += 9
    drawTowerSlot(x, y, buffSlot, "eFFECT", "tooltipBuff", hasAttack)
end



function applyCrit(projectile, enemy)
    if rnd(100) < 35 then
        dealEnemyDamage(enemy, 20 * projectile.impactDamageMultiplier)
        
        for dir in all({vec2(-1, 1), vec2(1, 1)}) do
            createEffect(8, effectDataPixelSpray(enemy.pos + -1.5 * dir, {0, 7}, dir, 0.015, 0.35, 0.55, 20.5, 7))
        end
    end
end

function attackTargeted(tower, extraRange)
    range = 6
    if (extraRange) range *= 1.2

    chosenEnemy = nil
    numEnemiesSeen = 0
    for enemy in all(enemies) do
        thisDist = #(tower.pos - enemy.pos)
        if thisDist < range then
            numEnemiesSeen += 1
            if rnd(1) <= 1 / numEnemiesSeen then
                chosenEnemy = enemy
                chosenDist = thisDist
            end
        end
    end

    if (chosenEnemy == nil) return nil

    timeToHitCurrentPos = chosenDist / (projectileSpeed * aim.attackSpeedMultiplier)
    enemyPosAtTime = chosenEnemy.pos + timeToHitCurrentPos * chosenEnemy.vel

    offset = enemyPosAtTime - tower.pos
    offset:normalize()

    return {
        target = tower.pos + range * offset
    }
end

aim = {
    sprite = 51,
    anim = {20},
    attackTime = 220,
    attack = attackTargeted,
    attackSpeedMultiplier = 1.9,
    tooltipAttack = "aCTUALLY AIMS AT\nRANDOM MONSTERS.\nwEIRD...",
    impactDamageMultiplier = 0.7,
    impact = impactPassthrough,
    arrive = destroyProjectile,
    extraRange = true,
    projectileAnim = {right={35}, up={36}, diag={37}},
    projectileAnimRate = 4,
    projectileSFX = 44,
    projectileDeathSFX = 45,
    unbuffedProjectileColor = 13,
    tooltipImpact = "gOES LIKE\nA HOT BULLET\nTHROUGH BUTTER.",
    buff = applyCrit,
    projectileColor = 7,
    tooltipBuff = "hOPE FOR A LUCKY\nHIT. wHERE ARE\nTHEY WEAK?",
    
    towerImpactColorDefault = 0,
    towerBuffColorDefault = 0,
    towerImpactColor = 6,
    towerBuffColor = 7,
}


function applyDot(projectile, enemy)
    enemy.dotInterval = 30
    if (enemy.dotTicks == 0) enemy.dotTicks = enemy.dotInterval
    enemy.dotRemaining = flr(8 * projectile.impactDamageMultiplier)
    
    createEffect(enemy.dotInterval * enemy.dotRemaining,
        effectDataPixelSpray(enemy.pos, 8, vec2(0, 1), 0.25, 0.02, 0.04, 0.07, 16),
        enemy)
end

function arriveBoomerang(projectile)
    projectile.hitEnemies = {}
    projectile.target = projectile.startPos
    projectile.currentAngle = nil
    projectile.arrive = destroyProjectile
    sfx(43)
end

function attackSlash(tower, extraRange)
    if (tower.slashShot == nil) tower.slashShot = 0

    tower.slashShot += 1
    offset = slashOffsetsAndTimes[tower.slashShot][1]
    if (extraRange) offset = 1.2 * offset
    attackTime = slashOffsetsAndTimes[tower.slashShot][2]
    if (tower.slashShot == #slashOffsetsAndTimes) tower.slashShot = 0

    return {
        target = tower.pos + offset,
        attackTime = attackTime
    }
end

blade = {
    sprite = 49,
    anim = {18},
    attackTime = 200,
    attack = attackSlash,
    tooltipAttack = "sLASHES A y:\ntHE MARK OF\nyORRO.",
    impactDamageMultiplier = 0.6,
    impact = impactPassthrough,
    arrive = arriveBoomerang,
    projectileAnim = {21,22,23,24},
    projectileAnimRate = 8,
    projectileSFX = 42,
    projectileNoDeathFX = true,
    unbuffedProjectileColor = 2,
    tooltipImpact = "fLIES BACK LIKE\nA TOTALLY SAFE\nBOOMERANG.",
    buff = applyDot,
    projectileColor = 8,
    tooltipBuff = "iF YOU PRICK\nTHEM, DO THEY\nNOT BLEED?",
    
    towerImpactColorDefault = 6,
    towerBuffColorDefault = 7,
    towerImpactColor = 8,
    towerBuffColor = 14,
}

slashOffsetsAndTimes = {
    { vec2(2.5, -5.0), 0 },
    { vec2(-2.5, 4.5), 0 },
    { vec2(-2.5, -5.0), blade.attackTime }
}


function applyStun(projectile, enemy)
    enemy.stunTicks = flr(40 * projectile.impactDamageMultiplier)

    createEffect(enemy.stunTicks,
        effectDataPixelSpray(enemy.pos, 10, vec2(0, -1), 0.5, 0.04, 0.07, 0.15, 12),
        enemy)
end

function attackBolt(tower, extraRange)
    waypoints = {}
    boltShotOffset = vec2(0, 0)

    iterations = 8
    if (extraRange) iterations *= 1.2

    for i=1,iterations do
        boltShotOffset += vec2(rnd(3.8) - 1.9 - boltShotOffset.x, 0.35 + rnd(0.55))
        add(waypoints, tower.pos + boltShotOffset)
    end
    return {
        target = waypoints
    }
end

function impactBolt(projectile, hitEnemy)
    range = 3

    chosenEnemy = nil
    chosenDist = 4
    chosenOffset = nil
    numEnemiesSeen = 0
    for enemy in all(enemies) do
        thisOffset = enemy.pos - hitEnemy.pos
        thisDist = #thisOffset
        if enemy != hitEnemy and thisDist < chosenDist then
            numEnemiesSeen += 1
            if rnd(1) <= 1 / numEnemiesSeen then
                chosenEnemy = enemy
                chosenDist = thisDist
                chosenOffset = thisOffset
            end
        end
    end

    if chosenEnemy then
        segmentCount = max(2, flr(chosenDist / 0.5))
        segments = { hitEnemy.pos }
        orthogonal = vec2(chosenOffset.y / chosenDist, -chosenOffset.x / chosenDist)
        for i=2,segmentCount do
            add(segments, hitEnemy.pos + ((i - 1) / segmentCount) * chosenOffset + randFloat(-1, 1) * orthogonal)
        end
        add(segments, chosenEnemy.pos)
        
        projectileApplyToEnemy(projectile, chosenEnemy)
        createEffect(9, effectDataLightning(10, segments))
        sfx(33)
    end

    projectileDefaultImpact(projectile, hitEnemy)
end

bolt = {
    sprite = 50,
    anim = {19},
    attackTime = 110,
    attack = attackBolt,
    attackSpeedMultiplier = 1.9,
    tooltipAttack = "zIGS AND ZAGS\nDOWN, FOR SOME\nVERSION OF DOWN.",
    impactDamageMultiplier = 0.9,
    impact = impactBolt,
    arrive = destroyProjectile,
    projectileAnim = {33,34,-33,-34,33+256,34+256,-33-256,-34-256},
    projectileAnimRate = 4,
    projectileSFX = 37,
    projectileDeathSFX = 38,
    unbuffedProjectileColor = 9,
    tooltipImpact = "hIT ONE, ZAP ONE\nABSOLUTELY FREE!",
    buff = applyStun,
    projectileColor = 10,
    tooltipBuff = "tHE BEAUTY OF\nTHE LIGHTNING\nIS STUNNING.",
    
    towerImpactColorDefault = 5,
    towerBuffColorDefault = 13,
    towerImpactColor = 9,
    towerBuffColor = 10,
}


function applySlow(projectile, enemy)
    enemy.speedMult = 1 - (0.55 * projectile.impactDamageMultiplier)
    enemy.speedMultTicks = 140
    
    createEffect(enemy.speedMultTicks,
        effectDataPixelSpray(enemy.pos, 12, vec2(0, 1), 1, 0.02, 0.04, 0.2, 30),
        enemy)
end

function attackCircle(tower, extraRange)
    finalRadius = 4
    duration = 100
    if extraRange then
        finalRadius *= 1.2
        duration *= 1.2
    end

    startAngle = rnd(1)
    return {
        target = {
            finalRadius = finalRadius,
            duration = duration,
            currentAngle = startAngle,
            angleRate = -0.025
        }
    }
end

clock = {
    sprite = 48,
    anim = {17},
    attackTime = 150,
    attack = attackCircle,
    tooltipAttack = "rOUND AND ROUND,\nNEVER SLOWING,\nGETTING DIZZY.",
    impact = createLingeringProjectile,
    arrive = createLingeringProjectile,
    projectileAnim = {52,53},
    projectileAnimRate = 4,
    projectileSFX = 34,
    unbuffedProjectileColor = 13,
    tooltipImpact = "iS THE TOP\nSTILL SPINNING?",
    buff = applySlow,
    projectileColor = 12,
    tooltipBuff="dAYLIGHT sAVINGS\nMAKES MONSTERS\nSLEEPY AND SLOW.",
    
    towerImpactColorDefault = 13,
    towerBuffColorDefault = 7,
    towerImpactColor = 1,
    towerBuffColor = 12,
}


possibleItems = {
    clock=clock,
    blade=blade,
    bolt=bolt,
    aim=aim
}

function createItem()
    if (#availableItems == 0) return nil
    result = rnd(availableItems)
    del(availableItems, result)
    return result
end


function beginLevel(level)
    lives = maxLives
    killsPerItem = level.killsPerItem
    killsTowardsItem = 0
    availableItems = {}
    slottedTowerCount = 0

    previousLevel = level

    for i=1,#levels do
        if level == levels[i] then
            previousLevelNum = i
            break
        end
    end

    for itemName, count in pairs(level.items) do
        for i=1,count do
            add(availableItems, possibleItems[itemName])
        end
    end

    levelEnemySpeedMultiplier = level.enemySpeedMultiplier or 1
    levelEnemyHealthMultiplier = level.enemyHealthMultiplier or 1

    initInventory(level.startingItems)
    towers = {}
    enemies = {}
    projectiles = {}
    lingeringProjectiles = {}
    initEffects()
    initHud()

    selectionLocation = vec2(8, 8)
    selectionVel = vec2(0, 0)

    initMap(level.mapX, level.mapY)
    beginEnemyWaves(level.waves)
end

function restartLevel()
    beginLevel(previousLevel)
end


levelS = {
    mapX=15,
    mapY=0,
    startingItems=3,
    killsPerItem=3,
    waves={
        {
            delay=600,
            enemy=enemyBasic,
            spawnCount=4,
            spawnDelay=50
        },
        {
            delay=240,
            enemy=enemyBasic,
            spawnCount=6,
            spawnDelay=40
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=4,
            spawnDelay=50
        }
    },
    items={
        aim=0,
        blade=2,
        bolt=2,
        clock=3
    },
    miniMap=96,
    requiredLevels = 0
}

levelIsland = {
    mapX=31,
    mapY=0,
    startingItems=5,
    killsPerItem=4,
    waves={
        {
            delay=600,
            enemy=enemyBasic,
            spawnCount=5,
            spawnDelay=70
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=2,
            spawnDelay=90
        },
        {
            delay=240,
            enemy=enemyBasic,
            spawnCount=6,
            spawnDelay=50
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=4,
            spawnDelay=90
        }
    },
    items={
        aim=2,
        blade=2,
        bolt=4,
        clock=5
    },
    miniMap=98,
    requiredLevels = 2
}

levelH = {
    mapX=63,
    mapY=0,
    startingItems=5,
    killsPerItem=6,
    waves={
        {
            delay=600,
            enemy=enemyBasic,
            spawnCount=9,
            spawnDelay=50
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=5,
            spawnDelay=80
        },
        {
            delay=240,
            enemy=enemyBasic,
            spawnCount=12,
            spawnDelay=30
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=7,
            spawnDelay=70
        }
    },
    items={
        aim=4,
        blade=5,
        bolt=4,
        clock=6
    },
    miniMap=100,
    requiredLevels = 4
}

levelTwoPaths = {
    mapX=79,
    mapY=0,
    startingItems=6,
    killsPerItem=3,
    enemySpeedMultiplier=0.8,
    waves={
        {
            delay=360,
            enemy=enemyBasic,
            spawnCount=10,
            spawnDelay=60
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=4,
            spawnDelay=90
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=6,
            spawnDelay=70
        },
        {
            delay=240,
            enemy=enemyHeavy,
            spawnCount=2,
            spawnDelay=1
        }
    },
    items={
        aim=5,
        blade=4,
        bolt=5,
        clock=4
    },
    miniMap=66,
    requiredLevels = 4
}

levelCramped = {
    mapX=111,
    mapY=0,
    startingItems=6,
    killsPerItem=5,
    waves={
        {
            delay=600,
            enemy=enemyBasic,
            spawnCount=10,
            spawnDelay=60
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=7,
            spawnDelay=80
        },
        {
            delay=240,
            enemy=enemyHeavy,
            spawnCount=3,
            spawnDelay=360
        },
        {
            delay=240,
            enemy=enemyHeavy,
            spawnCount=6,
            spawnDelay=240
        }
    },
    items={
        aim=4,
        blade=5,
        bolt=4,
        clock=6
    },
    miniMap=64,
    requiredLevels = 24
}

levelMaze = {
    mapX=95,
    mapY=0,
    startingItems=7,
    killsPerItem=10,
    enemySpeedMultiplier=1.3,
    enemyHealthMultiplier=1.5,
    waves={
        {
            delay=600,
            enemy=enemyBasic,
            spawnCount=18,
            spawnDelay=50
        },
        {
            delay=240,
            enemy=enemyTough,
            spawnCount=13,
            spawnDelay=110
        },
        {
            delay=240,
            enemy=enemyHeavy,
            spawnCount=7,
            spawnDelay=300
        },
        {
            delay=240,
            enemy=enemyBasic,
            spawnCount=40,
            spawnDelay=60
        },
        {
            delay=240,
            enemy=enemyBoss,
            spawnCount=4,
            spawnDelay=600
        }
    },
    items={
        aim=6,
        blade=6,
        bolt=6,
        clock=6
    },
    miniMap=68,
    requiredLevels = 32
}

levels = {
    levelS,
    levelIsland,
    levelH,
    levelTwoPaths,
    levelCramped,
    levelMaze
}


------ TEST

levelTestSparse = {
    mapX=47,
    mapY=0,
    startingItems=8,
    killsPerItem=3000,
    waves={
        {
            delay=5,
            enemy=enemyBasic,
            spawnCount=5,
            spawnDelay=80
        }
    },
    items={
        aim=2,
        blade=2,
        bolt=2,
        clock=2
    }
}

levelTestDense = {
    mapX=47,
    mapY=0,
    startingItems=8,
    killsPerItem=3000,
    waves={
        {
            delay=5,
            enemy=enemyBasic,
            spawnCount=6,
            spawnDelay=50
        }
    },
    items={
        aim=2,
        blade=2,
        bolt=2,
        clock=2
    }
}



function initBalanceTest()
    maxLives = 10
    basicDraw = _draw
    _draw = drawBalanceTest
    showEndDisplay = balanceTestOnEnd

    poke(0x5f2d, 1)

    balanceTestResults = {}
end

function drawBalanceTest()
    basicDraw()

    for i=1,#balanceTestResults do
        print(balanceTestResults[i], 1, -6 + 7 * i, 1)
    end

    mouseX = stat(32)
    mouseY = stat(33)
    if (mouseX > 1 and mouseX < 127 and mouseY > 1 and mouseY < 127) circfill(mouseX, mouseY, 1, 11)
end

function balanceTestOnEnd()
    if #balanceTestResults == 10 then
        deli(balanceTestResults, 1)
    end
    add(balanceTestResults, lives)

    backupInventory = inventory
    backupTowers = towers
    backupSlottedTowerCount = slottedTowerCount
    restartLevel()
    inventory = backupInventory
    towers = backupTowers
    slottedTowerCount = backupSlottedTowerCount
end


__gfx__
0000000000dd600000dd7000000700000066600000dd6000000000007d000d70e80008e06d5005d6e820028eee88211111111111111111111111111100000000
000000000dddd60000ddd000000d0000006dd0000dddd60008000800d00000d080000080d000000d80000008e111111111111111111116666661111100000000
007007005d8d8d6005888d00000d000006d0dd005d0d0d60008080000000000000000000500000052000000281111111111111111111ddddddd6111100000000
000770005888886005888d00000d00000dd0dd005dd0dd6000080000000000000000000000000000000000008111111111111111111dddd55ddd611100000000
000770005d888d6005d8dd00000d00000dd0dd005d0d0d600080800000000000000000000000000000000000211111111111111111ddddd00dddd61100000000
0070070005d8dd000058d0000005000000ddd00005dddd0008000800d00000d080000080500000052000000211111111111111151dddddd00ddddd6100000000
00000000005dd000005dd00000050000005dd000005dd000000000007d000d70e80008e0d000000d8000000811111111111111501dddddd00ddddd6100000000
0000000000000000000000000000000000000000000000000000000000000000000000006d5005d6e820028e11111111111115001dd5000000005d6100000000
4448864444ccbc44444444444a4674a44446d4444444444444444e444444444444444444000000000000000000000000000000001dd5000000005d6100000000
488886444fccdcf4444444f44466674a44645d444e412444444444e44442144444444444000000000000000000000000000000001dddddd00ddddd6100000000
84444644c17cd7cc4444644f44666644464445d4e44412444444444444214444442ee2440000000000000000000000000000000015ddddd00ddddd6100000000
44444644bdd77ccc44b4464f4a4664a46bb000df44441e444144441444e144444211112400000000000000000000000000000000115dddd00ddddd1100000000
4444464411177ddb444444444a4bf44a464444d444441e444211112444e1444441444414000000000000000000000000000000001115ddd55dddd11100000000
4ddf56f4cc7d171188bb666fa44bf444446445d444441244442ee2444421444e444444440000000000000000000000000000000011115ddddddd111100000000
dd5555df4f1dc1f48866666744222e4444465d444441244444444444444214e44e44444400000000000000000000000000000000111115555551111100000000
55555555441bcc4444777774411222e44444d44444444444444444444444444444e4444400000000000000000000000000000000111111111111111100000000
44444444449944444449994444444444444444444444444444444444443444444444444444443444444444444444434400000000000000000000000000000000
44444444494499444494449444444444444ee4444444444444344444424444443444444434444244444443443444244400000000000000000000000000000000
44499444944444944449444944edde4444edde44444ee44442333324433332344233334343234344332442444323434400000000000000000000000000000000
449ee944494ee449449ee49444eddde444dddd4444ddde4444433443443344444443342444433344444343444443334400000000000000000000000000000000
449ee944944ee494494ee44944eddde444dddd444eddde4444333344343334444433334444433344444333444443334400000000000000000000000000000000
44499444494449444494499444edde4444eeee4444edd44444244244343442444244424444234334443333434443434400000000000000000000000000000000
4444444444994944449494444444444444444444444e444433444344424443444344434443444244424443244324424400000000000000000000000000000000
44444444444494444449444444444444444444444444444444444434444443444444443443444444443344444444443400000000000000000000000000000000
00ccc00000000670555555500066600044444e444444444444466444444444444444444444466444444554444554554444554554454454440000000000000000
0c0c0c00000066700555a500000600004dd444e444ee4d4444dddd44444664445444444544dddd44555455444554554445545544455455440000000000000000
c00c00c00006667000000a0060000060444d444444444d4445dddd5455dddd555546645545dddd5445ddddd44ddddd44ddddd44445ddddd40000000000000000
c00cc0c0006667000000a00066000660e44dd4d444ddd44e55dddd5555dddd5545dddd5455dddd5544ddddd64ddddd64ddddd64444ddddd60000000000000000
c00000c008867000000a000060000060e44ddd444d4dd44e54dddd4544dddd4454dddd4544dddd4444ddddd64ddddd64ddddd64444ddddd60000000000000000
0c000c008880000000a000000006000044d444444444d44445dddd5455dddd5555dddd5545dddd5445ddddd44ddddd44ddddd44445ddddd40000000000000000
00ccc00008000000000a00000066600044d4ee444e444dd44554455455dddd5545dddd5455444455555455444554554445545544455455440000000000000000
000000000000000000000000000000004444444444e44444454444544444444444dddd4444444444444554444554554444554554454454440000000000000000
444444444444444444444444444444444444444444444444ffffffffffffffaaaaaaffffffffffffffffffff001001111111111affffffff0000000000000000
444444444ffff4444444444444444444fffffffffffff444fffffffffffffaffffffaaafffffffffffffffff0010011111111111afffffff0000000000000000
4444444fffffffffff444444444444ffffffffffffffff44ffffffffffffa777777ffffaaaafffffffffffff0010011111111111afffffff0000000000000000
44444ffff4ffffffffff44444444ffff44444444444fff44ffffffaaaffa666677777ffffffaffffffffffff0010011111111a1aafffffff0000000000000000
444fffffff4ffff4ffffffffffffffff44444444444ffff4fffffafffa6666666667777fffffafffffffffff001001111111a1a1ffffffff0000000000000000
44fffffffffff4444ffffffffffffff44444fffff444fff4ffffafff6666666666666777fffaffffffffffff0016666666666111ffffffff0000000000000000
44fffffff4444444444ffffffffff444444fffffff44fff4fffafff666666666666666777fafffffffffffff0016566666656111ffffffff0000000000000000
44fffff444444444444444444444444444ffffffff44fff4fffafff666666666666666677affffffffffffff0016666666666111ffffffff0000000000000000
444fffffff4444444444fff44444444444ffffffff44fff4ffafff56666666666666666677ffffffffffffff0016666666666111ffffffff0000000000000000
444ffffffff44444444ffffff444444444fff444ff444ff4ffafff56666666666666666677ffffffffffffff0016666666666111ffffffff0000000000000000
4444ffffffff444444ffffffff44444444fff444fff44ff4ffaff5566666666666666666677fffffffffffff0016666666666111ffffffff0000000000000000
4444fffffffff444fffff44fffff44444ffff444fff44ff4fffaf5566666666666666666677fffffffffffff0016566666656111ffffffff0000000000000000
4444ffff44fff444fffff4444ffffffffffff444fff4fff4fffaf5566666666666666666677affffffffffff0016666666666111ffffffff0000000000000000
444ffff4444fff44ffff444444ffffffffff4444fffffff4ffaff5566666666666666666667fafffffffffff0010011111111111ffffffff0000000000000000
444ffff4444fff44fff444444444fffffff444444fffff44ffaff5556666666666666666667ffaffffffffff0010011111111111ffffffff0000000000000000
44ffff444444ff4444444444444444444444444444444444ffaff555666666666666aa66667ffaffffffffff0010011111111111ffffffff0000000000000000
4fff44444444444444444444444444444ff4444444444ff4ffafff555666666666aa66a666ffffaf444444440010011111111111444444440000000000000000
4fff444444444444fff44444444444444ff4444444444ff4ffafff55556666666a66666a66ffffaf444444440010011111111111444444440000000000000000
4fff444444fff444fffff444444444444fff44444444fff4ffaffff555566666a6666666afffffaf444444440010011111111111444444440000000000000000
4fff44444fffff44fffffff4444444444fff44444444fff4fffaffaaaa55566a666666666affffaf444444440010011111111111444444440000000000000000
4fff444fffffff444ffffffff44444444ffff444444ffff4ffffaaff55aaaaa666666666faffffaf444444440010011111111111444444440000000000000000
4ffff4ffffffff4444ffffffff4444444fffff4444fffff4ffffffff0555555a55666661ffafffaf444444440010011111111111444444440000000000000000
4ffff4ffffffff44444ff44fff4444444ffffffffffffff4ffffffff0015555a55555111fffafaff444444440010011111111111444444440000000000000000
4fffffffffffff44444ff44fff4444444ffffffffffffff4ffffffff0010055a55511111ffffafff444444745510011111111155474444440000000000000000
4fffffffffffff44444ffffffff444444ffffffffffffff4ffffffff0010011a11111111ffffffff444440705510551111551155070444440000000000000000
4ffffffff4ffff44444fffffffff44444ffffffffffffff4ffffffff0010011a11111111ffffffff444440505510551111551155050444440000000000000000
4fffffff444fff444444fffffffff4444fffff4444fffff4ffffffff0010011a11111111ffffffff444400000555551111555550000044440000000000000000
44ffffff444fff4444444ffffffffff44ffff444444ffff4ffffffff00100111a1111111ffffffff444400000005555555555000000044440000000000000000
44fffff4444fff44444444ffffffffff4fff44444444fff4ffffffff001001111a111111ffffffff444407000000000000000000007044440000000000000000
444fff44444fff44444444444fffffff4fff44444444fff4ffffffff0010011111a11111ffffffff444007000000000000000000007004440000000000000000
44444444444fff44444444444444ffff4ff4444444444ff4ffffffff00100111111a1111ffffffff444005000000000000000000005004440000000000000000
44444444444fff4444444444444444444ff4444444444ff4ffffffff001001111111aaa1ffffffff444400000000000000000000000044440000000000000000
ffffffff44444444ffffffffffffffff44444442244444444444ffffffff4444444444444444444444444444000000001111111122222222fff886ff44488644
ffffffff44444444fffffff44fffffff4444444ff44444444444ffffffff4444444444444444444444444444000000001111111122222222f88886ff48888644
ffffffff44444444ffffff4444ffffff4444442ff24444444444ffffffff44444444444444444444444444440000000011111111222222228ffff6ff84444644
ffffffff44444444fffff444444fffff444444ffff4444444444ffffffff4444444444444444444444444444000000001111111122222222fffff6ff44444644
ffffffff44444444ffff44444444ffff444442ffff2444444444ffffffff4444444444444444444444444444000000001111111122222222fffff6ff44444644
ffffffff44444444fff4444444444fff44444ffffff444444444ffffffff4444444444444444444444444444000000001111111122222222f666666f46666664
ffffffff44444444ff444444444444ff44442ffffff244444444ffffffff44444444444444444444444444440000000011111111222222226666666666666666
ffffffff44444444f44444444444444f4444ffffffff44444444ffffffff44444444444222222222244444440000000011111111222222226666666666666666
0000000000000000f24444444444442f4442ffffffff2444ffffffff44444444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000000000000000ff244444444442ff444ffffffffff444ffffffff44444444fff1fffffff11ffffff11fffff1ff1ffff1111fffff111ffff1111fffff11fff
0000000000000000fff2444444442fff442ffffffffff244ffffffff44444444ff11ffffff1ff1ffff1ff1ffff1ff1ffff1fffffff1ffffffffff1ffff1ff1ff
0000000000000000ffff24444442ffff44ffffffffffff44ffffffff22222222fff1fffffffff1fffffff1ffff1111ffff111fffff111fffffff1ffffff11fff
0000000000000000fffff244442fffff42ffffffffffff2444444444fffffffffff1ffffffff1fffffff1ffffffff1fffffff1ffff1ff1fffff1ffffff1ff1ff
0000000000000000ffffff2442ffffff4ffffffffffffff444444444fffffffffff1fffffff1ffffff1ff1fffffff1fffffff1ffff1ff1fffff1ffffff1ff1ff
0000000000000000fffffff22fffffff2ffffffffffffff244444444fffffffff11111ffff1111fffff11ffffffff1ffff111ffffff11ffffff1fffffff11fff
0000000000000000ffffffffffffffffffffffffffffffff44444444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
4ffffffffffffffffffffffffffffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
444ffffffffffffffffffffffffff4444ffffffffffffff4fff4fffffff4fffffffbfffffffbbffffffbbfffffbffbffffbbbbfffffbbbffffbbbbfffffbbfff
44444ffffffffffffffffffffff444444ffffffffffffff4ff444ffffff4ffffffbbffffffbffbffffbffbffffbffbffffbfffffffbffffffffffbffffbffbff
4444444ffffffffffffffffff444444444ffffffffffff44f4f4f4fffff4fffffffbfffffffffbfffffffbffffbbbbffffbbbfffffbbbfffffffbffffffbbfff
444444444ffffffffffffff44444444444ffffffffffff44fff4fffff4f4f4fffffbffffffffbfffffffbffffffffbfffffffbffffbffbfffffbffffffbffbff
44444444444ffffffffff44444444444444ffffffffff444fff4ffffff444ffffffbfffffffbffffffbffbfffffffbfffffffbffffbffbfffffbffffffbffbff
4444444444444ffffff4444444444444444ffffffffff444fff4fffffff4fffffbbbbbffffbbbbfffffbbffffffffbffffbbbffffffbbffffffbfffffffbbfff
444444444444444ff4444444444444444444ffffffff4444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
444444444444422ff2244444444444444444ffffffff4444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
4444444444422ffffff224444444444444444ffffff44444ffff4ffffff4fffffff8fffffff88ffffff88fffff8ff8ffff8888fffff888ffff8888fffff88fff
44444444422ffffffffff2244444444444444ffffff44444fffff4ffff4fffffff88ffffff8ff8ffff8ff8ffff8ff8ffff8fffffff8ffffffffff8ffff8ff8ff
444444422ffffffffffffff224444444444444ffff444444f444444ff444444ffff8fffffffff8fffffff8ffff8888ffff888fffff888fffffff8ffffff88fff
4444422ffffffffffffffffff2244444444444ffff444444fffff4ffff4ffffffff8ffffffff8fffffff8ffffffff8fffffff8ffff8ff8fffff8ffffff8ff8ff
44422ffffffffffffffffffffff224444444444ff4444444ffff4ffffff4fffffff8fffffff8ffffff8ff8fffffff8fffffff8ffff8ff8fffff8ffffff8ff8ff
422ffffffffffffffffffffffffff2244444444ff4444444fffffffffffffffff88888ffff8888fffff88ffffffff8ffff888ffffff88ffffff8fffffff88fff
2ffffffffffffffffffffffffffffff24444444444444444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ee6666666666666666666666666666666666666666666666666666eeee6666666666666666666666666666666666666666666666666666ee0000000000000000
e555555555555555555555555555555555555555555555555555556ee555555555555555555555555555555555555555555555555555556e0000000000000000
05511111111111111111111111111111111111111111111111111556055222222222222222222222222222222222222222222222222225560000000000000000
05166111661666666111666616666661116661116666611661166156052222222666622266666266666266666222666226666662222222560000000000000000
05166111661666666116666616666661166666116666661661166156052222222666662266666266666266666222666226666662222222560000000000000000
05166111661226622166622212266221666266616622661661166156052222222661666266111266111266111226666621166112222222560000000000000000
05166616661116611166211111166111662126616611661661166156052222222662166266222266222266222226616622266222222222560000000000000000
05126616621116611166111111166111661116616666661266662156052222222662266266662266662266662226626622266222222222560000000000000000
05116616611116611166111111166111661116616666621166661156052222222662266266662266662266662226626622266222222222560000000000000000
05116616611116611166111111166111661116616626661126621156052222222662266266112266112266112266666662266222222222560000000000000000
05116666611116611166611111166111666166616612661116611156052222222662666266222266222266222266666662266222222222560000000000000000
05112666211666666126666611166111266666216611661116611156052222222666661266666266222266666266111662266222222222560000000000000000
05111666111666666112666611166111126662116611661116611156052222222666612266666266222266666266222662266222222222560000000000000000
05511222111222222111222211122111112221112211221112211556055222222111122211111211222211111211222112211222222225560000000000000000
e055555555555555555555555555555555555555555555555555555ee055555555555555555555555555555555555555555555555555555e0000000000000000
ee0000000000000000000000000000000000000000000000000000eeee0000000000000000000000000000000000000000000000000000ee0000000000000000
cc6666666666666666666666666666666666666666666666666666666666666666666666666666cccccccccccccccccc00000000000000000000000000000000
c555555555555555555555555555555555555555555555555555555555555555555555555555556ce82cccccccccc28e00000000000000000000000000000000
055111111111111111111111111111111111111111111111111111111111111111111111111115568cccccccccccccc800000000000000000000000000000000
051111666616666611116661116666616666111666661666661666661661116611666616666611562cccccccccccccc200000000000000000000000000000000
05111666661666666111666111666661666661166666166666166666166111661666661666661156cccccccccccccccc00000000000000000000000000000000
051166622216622661166666116622216626661662221662221662221666116616622216622211562cccccccccccccc200000000000000000000000000000000
051166211116611661166266116611116612661661111661111661111666616616611116611111568cccccccccccccc800000000000000000000000000000000
05116611111666666116616611666611661166166661166661166661166666661666611666611156e82cccccccccc28e00000000000000000000000000000000
05116611111666662116616611666611661166166661166661166661166666661266661666611156000000000000000000000000000000000000000000000000
05116611111662666166666661662211661166166221166221166221166266661122661662211156000000000000000000000000000000000000000000000000
05116661111661266166666661661111661666166111166111166111166126661111661661111156000000000000000000000000000000000000000000000000
05112666661661166166222661661111666662166666166111166666166112661666661666661156000000000000000000000000000000000000000000000000
05111266661661166166111661661111666621166666166111166666166111661666621666661156000000000000000000000000000000000000000000000000
05511122221221122122111221221111222211122222122111122222122111221222211222221556000000000000000000000000000000000000000000000000
c055555555555555555555555555555555555555555555555555555555555555555555555555555c000000000000000000000000000000000000000000000000
cc0000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000004040404040404040400000000000000040404040404040404040404000000000000000004040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000202100000000000000008182838485868788000000000000000041424344454647480000000000000000010203040506070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000008c8cbbbbbb8c8c8c8c8c8c8c8c8c8c8c8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c8c8c8c8c8c8c8c8c8c8cb8b8b88c8c8d81abab8d8d8d8d8d8d8d8d9b9b818d8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c00
0000000000000000000000000000008c81808080818181818181818181818c8d8989898a818181818181818181818d8c81818181818181818181808080818c8d81808081818181818181818080818d8c81818181818181818181818181818c8d81818181818181818181818181818d8c81818181818181818889898a81818c00
0000000000000000000000000000008c81808080818181818181818181818cb8808080b2b38f81818181818181818d8c8181818181818181818180a780818c8d81808081818181818181818080818d8c81818181818181818181818181818c8d8989898f898989898989898a81818d8c81818181818188b0b18080b2b3818c00
0000000000000000000000000000008c818080808181818188898f898a818cb8b680808080b2b38a8181818181818d8c81818181818181818181808080818c8d81808085818181818181848080818d98b2b38a8f8181818181818f88b0b19bb880808080808080808080b9928f818d8c8181818188b0b19a808099808080b800
0000000000000000000000000000008c81808080818181b0b180b9b992818c8d80808080808080928181818181818d8c81818181818181818181808080818c8d818080958a8181818188948080818d98b680b2b3898989898989b0b180809bb8b680808080808080808080b985818d8c81818fb0b18080808f83808080b7b800
0000000000000000000000000000008c818080808181848080808080b9818c8da0a18080808080998181818181818d8c81818181818181818181808080818c8d81808080928a81818893808080818d988080808099808080809a808080809b8d818181818f8181818fa4808095818d8c81b0b18080808080928f808080828c00
0000000000000000000000000000008c81808080858f94808080808080818c8d818183a9828183808181818181818d8c81818181818181818181808080818c8d818080808eb2b3b0b18e808080818d8ca0a1808099808080809a8080a2a38c8d8188b0b180b2b38a81b4808080818d8c84bb8080808080aa8080a9a2a3818c00
0000000000000000000000000000008c818080809593808080808080808f8c8d81818180818f81808181818181818d8c8181818181818181818f8080808f8c8d8180aa80808080808080809a80818d8c8181818fb0b38a8f8181818181818c8d8193bd808080bc928181808080818d8cb48080808ea2a3818181818181818c00
0000000000000000000000000000008c81808080808080808080808080818c8d81818180928993808581818181818d8c81818181818181818181808080818c8d8f80aa80808080808080809a808f8d8c81818893a980b2b38a81818181818c8d81bd8080808080bc81818080808f8d8c8183808080b2b38a8181818181818c00
0000000000000000000000000000008c81808080808080808080808080818c8d818181a480808080958a818181818d8c81818181818181818181808080818c8d819980808080808080808080a9818d8c818893a980808080928a818181818c8d8f8080a296a18080818fa48080818d8c818fa480808080b2b38a818181818c00
0000000000000000000000000000008c818080808080808082a4808080818c8d818181b4aa80808080928f8181818d8c81818181818181818181808080818c8d818099808ea2a3a0a18e80a980818d8c889380808080808080928f8181818c8d818080818f8180808581b48080818d8c8181b48080809c808092818181818c00
0000000000000000000000000000008c81ba8080808080a58fb4808080818c8d818181818380809a8080b2b38a818d8c81818181818181818181808080818c8d81808080828181818183808080818d8c93808080a581a0a180aab2b38a818c8d81808085818180808781818080818d8c818181a4808080808080858f81818c00
0000000000000000000000000000008c81a4ba80808080b58181808080818c8d818181818f83809a80808080b2b38d8c818181818f8181818181808080818c8d818080a5818181818181a48080818d8c80808080b58f818183aa8080b2b38c8d84808087818480808781818080818d8c81818f86acaca2a18080958181818c00
0000000000000000000000000000008c81b480ba808082818181808080818c8d8181818181818380808080808080abba808080808080808080808080b9818c8d818080b5818181818181b48080818da8b680808281818181818380808080ab8d948080878f868080958f938080818d8c8181819480a58f81a480808581818c00
0000000000000000000000000000008c81818380a2a381818181808080818c8d81818181818181a0a18080808080abba8080808080808080808080b982818c8d81808081818181818181818080818da880808281818181818181a0a18080ab8dbf80beb581b4bbbb80808080ba818d8c8181848080b58181b480809581818c00
0000000000000000000000000000008c81818181818181818181808080818c8d818181818181818181a0a18080809bba80808080808080808080b98281818c8d81808081818181818181818080818da8a2a381818181818181818181a0a1ab8dbfa2a3818181a0a18080808082818d8c81819480a581818181a4808081818c00
0000000000000000000000000000008c8181818181818181818180a680818c8d81818181818181818181818f81818d8c818181818f8181818181818181818c8d8180a68181818181818181a680818d8c81818181818181818181818181818c8d81818181818181818181818181818d8c8184adadb581818181b49d9d81818c00
0000000000000000000000000000008c8c8c8c8c8c8c8c8c8c8cb8b8b88c8c8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8d8198988d8d8d8d8d8d8d8da8a8818d8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c00
8080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647484980808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
565758598080808080808080808080a296000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66676869808080808080808080a2a38181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7677787980808080808080808281818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4b4c4d80808080808080828181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a5b5ca2969696a180a2a3818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6a6b6c6d81818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7b7c7d81818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011400000c0430570005700057000c0430c0000c000057000c0430570005700057000c043057000c0000a7000c0430a7000a7000a7000c0430a7000c0000a7000c0430a70005700057000c043057000570000000
011400000c043057001c6151c6150c0430c0000c000057000c0430570005700057000c043057000c0000a7000c0430a7001c6151c6000c0431c6151c6150a7000c0431c615057001c6150c043057001c61500000
011400000c000057001c6151c6150c0000c0000c000057000c0000570005700057000c000057000c0000a7000c0000a7001c6151c6000c0001c6151c6150a7000c0001c615057001c6150c000057001c61500000
011400000c043057001c6151c6150c0430c0000c000057000c0430570005700057000c043057000c0000a7000c0430a7001c6101c6011c6001c6011c6101c6111c6011c600057001c6000c000057001c60000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000554005520055100554005520055150050002500025000250002500025000254002510055400551005540055200551005540055200551500500005000050000500005000050000540005100254002510
011400000554005520055100554005520055150254202522025120254202522025150254002510055400551005540055200551005540055200551500542005220051200542005220051500540005100254002510
011400000554005520055100554005520055150254200532025420251202542005320254202515055400552007540075220754005540055200551500542005220051200542005220051200542005120254002510
011400000554005520055100554005520055150254202522025120254202522025150254002510055400551005540055200551005540055200551500542005420053200522005220051500500005000250002500
011400000554005520055100554005520055150050002500025000250002500025000250002500055000550005540055200551005540055200551500500005000050000500005000050000500005000250002500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001d5401d5401d5401d5311d5211d5001a5401a5211a5001a5001a5401a5211a5021a5051d5401d5401f5521f5301f5521d5401d5201d52018550185301853018560185301853018560185301a5401a535
011400001d5401d5401d5301f5501f55022550245501a500025500055000510005501a5021a5051d5401d5401f5521f5301f5521d5401d5201d50000550005300255000550055300055007530005500a53000550
011400001d5401d5401d5401d5401d5201d5150050002500025000250002500025001a5401a5101d5401d5101d5401d5401d5401d5401d5201d51500500005000050000500005000050018540185101a5401a515
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000296632a6431f63318600126340e6320a63208622066220562202612026120261300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000037221372213722138221392213a2213a2423a2323a2323a2323a2223a2223a2223a2123a2123a2123a2123a2123a21200202002020020200202002020020200202002020020200202002020020200202
0002000000705137251d745197352270524705237051f7051e7050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
010300000070013720117302270018700187501775019750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400000000016750137400f72006710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000018530185551850018500185001855518500185551850018555185001f5501f5551f5001b5001c5501c5551b5001b50023550235552350030500305503055030552305523057030572305723057200500
000300001d5501d550185501655016550185501b5501d55017500185000e500005001b5501b5501655013550135501355016550185501a5000050000500005000050016550165501355011550115500f5500c550
0102000004601106110c611116010861106611086010660007600046000460019601176011560113601136011260111601116011160110601106010f6010f6010e6010e6010d6010c6010c6010b6010a6010a601
010200000020111771182611e2510824105231042210b2010a201082010e201112011020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
01020000006010461105611006010161103611006010261103611006010460005600006000160003600006000260003600006000160103601006010060101601006010660107601186012e6013f6010760100601
000200001c2331f23322223152231a2131e2031a2031c20318203132030d203082030020309203082030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
000200001b23321233292431f25321253192351322518205172051220517205152050000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000200000f3041c3141a3241c3341a3341b3041d3041e3041d3041930400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304003040030400304
00020000002041f3541a3441830418304143041330419304133040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204
000200000060105611076210863108631076210561105601046010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
000200002460109621076110561105601026010160100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
01060000005003a5723a5503a5503a5503a5323a5323a5353a5253a5253a515005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050009501
010200000e05512032130520a03300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000a03513052120320e053000000000000000000000a00013000120000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000017620136230a6132060321603226032360324603256032660327603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
010200001d6101f6130a6130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 41 08 43 44
00 00 08 43 44
00 01 08 43 44
00 01 08 43 44
00 01 09 43 44
00 01 0a 43 44
00 01 08 43 44
00 01 08 43 44
00 01 12 43 44
00 01 0a 43 44
00 01 10 43 44
00 01 08 43 44
00 01 02 03 04
00 02 02 03 04
00 02 08 43 44
00 02 08 43 44
00 01 10 43 44
00 01 11 43 44
00 01 09 43 44
00 01 08 43 44
00 02 0c 43 44
00 02 0c 43 44
00 02 0c 43 44
02 41 0c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
