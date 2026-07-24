pico-8 cartridge // http://www.pico-8.com
version 15
__lua__


--spaceman splorf:planet of doom
--by roy fielding (pond software)

local function contains(table, val)
    for asi=1,#table do
        if table[asi] == val then
            return true
        end
        return false

    end
end

function _init()

    textcols={1,2,8,14,10,15,7,15,10,14,2,1}
    for p = 0,15 do
        pal(p,0)
    end
    firstrun = 1
    hightoday = 10000  -- hehe the leftmost digit is not actually used :p

    _vars_init()
    music(38)

    cartdata("splorfhi")
    highscore = dget(0)

    if highscore == 0 then highscore = 10250  end  -- first digit ignored
    -- should only need to change
    -- if there's no save file,
    -- meaning highscore was 0.
    -- we want the lowest highscore
    -- to start at 2500.

    debug = false
end

function _vars_init()

    spanner = {}
    spanner.s = 1
    spanner.f = 235
    spanner.w = 0
    add(spanner,hs)
    dospanner = 0
    noggins = {}
    hoffer = 0
    hwait = 0
    tm=0
    epal={7,12,11,3,1}  --splorf explosion palette
    e={}  --explosions
    fdelay = 0
    stars={}
    pframe = 2
    pxmax = 12
    dy = 0
    dystep = 0.055
    dystep2 = 0.125
    gamemode = 0
    gtype = 0
    thrust = 0
    ttype = 0
    logo_y_offset = 0
    logos_x = 4
    logos_y = 128
    dologos = false
    stexty = 128
    lastp = 0
    tswapdelay = 0
    tswapnum = 0
    rdelay = 0

    pondtimer = 90
    pup = true
    pfidx = 0
    pdelay = 0
    dofade = 1
    dead = 0
    didx = 1
    ddelay = 0

    tx = 0
    i = 0
    mx = 0
    mx2 = 0
    score = 10000
    scdelay = 0
    ti = 1
    pulsedelay = 0
    s_limit=1200
    px = -16 py = 52
    starsmax = 80
    z_scount=0
    r=0
    m=0
    dcycle = 0
    fc={1,5,6,7}
    zoomstars={}

    stars_colour={1, 1, 5, 6, 7, 13, 12}

    asteroid_list = {}
    asteroid_bounds =    {}

    asteroid_x_table={}
    asteroid_y_table={}
    asteroid_speed={}

    asteroid_reflist={128+6,128+8,128+10,128+12,128+14,128+32,128+34}
    asteroid_x_reftable={140,250,440,500,200,370,300}
    asteroid_y_reftable={13,30,45,62,77,91,106}
    asteroid_refspeed={1.2,1.5,1.3,1.75,2,1.4,1.9,1.1}

    abounds_list = {}

    -- asteroids collision bounds in segments to get accurate collision. --
    abounds1 = {
        {8,3,12,12},
        {6,4,14,11},
        {4,5,15,9},
        {15,6,16,8},
        {1,10,9,13},
        {2,8,8,14},
        {3,14,6,15}
    }

    abounds2 = {
        {6,6,9,10},
        {7,5,12,9},
        {9,4,11,6},
        {11,6,13,8},
    }

    abounds3 = {
        {4,5,13,11},
        {5,4,13,12},
        {6,3,12,5},
        {12,6,14,12},
        {9,12,11,14},
        {8,11,13,13}
    }

    abounds4 = {
        {5,6,9,12},
        {4,7,11,11},
        {3,9,12,10},
        {6,5,13,9},
        {11,4,12,6},
        {12,5,14,8},
        {13,6,15,7}
    }

    abounds5 = {
        {7,5,13,9},
        {5,6,14,9},
        {4,7,11,11},
        {3,9,12,10},
        {6,11,9,12},
        {13,7,15,8}
    }

    abounds6 = {
        {3,4,8,7},
        {4,5,11,9},
        {5,7,14,10},
        {11,6,13,14},
        {9,11,11,13},
        {14,8,15,9},
        {6,10,8,12}
    }

    abounds7 = {
        {8,4,10,14},
        {8,4,13,11},
        {6,5,14,9},
        {5,6,12,12},
        {4,8,6,11},
        {6,11,11,13}
    }

    abounds_reflist = {abounds1, abounds2, abounds3, abounds4, abounds5, abounds6, abounds7}

    -- ############################################
    --(pn) testing certain random situations
    --     by forcing random number generation
    --     to always start with the same seed
    --srand(0)
    -- ############################################

    asl={}  --list
    asti ={}
    ass_size=6  --list size -- how many active asteroids?
    ass_max=7  --range - we have 7 types and 7 locations on screen to init
    while (#asl<ass_size and #asl<ass_max) do
        local asn= 1 + flr(rnd(ass_max))
        for asti in all(asl) do
            if (asn==asti) asn=nil break
        end
        if (asn!=nil) add(asl,asn)
    end
    aidx = 1
    --for asti in all(asl) do print(asti) end
    abidx = 1

    --(pn) removed local declaration
    asteroid_bounds_reflist =    {01,02,16,15,
        06,03,14,10,
        03,02,14,14,
        03,03,15,12,
        04,04,16,12,
        03,03,15,14,
        04,03,15,14}

    -- (pn) need to have *all* the finer bounds available (especially as new asteroids get created)
    abounds_list = abounds_reflist
    -- (pn) likewise all the y-positions
    asteroid_y_table = asteroid_y_reftable

    -- generate initial asteroids
    for asti in all(asl) do
        asteroid_list[aidx] = asteroid_reflist[asti]

        -- used for finer bound check
        -- ##############################################
        -- (pn) do not randomise this - must be in sync
        --      with asteroid orig numbers for lookup
        -- ##############################################
        --abounds_list[aidx] = abounds_reflist[asti]

        -- ##############################################
        -- (pn) likewise, can't randomise all params
        --    the same way, or the asteroids will still
        --      show in orig (unrandom) order?
        --
        -- (this combination seems to work well, but
        --  if showing <7 asteroids, the "spaces" will
        --  always be at the bottom - i tried other
        --  combinations, but they resulted in either
        --  non-rnd asteroid order or position)
        -- ##############################################
        asteroid_x_table[aidx] = asteroid_x_reftable[asti]

        asteroid_speed[aidx] = asteroid_refspeed[asti]

        aidx +=1

        for bi= 1,4 do
            -- asteroid rough bounds to check whether a higher res collision search is needed --

            asteroid_bounds[abidx] = asteroid_bounds_reflist[((asti*4)-4)+(bi)]


            abidx +=1
        end

    end


    -- player rough bounds to check whether a higher res collision search is needed --
    playerbounds={3,1,13,15,
        3,2,13,15}

    -- player collision bounds in segments, used to get accurate collision. --

    -- floating player
    pbounds1 = {
        {8,2,12,12},
        {7,3,13,7},
        {6,4,9,15},
        {4,11,13,12},
        {4,7,6,9},
        {5,10,7,15},
        {9,13,10,14}
    }

    -- thrusting player
    pbounds2 = {
        {7,4,13,9},
        {8,3,12,13},
        {6,5,10,15},
        {4,12,13,13},
        {4,8,6,10},
        {5,11,6,16},
        {7,14,8,16}
    }

    infotext = {
        "                                ",  --1
        "     pond software presents     ",  --2
        "                                ",  --3
        " spaceman splorf:planet of doom ",  --4
        "                                ",  --5
        "            a pico-8            ",  --6
        "version of a casual game for the",  --7
        "      commodore 64 computer.    ",  --8
        "                                ",  --9
        "                                ",  --10
        "   original c64 game coded by   ",  --11
        "       andreas gustafsson       ",  --12
        "                                ",  --13
        "    with gfx and music/sfx by   ",  --14
        "           vanja utne           ",  --15
        "                                ",  --16
        "            . . . . .           ",  --17
        "                                ",  --18
        "this is the first pico-8 game by",  --19
        "      roy fielding of pond      ",  --20
        "                                ",  --21
        " with music lovingly created by ",  --22
        "                                ",  --23
        " chris donnelly / gruber music  ",  --24
        "        (@gruber_music)         ",  --25
        "                                ",  --26
        "            . . . . .           ",  --27
        "                                ",  --28
        "shout outs to my fellow pondies:",  --29
        "                                ",  --30
        "       andreas gustafsson       ",  --31
        "        anthony  stiller        ",  --32
        "        craig derbyshire        ",  --33
        "          graham axten          ",  --34
        "        tom roger skauen        ",  --35
        "           vanja utne           ",  --36
        "          stefan  vogt          ",  --37
        "                                ",  --38
        "                                ",  --39
        "            . . . . .           ",  --40
        "                                ",  --41
        "   a special mention to these   ",  --42
        " wonderful pico-8 fans who have ",  --43
        "helped with their support and/or",  --44
        "         code snippets.         ",  --45
        "                                ",  --46
        "   paul nicholas (@liquidream)  ",  --47
        "     neil mcewan (@neil1637)    ",  --48
        "    justin ray (@designinvan)   ",  --49
        "           urban monk           ",  --50
        " denny pahlke(@beautifulpanda_) ",  --51
        "         @egordorichev          ",  --52
        " morgan mcguire(@casualeffects) ",  --53
        "    dylan bennett  (@mboffin)   ",  --54
        "                                ",  --55
        "            . . . . .           ",  --56
        "                                ",  --57
        "    last, but not least....     ",  --58
        "                                ",  --59
        "  greetings and best wishes to  ",  --60
        "                                ",  --61
        "                                ",  --62
        "   paul green, antonio savona,  ",  --63
        " roger bacon, eric nelson, wiz,  ",  --64
        "  jason aldred, @s0phieh, rgcd  ",  --65
        "  mike berry, martin linklater  ",  --66
        "   jose guerra, kevin tilley,   ",  --67
        "nicole marie t(@musicvsartstuff)",  --68
        " gabriel crowe, freakin frankie,",  --69
        " paul k (@zynubi), matt hughson ",  --70
        "   del seymour, rob caporetto,  ",  --71
        " kate lorimer and all you other ",  --73
        "  lovelies that i can't recall. ",  --73
        "                                ",  --74
        "            . . . . .           ",  --75
        "                                ",  --76
        "   you are splorf, space corp   ",  --77
        " sanitation engineer 5th class, ",  --78
        "lavatorial division. a small yet",  --79
        "   vital cog in the corporate   ",  --80
        "machine. another 20 years spent ",  --81
        "   fixing toilets in the lower  ",  --82
        " levels of methane station, and ",  --83
        "you could possibly have made 4th",  --84
        "         class engineer.        ",  --85
        "                                ",  --86
        "that all changed today, when you",  --87
        " were volunteered for a mission ",  --88
        "  to repair the disintegration  ",  --89
        "    fence above planet doom!    ",  --90
        "                                ",  --91
        "   working quickly to fix the   ",  --92
        "damaged shield generator, before",  --93
        "  evil space pirates steal the  ",  --94
        "precious gas resources from the ",  --95
        " planet below, you suddenly see ",  --96
        "   your company issued spanner  ",  --97
        "drifting off towards the planet.",  --98
        "                                ",  --99
        "   misplacing company property  ",  --100
        " would result in your pay being ",  --101
        "docked, or being sent to work in",  --102
        "the splort mines! not a tempting",  --103
        "            prospect.           ",  --104
        "                                ",  --105
        "     using your jetpack you     ",  --106
        " desperately follow the spanner ",  --107
        "   into a particularly pungent  ",  --108
        "  gasteroid field - just as the ",  --109
        "      now fully operational     ",  --110
        " disintegration fence above you ",  --111
        "     turns itself back on...    ",  --112
        "                                ",  --113
        "                                ",  --114
        "            . . . . .           ",  --115
        "                                ",  --116
        "  let's make 2018 a great year. ",  --117
        "                                ",  --118
        "            be  kind.           ",  --119
        "                                ",  --120
        "       #splorfallthethings      ",  --121
        "                                ",  --122
        "                                ",  --123
        "                                ",  --124
        "                                ",  --125
        "                                ",  --126
        "                                ",  --127
        "                                ",  --128
        "                                ",  --129
        "                                ",  --130
        "                                ",  --131
        "                                "  --132
    }

    infocols =
    {06,12,06,07,09,09,09,09,
        06,06,06,11,06,06,11,06,
        06,06,06,11,06,06,06,11,
        12,06,06,06,07,07,08,09,
        10,11,12,13,14,15,06,06,
        06,09,09,09,09,09,14,10,
        14,10,14,10,14,10,06,06,
        06,06,06,07,06,06,09,09,
        09,09,09,09,09,09,09,09,
        09,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06,
        06,06,06,06,06,06,06,06}

    local i

    -- horizontal stars generated here.
    for i = 1,starsmax do
        local hs = {}
        hs.x = rnd(128)
        hs.y = rnd(128)
        hs.sp= i/starsmax
        hs.col = rnd(#stars_colour)
        hs.col = stars_colour[flr(hs.col)]
        add(stars, hs)
    end

end

inftext1 =   "      roy fielding of pond      "
inftext2 =   "         aka  @pico8fan         "

function _textswapper()
    tswapdelay +=1
    if tswapdelay > 30 then
        tswapdelay = 0
        tswapnum +=1
        if tswapnum > 1 then tswapnum = 0 end
        if tswapnum == 0 then infotext[20] = inftext1 end
        if tswapnum == 1 then infotext[20] = inftext2 end
    end
end

function _rainbowcycle()
    local n = infocols[30]
    rdelay +=1
    if rdelay > 3 then
        for rbow = 30, 37 ,1 do
            infocols[rbow] = infocols[rbow+1]
        end
        infocols[37] = n
        rdelay = 0
    end
end

function rn(n)
    return flr(rnd(n))
end

function _make_expl(x,y,r)
    add(e,{
            x=x,
            y=y,
            r=r,  --radius
            f=0  --frame
        })
end

function _explode()  --update all
    for expl in all(e) do
        if #e > 12 then
            del(e,expl)
        end

        if expl.f <=2 then
            circfill(expl.x+(rn(expl.r/1.25)-expl.r/3),expl.y+(rn(expl.r)-expl.r/1.25),expl.r-1+rn(2),epal[1])
            expl.r -= 1
            circfill(expl.x+(rn(expl.r*2)-expl.r),expl.y+rn(expl.r*2)-expl.r,expl.r/2,epal[2])
            circfill(expl.x+(rn(expl.r*2)-expl.r),expl.y+rn(expl.r*2)-expl.r,expl.r/2,epal[3])
        elseif expl.f <8 then
            circfill(expl.x,expl.y,expl.r,epal[3])
            expl.r -= expl.r/3
            circfill(expl.x+(rn(expl.r*2)-expl.r),expl.y+rn(expl.r*3)-expl.r,expl.r/2,epal[3])
            circfill(expl.x+(rn(expl.r*2)-expl.r),expl.y+rn(expl.r*3)-expl.r,expl.r/2,epal[4])
        elseif expl.f < 14+expl.r then
            circfill(expl.x+(rn(expl.r*4)-expl.r*2),expl.y+rn(expl.r*4)-expl.r*2,expl.r/2,epal[4])
            expl.r -= expl.r/4
            circfill(expl.x+(rn(expl.r*4)-expl.r*2),expl.y+rn(expl.r*4)-expl.r*2,expl.r/2,epal[5])
        end

        expl.f+=1
        if expl.f >20 then   del(e,expl) end

    end
end

-- update! -----------------------------------------------
function _update()

    fdelay +=1
    if fdelay > 6 then tm+=1 fdelay = 0 end

    if gamemode == 0 then

        for zx=0,13,1 do
            new_zoomstar()
        end

        update_zoomstars()

    end

    if gamemode == 2 and dead == 0 then

        _controls()
        _gravity()

        py += dy

    end

    if gamemode == 1 then

        px = px +1
        if px >pxmax then
            px = pxmax
            gamemode = 2
        end
    end
end

-- draw ------------------------------------------------------
function _draw()

    cls(0)

    if gamemode > 0 then

        mx += 01
        mx2 += 2

        if mx >895 then mx = 0 end
        if mx2 >895 then mx2 = 0 end

        tx += 1

        if tx < 0 then tx = 0 end

        _stars_draw()
        pal(10,0)
        map(0,0,0-mx,-8,256,16)
        map(0,16,0-mx2,120,256,1)



        for i=1,ass_max do  --#asteroid_list+1 do
            a = asteroid_list[i]
            -- do we have an asteroid in this lane?
            if (a == nil) then
                -- no asteroid, must be empty lane, skip to next one
                goto continue
            end



            spr(a,flr(asteroid_x_table[i]),flr(asteroid_y_table[i]),2,2)

            -- (pn) suggest moving all the "moving/collision" code below to the _update() section

            asteroid_x_table[i] = asteroid_x_table[i] - asteroid_speed[i]

            if asteroid_x_table[i] < -16 then

                asteroid_x_table[i] = 150+rnd(180)
                newybool = flr(rnd(2))

                    -- (pn) randomly find an unused y-lane
                    local asternum = nil
                    while asternum == nil do
                        asternum = 1+flr(rnd(7))

                        if (asteroid_list[asternum]==nil) then
                            break
                        else
                            asternum = nil
                        end
                    end

                    -- (pn) now switch to new position

                    -- (pn) pick the correct asteroid sprite for the sprite number (to keep in sync with bounds)
                    asteroid_list[asternum] = asteroid_reflist[i]

                    asteroid_x_table[asternum] = 150+rnd(180)
                    asteroid_speed[asternum] = asteroid_speed[i]
                    asl[asternum] = i

                    -- move the finer bounds position to match
                    asteroid_bounds[((asternum*4)-4)+1] = asteroid_bounds_reflist[((i*4)-4)+1]
                    asteroid_bounds[((asternum*4)-4)+2] = asteroid_bounds_reflist[((i*4)-4)+2]
                    asteroid_bounds[((asternum*4)-4)+3] = asteroid_bounds_reflist[((i*4)-4)+3]
                    asteroid_bounds[((asternum*4)-4)+4] = asteroid_bounds_reflist[((i*4)-4)+4]

                    -- (pn) ...and make old lane empty
                    asteroid_list[i] = nil
                    asl[i] = nil



            end


            print(score, -4,3,5)
            print("0",16,3,5)
            print(score, -4,2, 7)
            print("0",16,2,7)

            scdelay = scdelay + 1

            if scdelay > 30 then
                if gamemode == 2 and dead == 0 then score += 1 end
                scdelay = 0
            end

            -- (pn) allow us to skip drawing "empty" lanes
            ::continue::

        end

        if py < 13 and dead == 0 then  godelay = 20 dead = 1 dcycle = 0 sfx(62,3) _highcheck() end  --sfx(2)
        if py > 105 and dead == 0 then  godelay = 20 dead = 2 dcycle = 0 sfx(63,3) _highcheck() end  --sfx(2)

        if dead != 0 then deathevent(dead, godelay)  end
    end

    if dospanner == 1 then do_spanner() end

    if gamemode != 0 then
        _pdraw()  //draw any particles

        pal()
    end

    if dead == 0 then spr((130+(thrust*2)),px,py,2,2) end

    _check_player_collision()

end

function _finer_collide_test(incoming_ast, incoming_plyr, ai)
    local ty = 30

    for ptests in all(incoming_plyr) do
        for tests in all(incoming_ast) do
            x1 = flr(px + ptests[1])
            y1 = flr(py + ptests[2])
            w1 = ptests[3] - ptests[1]
            h1 = ptests[4] - ptests[2]

            x2 = (tests[1])
            x2 = x2 + (asteroid_x_table[ai])
            y2 = (tests[2])
            y2 = y2 + (asteroid_y_table[ai])
            w2 = tests[3] - tests[1]
            h2 = tests[4] - tests[2]

            -- show the finer collision bounds
            if (debug) then
                rect(flr(x1),flr(y1),flr(x1+w1),flr(y1+h1),3)
                rect(flr(x2),flr(y2),flr(x2+w2),flr(y2+h2),2)
            end

            checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)

            if (x1 < x2+w2 and
                x2 < x1+w1 and
                y1 < y2+h2 and
                y2 < y1+h1) == true then

                -- (pn) debug testing collisions by stopping
                if (debug) and dead == 0 then
                    rect(flr(x1),flr(y1),flr(x1+w1),flr(y1+h1),11)
                    rect(flr(x2),flr(y2),flr(x2+w2),flr(y2+h2),8)
                --stop()
                end

                if dead !=3 then

                    if score > highscore then
                        spanner.x = flr(140+rnd(30))
                        spanner.y = py+2
                        dospanner = 1
                    end

                    _make_head(px+5, py+1, 104,4,6,2+rnd(4), flr(rnd(2)))
                    _make_head(px+2, py+5, 120,4,8,2.5+rnd(4),flr(rnd(2)))
                    _make_head(px+1, py+7, 164,4,7,1.75+rnd(2),flr(rnd(2)))
                    _make_head(px+4, py+8, 180,4,5,rnd(3),flr(rnd(2)))
                    _make_head(px+1, py+8, 168,2,2+rnd(4),rnd(8),flr(rnd(2)))
                    _make_head(px+1, py+8, 168,2,2.5+rnd(5),rnd(7),flr(rnd(2)))
                end
                dead = 3 sfx(60,3) godelay = 30 _highcheck()
                _make_expl(rn(16)+(px+2),rn(16)+py+2,rn(4)+5)  -- make splorf explode

            end
            ty += 8
        end
    end

end

function _check_player_collision()

    colliders={}

    local c
    local an = 1
    for c = 1, (#asteroid_x_table * 4) ,4 do
        local ac = {}

        ac.xa = (asteroid_bounds[c])
        ac.xa = ac.xa + (asteroid_x_table[an])

        ac.ya = (asteroid_bounds[c+1])
        ac.ya = ac.ya + (asteroid_y_table[an])

        ac.xb = (asteroid_bounds[c+2])
        ac.xb = ac.xb + (asteroid_x_table[an])

        ac.yb = (asteroid_bounds[c+3])
        ac.yb = ac.yb + (asteroid_y_table[an])

        an += 1
        add(colliders, ac)

    end

    local plyr_bounds_list = {pbounds1, pbounds2}
    local x1,y1,w1,h1,x2,y2,w2,h2
    local astcount = 1

    for ac in all(colliders) do

        if thrust == 0 then
            x1 = flr(px + playerbounds[1])
            y1 = flr(py + playerbounds[2])
            w1 = flr((px + playerbounds[3]) - x1)
            h1 = flr((py + playerbounds[4]) - y1)
        end

        if thrust == 1 then
            x1 = flr(px + playerbounds[5])
            y1 = flr(py + playerbounds[6])
            w1 = flr((px + playerbounds[7]) - x1)
            h1 = flr((py + playerbounds[8]) - y1)
        end

        x2 = flr(ac.xa)
        y2 = flr(ac.ya)
        w2 = flr(ac.xb - ac.xa)
        h2 = flr(ac.yb - ac.ya)

        checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)

        if (debug) and dead == 0 then
            rect(flr(ac.xa),flr(ac.ya),flr(ac.xb),flr(ac.yb),8+ac.xa/38)
            if thrust == 1 then
                rect(flr(px + playerbounds[5]),flr(py + playerbounds[6]),flr(px + playerbounds[7]),flr(py + playerbounds[8]),11)
            end
            if thrust == 0 then
                rect(flr(px + playerbounds[1]),flr(py + playerbounds[2]),flr(px + playerbounds[3]),flr(py +  playerbounds[4]),11)
            end

            -- (pn) force to always show/test finer collision
            -- if debug then
            --     _finer_collide_test(abounds_list[(asl[astcount])],plyr_bounds_list[(thrust+1)], astcount)
            -- end
        end

        if (x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1) == true then

            if dead == 0 then
                _finer_collide_test(abounds_list[(asl[astcount])],plyr_bounds_list[(thrust+1)], astcount)
            end
        end

        astcount +=1

    end

// front end
    palt()

    if gamemode == 0 and firstrun == 0 then

        for s in all(zoomstars) do
            pset(s.x+64,s.y+64,s.c)
        end

        _titlescreen(ttype)

        if (btnp(5)) and ttype == 0 then
            if lastp == 0 then gamemode = 1 music(19) end
        else lastp = 0
        end
        if (btn(4)) and ttype == 0 then ttype = 1  stexty = 128 logo_y_offset = 0 logos_y = 128 sfx(59) end

        if (btn(0)) then gtype = 0  hwait = 0 end
        if (btn(1)) then gtype = 1  hwait = 0 end

        hwait +=1
        if hwait > 120 then
            hwait = 0
            if gtype == 0 then gtype = 1
            else
                gtype = 0
            end
        end

    else

        if gamemode == 0 then

            spr(10,40,50,6,2)
            spr(42,40,66,6,1)

            rampforc01 = {00,00,01,01,01,01,01,01,01,01,01,01,01}
            rampforc03 = {00,00,01,05,03,03,03,03,03,03,03,03,03}
            rampforc05 = {00,00,01,01,05,05,05,05,05,05,05,05,05}
            rampforc06 = {00,00,01,01,05,13,13,12,06,06,06,06,06}
            rampforc07 = {00,00,01,01,05,05,13,13,12,06,06,07,07}
            rampforc11 = {00,00,01,05,03,11,11,11,11,11,11,11,11}
            rampforc12 = {00,00,01,01,05,13,12,12,12,12,12,12,12}
            rampforc13 = {00,00,01,01,05,13,13,13,13,13,13,13,13}

            pdelay += 1
            if pdelay > 1 then
                pondfade()
                pdelay = 0
            end
            pondtimer -= 1
            if pondtimer == 0 then firstrun = 0 pondtimer = 80 pal()   music(0) end
        end

    end

    if debug then
        print (stat(1), 0, 20, 9)
    end
end

function _titlescreen(tt)

    local tc

    if tt == 0 then
        _drawlogo(0)
        _showhighs()

        -- press (x) to start
        print("press — to start",31,86,5)
        print("press — to start",31,87,7)

        -- press (o) for info
        print("press Ž for info",31,101,5)
        print("press Ž for info",31,102,7)

        clip()
        print("(c) pond software 2017",21,121,1)

        print("(c) pond software 2017",21,120,6)
        clip(0,121,128,6)
        print("(c) pond software 2017",21,120,11)
        clip(0,122,128,6)
        print("(c) pond software 2017",21,120,12)
        clip()

    end

    if tt == 1 then
        _drawlogo(logo_y_offset)
        _drawtext(infotext, 0, stexty, 1)
        _textswapper()
        _rainbowcycle()

        _showhighs()

        if stexty < -977 and dologos == false then dologos = true  stexty = flr(stexty) end

        if (dologos) then
            -- commodore c64 logo
            spr(63,logos_x, flr(logos_y), 1,1)
            spr(175,logos_x+8, flr(logos_y), 1,2)
            spr(79,logos_x, flr(logos_y+8), 1,2)
            spr(207,logos_x+8, flr(logos_y+16), 1,1)
            spr(239,logos_x+16, flr(logos_y+8), 1,3)

            -- philips logo
            spr(80,logos_x+27, flr(logos_y), 3,1)
            spr(83,logos_x+27, flr(logos_y+8), 3,1)
            spr(58,logos_x+27, flr(logos_y+16), 3,1)

            -- atari logo
            spr(172,logos_x+56, flr(logos_y), 3,2)
            spr(224,logos_x+56, flr(logos_y+16), 3,1)

            -- pico8 logo
            spr(209,logos_x+85, flr(logos_y+7), 3,1)
            spr(213,logos_x+85+24, flr(logos_y+7), 1,1)
            spr(214,logos_x+85+30, flr(logos_y+6), 1,1)

            logos_y -= 0.33

        end

        hoffer = 0.25 + (hoffer * 1.2)

        logo_y_offset -= 0.25
        stexty -= 0.333

        if (btn(5)) then ttype = 0 lastp = 1 sfx(59) hoffer = 0 logos_y = 128 dologos = false stexty = 128 end

    end

end

function _drawlogo(logo_y)
    spr(1,32,logo_y+8,4,4)
    spr(5,64,logo_y+8,4,4)
    spr(65,32,logo_y+42,8,1)
end

function _highcheck()

    if score > hightoday then hightoday = score end
    if score > highscore then highscore = score dset(0,highscore) end

end

function _drawtext(lines, textx, texty, colour)

    --print(flr(texty),0,16,7)
    ci = 1
    for textline in all(lines) do

        if texty > -10 and texty < 138 then
            print(textline, textx+1, flr(texty+1), colour)
            print(textline, textx, flr(texty), infocols[ci])
        end

        texty += 9
        ci +=1
    end
    if texty < 32 then ttype = 0 hoffer = 0 ti = 1 logos_y = 128 dologos  = false stexty = 128 logo_y_offset = 0  end

end

function _showhighs()

    pal()
    pulsedelay = pulsedelay + 1
    if pulsedelay > 2 then
        ti = ti + 1
        pulsedelay = 0
    end
    if ti >= #textcols then ti = 1 end
    tc = textcols[ti]

    if gtype == 0 then

        hs = tostr(highscore).."0"
        s = 'highest score : '..sub(hs,2)
        print (s , 22+hoffer,65,tc)
    else
        hs = tostr(hightoday).."0"
        s = 'highest today : '..sub(hs,2)
        print (s , 22+hoffer,65,tc)

    end

end

-- collision detection function;
-- returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return  x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end

-- / pond logo ----------------------------------------------------------------
function pondfade()

    if dofade > 0 then
        pal(1,rampforc01[pfidx])
        pal(3,rampforc03[pfidx])
        pal(5,rampforc05[pfidx])
        pal(6,rampforc06[pfidx])
        pal(7,rampforc07[pfidx])
        pal(11,rampforc11[pfidx])
        pal(12,rampforc12[pfidx])
        pal(13,rampforc13[pfidx])

        if (pup) then
            pfidx += 1
            if pfidx == #rampforc01 then dofade = 0 end
        else
            pfidx -= 1
            if pfidx < 0 then pfidx = 0 dofade = 0 end
        end
    end
    if pondtimer < 40 then dofade = 1 pup = false end
end

-- //- death events  -----------------------------------------------------------

function deathevent(deadtype)

    deathshock = { 96,98, 96, 98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96,98,96}
    deathacid = { 102,100,102,100,102,100,102,
        100,102,100,102,100,102,102,100,102,100,102,102,100,102,100,102,102,100,102,100,102,102}

    if godelay < 1 then
        spr(73,52,56,3,2)  -- game over sprites
    else
        godelay -=1
    end

    if deadtype == 1 then
        spr(deathshock[didx],px,py,2,2)

        ddelay += 1
        if ddelay >2 then didx += 1  ddelay = 0  end
        if didx > #deathshock then didx = 1 dcycle += 1 end
    end

    if deadtype == 2 then
        spr(deathacid[didx],px,py,2,2)
        palt(11,1)
        map(0,16,0-(mx/.5),120,256,1)
        palt(11,0)

        ddelay += 1
        if ddelay >2 then didx += 1  ddelay = 0  py = py + 0.5 px = px -1 end
        if didx > #deathacid then didx = 1 dcycle += 1 end
    end

    if deadtype == 3 then

        fdelay +=1

        _explode()  -- update all explosions
        _decapitation()

        ddelay += 1
        if ddelay >3 then didx += 1  ddelay = 0  end
        if didx > #deathacid then didx = 1 dcycle += 1 end
    end

    if dcycle >= 1 then dcycle = 0 _clearparticles()  sfx(-1,0) sfx(-1,1) sfx(-1,2) sfx(-1,3) music() music(0) _vars_init() end

end

function _make_head(hx,hy,hframe,hframecnt, hrangex, hvy,xdir)
    h={}
    h.x = (hx)
    h.y = (hy)
    h.dx = 0.5+(rnd(hrangex)/9)
    h.dy = -rnd(hvy)
    h.spr = hframe
    h.frame = 0
    h.t = 0
    h.gravity = 0.15
    h.frames=hframecnt

    if xdir == 1 then h.dx = -h.dx end

    add(noggins,h)

    return h
end

function _decapitation()
    for hs in all(noggins) do
        spr(hs.spr+hs.frame,hs.x,hs.y,1,1)
        hs.t = hs.t + 1
        if hs.t > 2 then hs.t = 0 hs.frame +=1 end
        if hs.frame > hs.frames-1 then hs.frame = 0 end
        hs.x = hs.x + hs.dx
        hs.y = hs.y + hs.dy
        hs.dy = hs.dy + h.gravity
    end
end

-- horizontal stars ---------------------------

function _stars_draw()
    for hs in all(stars) do
        pset((hs.x - 3*tx*hs.sp) % 128, hs.y, hs.col)
    end
end

function _controls()

    thrust = 0

    if (btn(5)) then
        dy -= dystep2
        thrust = 1
        sfx(0)

    end

//-- gravity stuff
    function _gravity()

   //gravity

        if dy >= 3 then
            dy = 3
        else
            dy += dystep

        end

        if dy < -2 then
            dy = -2
        end
    end

end

-->8
function new_zoomstar()
    if(z_scount>=s_limit)then
        return
    end
    local s={}
    s.z=0.666
    s.a=rnd(1)
    s.d=rnd(320)+3
    s.x=cos(s.a)*s.d
    s.y=sin(s.a)*s.d
    s.xs=0
    s.ys=0
    s.s=0
    s.c=7
    z_scount+=1
    add(zoomstars,s)
end

function update_zoomstars()
    r=(r+0.002)%16
    m=(m+0.63)%2
    for s in all(zoomstars) do
        s.z+=s.z*0.06
        s.s+=0.16
        s.c=fc[min(flr(s.s),5)]
        s.xs+=cos(m)*0.005
        s.ys+=sin(m)*0.005
        s.x=((cos(s.a+sin(r)*0.5)+s.xs)*s.d)*s.z
        s.y=((sin(s.a+sin(r)*0.5)+s.ys)*s.d)*s.z
        if(s.z>11)then
            del(zoomstars,s)
            z_scount-=1
        end
    end
end

function do_spanner()
    spr(spanner.f, spanner.x, spanner.y,1,1)

    spanner.x -= spanner.s
    spanner.w+=1

    if spanner.w > 3 then
        spanner.w = 0
        spanner.f-=1
        if spanner.f < 232 then spanner.f = 235 end
    end

end

-- We don't want any of you
-- around these here parts,
-- be off with you,
-- you pesky Secret Squirrel!

-->8
-- fast particle system
-- by morgan mcguire @casualeffects
-- http://casual-effects.com
-- released as bsd-license open source february 2017.
// thanks morgan, this code was very useful!

plx = 0

function add_particle(x, y, dx, dy, life, color, ddy)
    particle_array_length += 1

    -- grow if needed
    if (#particle_array < particle_array_length) add(particle_array, 0)

    -- insert into the next available spot
    particle_array[particle_array_length] = {x = x, y = y, dx = dx, dy = dy, life = life or 8, color = color or 6, ddy = ddy or 0.125}
end

function _clearparticles()
    for part in all(emitter_array) do
        del(part, emitter_array)
    end
    particle_array_length = 0
end

function process_particles()
    -- @casualeffects particle system
    -- http://casual-effects.com

    -- simulate particles during rendering for efficiency
    local p = 1
    while p <= particle_array_length do
        local particle = particle_array[p]

        -- the bitwise expression will have the high (negative) bit set
        -- if either coordinate is negative or greater than 127, or life < 0
        if bor(band(0x8000, particle.life), band(bor(particle.x, particle.y), 0xff80)) != 0 then

            -- delete dead particles efficiently. pico8 doesn't support
            -- table.setn, so we have to maintain an explicit length variable
            particle_array[p], particle_array[particle_array_length] = particle_array[particle_array_length], nil
            particle_array_length -= 1

        else

            -- draw the particle by directly manipulating the
            -- correct nibble on the screen
            local addr = bor(0x6000, bor(shr(particle.x, 1), shl(band(particle.y, 0xffff), 6)))
            local pixel_pair = peek(addr)
            if band(particle.x, 1) == 1 then
                -- even x; we're writing to the high bits
                pixel_pair = bor(band(pixel_pair, 0x0f), shl(particle.color, 6))
            else
                -- odd x; we're writing to the low bits
                pixel_pair = bor(band(pixel_pair, 0xf0), particle.color)
            end
            poke(addr, pixel_pair)

            -- acceleration
            particle.dy += particle.ddy

            -- advance state
            particle.x += particle.dx
            particle.y += particle.dy
            particle.life -= 1

            p += 1
        end  -- if alive
    end  -- while
end

------------------------------------------------------------------
-- stuff below here is modified/butchered

particle_array, particle_array_length = {}, 0

emitter_array = {
    { count = 2, x = 30, y = 20, dx = -1.2, rnd_dx = 0.9, dy = 0.1, rnd_dy = 0.07, life = 15, rnd_life = 20, color = 11 },

    { count = 8, x = 18, y = 122, dx = -1.2, rnd_dx = 2, dy = -1.7, rnd_dy = 0.366, life = 9, rnd_life = 12, color = 19},
}

function _pdraw()
    palt(0, false)

    process_particles()

    -- create new particles
    for emitter in all(emitter_array) do
        -- print (emitter.count,8,20+ (emitter.count *8),7)
        for i = 1, emitter.count do
            if thrust > 0 and dead == 0 then
                if emitter.count == 2 then
                    add_particle(px + 5 + rnd(emitter.rnd_x or 0), py + (dy*2) +  8 + rnd(emitter.rnd_y or 0),
                        emitter.dx + rnd(emitter.rnd_dx), emitter.dy + rnd(emitter.rnd_dy),
                        emitter.life + rnd(emitter.rnd_life), emitter.color, emitter.ddy)
                end

            end

            local pymax = (py+16)
            local pxmax = (px+4 + rnd(6) + rnd(emitter.rnd_x or 0))
            if pymax >127 then pymax = 127 end
            if pxmax <0 then pxmax = 0 end

            if emitter.count == 8 and dead == 2 and px > -10 then

                add_particle(pxmax, pymax + rnd(emitter.rnd_y or 0),
                    emitter.dx + rnd(emitter.rnd_dx), emitter.dy + rnd(emitter.rnd_dy),
                    emitter.life + rnd(emitter.rnd_life), emitter.color, emitter.ddy)
            end

        end
    end

end
__gfx__
000000000000000166650d66660006d00001d610d7600dd00d50006d10006100d100000000000000000000000000000000000000000000000000000000000000
0000000000000017d5d6067d57701761001676507600067106600067d0007d007500000000000000000000000000000000000000000000000000000000000000
000000000000006710000d700570577500d751006d00067606700067610076106d00000000000000000000000000000000000000000000000000000000000000
00000000000000d750000d600d60d66d006d00006d000d66d6610066dd0067d16d00000000000000017777777777777777777777777777777777777777777610
000000000000000d7d000561d60061560075000066d00d656d65006d0610d66dd60000000000000017d111111111111111111111111111111111111111111671
00000000000000000dd0056d500560d60065000161000dd0d0d6006606d0d60656000000000000007d167777777777777777777777777777777777777777616d
000000000000000000dd0560000d6dd6506d100560000d6000560566dd605605dd100000000000007167d116d1111677777777777777777777777777d11d7616
00000000000000d6006d0d600006d00dd006d10560050d600016056501650d10d6100000000000006177176166dd101777777777777777777777777717617716
000000000000001dd6d10dd000060005d0056601dd6605d00006116000dd0d500650000000000000617716dd1100d11d77777777777777777777777716d17716
00000000000000000000000000000000000000000000000000000000000000000000000000000000617716d1166101017777777777777777777777771611771d
000000000000033310000013333310000133c2000000000000000000000003d31000000000000000d1771d1177770001d6d11d77d117d11d7777d11d1d117716
000000000003b666b2003b366bb333200366b32000000013630366bc31003666bbb3310000000000d177110077770001d766d11617617761176166d11101771d
00000000003b6b3bb320b66bbbbbb3120b6bb320000000266db6bbbbb321d6b6b66bbb2000000000d1771100166100016610010116dd11661d17d11001017715
0000000000b6b31cb12036b3333cbb0203bbc1211d6d211d6bbbd3b3bc31bbbbbbbb6bb1000000005166110000000016d11610001d101d1d116101610001661d
00000000036b3103b020b6630221cb120b6b30236666d202bbc323123b32bbb33cb3bbb200000000d17711010000011d117771001101771111d1177710017705
00000000036b3200221036b302003b02136c02d6cb3cbc256b321201cb3236b113123b3200000000506611011111151101666100110166110110166610016601
0000000003b6bb3000002b630201bb020bb302b6b1023b25bb3201013b323bb02000132100000000103310013333331100131000110133110110013100013305
00000000003b6bb3100013b3323bb02116b021bbb1005b356bd20012b3111bb1211000500000000050bb1001bbbbbbb1000000011001bb10011000000001bb01
0000000000033cbb31000b6bbbbb02102bc020b6b2003b32bbb3013b310213bbbbb310100000000010cc1001cccccccc1000001c1001cc1001c10000c101cc01
000000000000133bb3310bbbb33123003b3020cbb2003b323bbb3cb3102103bbc33120b30000000010bb1111bbbbbbbbc11111cb1111bb1111bc1111b111bb01
00000000000000136b321b63112205003b02103b6c33bb32bb3bb315221001bb102200320000000010cc1111cccccccc1111111c1111cc1111c111111111cc01
00000000000000003bb323b302010201bb020023bbbbb3023b53b321000002b30210001100000000101311113333333111111111111133111111111111113101
000000000036621006b30bb202000001b30200033bbb3020bb52bb32000001db1120000000000000010000000000000000000000000000000000000000000010
0000000000b6b12016b103b2030000033302100023c002103b123bb310000036302000b300000000001111111111111111111111111111111111111111111100
00000000003b6b336b300bb102000003b3013b3211322100bb52136b3100003bb1120032000000000ccc6776667776cccccc76cc000000000000000000000000
000000000013bbbbb30026b00500001bbb36b66b312100003b121036bb30003bb3020011000000000ccc6767776ccccc7ccc76cc000000000000000000000000
000000000001233330021b3021000013bbbbb3b3b32100003b310013b6b1002bb3020000000000000cccc7dcccccccc777c76ccc000000000000000000000000
0000000000001222222103021000002b3b3b3233310200003b3210023b32001210200000000000000cccc67dcccccccc7c67dccc00000000000000000000001c
000000000000000000000131000000123213212200210000532100002312000122000000000000000ccccc67dccccc7cc67dcccc000000000000000000001ccc
000000000000000000000010000000012012000132100000121000000220000000000000000000000cccccc677cccccc77dccccc00000000000000000001cccc
000000000000000000000010000000000001000020000000010000000000000000000000000000000cccccccd67777776dcccccc0000000000000000000ccccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccddddccccccccc000000000000000000cccccc
000000000d6500d00005d000dd000d6d0d6d0000000000000000dd0005d0005d000dd5d077777077777077007707777701152ddd211111100000000001ccccc0
00000000077f507000577f0d77f0d77f067f500006d0006d000d77f0577f0577f0d77ffd76000076007076777707600015ddddd222112251000000000ccccc00
00000000090920900049090490904900005e4000d9090d9000049090d9090d909049595e7607707777707607070777702ddd5222111aaa2d000000001cccc100
000000000e4200e0004e4e04e0e04e40000e4000421404e40004e0e04e0e04e0e04e0e047600707600707600070760002d5522111aaa121200000000ccccc000
000000000e200045104e0402e0402e00000e2000042004200002e54024540245402404047777707600707600070777772222111aaa12112100000000ccccc000
0000000004200024202402024020244200042000000000000005442002420024202202020000000000000000000000001211aaaaa1a1121200000000ccccc000
0000000000000000000000000000000000000000000000000000000000000000000000007777707600707777770777701aa111111111111100000000ccccc000
00000000000000000000000000000000000000000000000000000000000000000000000076007076007076000007600715ddd5222211a11a000000001cccc100
0ccccccccccccccccccccccc0ccc77776cccccccc67776cc0000000000000000000000007600707600707777700777705dd22221111aaa11111111000ccccc00
0cccd7777777777777777dcc0ccc777ccc7ccccccd6776cc0000000000000000000000007600700760707600000760071222111a1aa12dddd221221001ccccc0
0ccc777777777777777776cc0ccc776c7cccccccccd676cc00000000000000000000000077777000777077777707600711111aaaaa12122d2211121100cccccc
0ccc76c6c6cc6c6ccc6c76cc0ccc77c777cccc67776c76cc00000000000000000000000000000000000000000000000012dd5211a1a11121111a111a001ccccc
0ccc7cdc6cc6d6dcccc676cc0ccc76cc7ccd6777667776cc0000000000000000000000000000000000000000000000001dd2211aaa1a1a121aa1d2210001cccc
0ccc7c6cc6c6cc6c6c7c76cc0ccc776ccc6776cccccc76cc00000000000000000000000000000000000000000000000011221aaaa121aaaaa1a1121100001ccc
0ccc777777777777777776cc0ccc76d77776cc67777676cc000000000000000000000000000000000000000000000000a111111a12d21a11111aa1110000001c
0ccc7777766cccc6777776cc0ccc76cccccc677ccccc76cc00000000000000000000000000000000000000000000000015d22211a1211112221a1a1a00000000
0000000d00000000000000c00c00000000000000000000000000000000000000005d671003155d0001511300015d65105ddd222aa1111aaaa11aa1a100000000
0000d0067760d0000000c00cccc0c00000000005d671000000000005d67100000d500161003305d0151305031610005122d22221a1ddd2111a11111100000000
00000d7d11160000000000c76ddc00c0000000d500161000000000d500161000d506301536b53055506bbb3171062b151222211a12dd2221a1dd211a00000000
000006d16611d00000c00c76555dc00000000d506301500000000d50630150005063630d10b2330d6025253560bb5b3111111aaa11221211a222221100000000
000007167760dd000000cc65555dcdc000000506bbb0d00000000506bbb0d0005352520613b5b306d03b3305d0332b011d211d21a111111aa121211100000000
00d017171710d00000001cd5757dc0000000053b5b5060000000053b5b50600013bbbb0551b230175103305d55035b5322221221aa1a1aaa1a1a111a00000000
0006d6167760500000c0ccc55555c0000002410bbbb05000000d110bbbb051003050315115000161161005d00d503300a111111aa1111111a111a1aa00000000
000d15d1ddd50100000c76dc5c5c0c000004253533150000000d651533150610003115100156d5100176d50000d551301dd211a1aa1d211aaa1a121100000000
00016776656d500000c6dcc5c5ccc0000001d66ddd5110000001d6dddd516d00000000000000000000000000000000002222211aa11221a1a1a1aa1a00000000
0056dd7666d5dd5000cdc0dcddcd5cc000166d566d5d5000000015d66ddd500000000000000000000000500000000000221111aaaa11111a12d21aa100000000
000d0066ddd00501000c00cddcdc0c00001d10566d116500000001566dd1000000242000000000000002120000244200111aaaa1a12211aaa221111100000000
0000016ddd10010000000cddddc0000000000056dd101d0000000056dd500000004240000024420000042400051224002211111a12111a1a111111a100000000
000006d01dd000000000cdc0cdc000000000016d161000000000016d161000000042400000422150000424000024420012122221a111a2a11a1a1a1a00000000
00006d00016d1000000ccc000cdc0000000016d01d000000000016d01d1000000021200000244200000242000000000011122211a1a11a11a111aaaa00000000
00001000005000000000c000c0c0000000001d01d100000000001d00dd00000000050000000000000000000000000000a1a1111aaa1aa11aaa1aa1a100000000
000000000000000000000000000000000000000050000000000000005100000000000000000000000000000000000000111a11a1aaa1a111a1aa1aa100000000
00000000005d67100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d50016100000005d6710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d5063015000000d50016100000000005d671000000000005ddd5000000000000000000000000015d66d1000000000000000000000000000000000000
000770005063b30d00000d5063015000000000d500161000000005d666d65100000000001110000000001d766d7d100000000000001100000000000000000000
000770005352520600000506bbb0d00000000d50630150000001d6666ddd551000000015d6d100000001d766dd5550000000011001d66500000000566d551000
0070070013bbbb050000053b5b50600000000506bbb0d000000566d5dddddd51000001d66d551000000d666d5555510000001d66665d6d1000001d66d56dd500
00000000305031510002410bbbb050000000053b5b50600000056656ddd5dd5100000566dd675000000d66d555d555000001666d65d5dd100001d6656ddd5d10
000000000031151000042535331500000002410bbbb050000156d66ddd555551000006d5d55550000006d5dd5d6d55000006ddd6dd56d500000d6d56dd555510
000000000000000000021d6ddd50000000042535331500000d66665dd5d55510000005d5551100000006d556d5d55500001d5d5d5555100000165d6d55555100
00000000000000000000d6566d55000000021d6ddd50000056ddddddd555d5000000015510000000000d55dd555d5500001d5555dd510000001d55d5d5510000
0000000000000000000061566d5650000000d6566d550000d66d5d55555d510000000000000000000001555d55d555000001d155551000000001d55555100000
000000000000000000015056d515100000006156dd5650006ddd5555555100000000000000000000000010155d55510000001111100000000000011110000000
0000000000000000000000d61d000000000150d65d1510005dd55555100000000000000000000000000000015555100000000000000000000000000000000000
000000000000000000001d61dd000000000015655d000000155d5511000000000000000000000000000000001110000000000000000000000000000000000000
0000000000000000000015015000000000001d15d100000000155100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888888888888888888800000000
0000000000000000000000000000000000001000000000000000100000000000000000000000000000000000000000008888888887e77e788888888800000000
000000000000000000000000000000000001d100000110000001d10000d10000000150000001100000000000000000008888888887e77e788888888800000000
005d55110000000000000005666d5000000d6000001d6100000561000056d10000167500001dd10000000000000000008888888887e77e7888888888cccccc00
006776ddd5100000000005667dd6d500001610000001d6500006d00000016d10001d51000057610000000000000000008888888887e77e7888888888cccccc00
0056d55667dd100000005676d5676d000015000000000110001d10000000010000011000000d500000000000011110008888888887e77e7888888888cccccc00
001566dd5566d100000066ddd5d6d50000000000000000000001000000000000000000000000000000000000122d21008888888887e77e7888888888cccccc00
00015566d55ddd100005d56d5d6d5500000000000000000000000000000000000000000000000000000000012ddd221088888888e7e77e7e8888888800000100
00015d556d55d5100006d6556dd55100000000000000000000000000000000000000000000000000000000144ed2d22088888888f7e77e7f88888888000000cc
000015dd55515100000d5d5dd55d500000016d1001d5000000001510011000000000000000000000000001224d244211888888887787787788888888000000cc
0000015d5d51000000015555d5551000000576d00d6d100000016d1005d10000000000000000000000011112222d2d218888888f7e8778e7f8888888000000cc
00000015d5d510000000155d5d55000000056d50067661000016d100016d55100000000000000000001211222dd22221888888e7f887788f7e88888800000011
00000000155551000000015555500000001d61000155d61005d65000001667600000000000000000012d2115de4d221188888e77e887788e77e8888800000000
0000000000111000000000055500000001d6100000001d500d6750000001d6d000000000000000000124212de4d2d21a888ef77e88877888e77fe88800000000
00000000000000000000000000000000015100000000011001d6100000005d100000000000000000001211a5d552222a88877e888887788888e7788800000088
00000000000000000000000000000000000000000000000000000000000000000000000000000000001225251aaa121188888888888888888888888800000088
15151515151515151515151515151515cccccccccccccccc52cccccccccccacc00000122100000000012d251aaa1a12a000000000012d2100000000000000088
3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bdddddddddddddddd214dddddddddd54d000002e420000000012d421aa1aa111100000000002ded210000000000000022
bbb3bbbbbbb3bbbbb3b3bbb3bbb3bbbb22222222222222221122222222222122000012422000000002d2d21a1a11112100000000014e42d10000000010000100
3b3b3b3b3b3b6b3b333b3b3b3b3b3b3b1111111111111111a111111111111a1100001122100000000124d21aa11212110000000001242d2110000000cccccc00
333b3333b3d3b3333b33b333d3bfb333aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0011a1122110000002dd221a11212221000000000a12d114d2100000cccccc00
33b6b3b333333333bfb333b3333b3b33111111111111111111111111111111110012122421d200000142d2251112121100000000012d422e2d210000cccccc00
333b333333b33b3d3b33333333b3bdb3aaa1a1aa000000000000000000000000012421222122100002d2225dd211ddd10000000012122212d1210000cccccc00
33333d333333b7b33333353333333b3311111aa1000000000000000000000000012211121a11100011222d511d222d2210000000a11121a1121a100000000000
11111111000000000000000000000000152121aa0000000000800000000000000a222a11dd21a00a122251aaaa222d21a1d4d10a12a11dd2111d210000000000
cdcdcdcd0000000000000000000000002d2211a100000000097f0000000000000112d21d42121aa1d222daaaa11dd2111d4d221a2d21d421aad4d21000000000
6c6c6c6c0000000000000000000000002cd221a100000000a777e00000000000112d221221aa1a1d2222da1a111d212aa2d2521ad221221aa1ad212000000000
777777770777707777007770077770002cd221a1007777000b7d000000000000a22121121aa111a5211221a111221aaa1a2521211211211a1212221100000000
c6c6c6c67707700770077000770770002cd221a10070070000c000000000000012d21a112122121222a122111121aa12a2121a1a21a112112121a12100000000
dcdcdcdc7777700770077000770770772cd221a1077777000000000000000000122121a112222122211a12212121a1211121a111121a1122111a111100000000
111111117700000770077000770770001d211aaa077007000000000000000000a12a1a221121221212a1a21122111a11a1a2aa1aa1a22112a1a121a100000000
000000007700007777077770777700005ccd21a1077777000000000000000000121a111121111111111111111a11a1111a11a111a11112111aaa1a1a00000000
888888888888888888888888000000002cd221a100000000000000000000000000000000000000000000000000000000000000000000000001222210cccccc00
888e7887778e788777e87888000000002cd221a1000000000000010000000000000d0d00000000d00000000000d00000000000000000000015d115d1ccccc000
888f7788788f778788787888000000002cd221a10000000000000120000000000005d5000000050000000000000500000000000000000000125ddd21cccc0000
8887e7887887e78788787888000000002cd221a10000000000000010000000000000d00000000d5d0dd0005d0d5d000000000000000000001222221111100000
88e787e878e787e77f887888000000002cd221a10000000000000011000000200000d0000000d000005dddd00000d00000000000000000001121212100000000
88f777f878f777f787e878880000000015211aaa0000000000000001000001000000d0000d5d00000dd0005d00000d5d00000000000000001222121100000000
8878887e7e7888f788787888000000002cd221a1000000000000000210000100000d5d000005000000000000000005000000000000000000a121111a88800000
888888888888888888888888000000002cd221a1000000100000000110000020000d0d0000d0000000000000000000d000000000000000001112111188880000
00000000000000002cd221a1001000002cd221a1000001500000500100100510000000000000000000000000000000001222211222122221a121111a88888000
00000000000000002cd221a1000110002cd221a1000012000000102100200110000000005000000000000000000000002d11d22d152251d21a1211a122222200
00000000000000002cd221a1000211002cd221a10001210000010021012101000000000020000000000011000010000022dd2122dd5dd521a111111a00000000
00000000000000002cd221a10500211115211aaa00012100000210110010010000000000110000000001200000210000122221122222212aaa1211a100000000
00000000000000002cd221a10150215dcccd2d2551a0525000012110001001200050000002100000000100000002100012121a1222121211a1a11a1a00000000
000000000000000015211aaa0020115dcdd2121a11a012a0000a1115011501a0001000000110001200021000000210001121aa112111111a1a1111aa00000000
00000000000000002cd221a1001a212ddd2121aaa1a121100001a11111111110002100001100012000021000051a101111111aa2221211a1aaa11a1a00000000
00000000000000002cd221a10011111525111a1a11a11111011111111111111100111000110001110001110011a110a11121aa112111111a1a1111aa00000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5f90000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006d6e0000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000c7c7c4c6c5c6c7c5c4c5c6c700000000000000000000000000000000000000000000000000000000000000f6000000000000000000000000000000000000005c6ef80000f9fa000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000ab00000000000000000000000000d40000000000d4000000000000000000000000000000000000000000000000000000000000000000004c4dfa00000000000000000000000000000000006d4c5e00004c6e000000000000000000000000000000000000
00000000000000000000000000000000000000000000ab00000000babb00000000000000000000000000e40000000000e40000000000d40000000000000000e7ee0000000000e70000000000000000000000005c5d5e000000f90000000000e700f9eefa0000005c6ceef9005c4d5e0000000000000000000000000000000000
0000000000e60000000000000000e6e700000000fababbf500c8c9cacb00cdce0000000000d400000000e40000000000e4000000e6e7e40000004c6de6e700eefcfd0000eee6f7fa4c4df8f90000e6f9f8e6e76c6d6e00e7005d5e000000e6f7eeeefcfde6f9e76c6d6e5ee66c6deee70000000000e60000000000000000e6e7
f9f70000f9f6f7f600f7f8f9faf5f6f7f8f9fafbd8dbdcd8c9d8d9dadbdcdddefaf5cdcef3f4fb00f9f7f4fbf9f6f7f6f4f7f7f9f6f7f4f7f5fb6c6df7fcfdfefefefcfdfeeefcfd5c5d5ef7faf5f6f7f7f5f57c7d7ef9f7f96d6ef9faf5fcfdfefefefeeef7f67c7d7eeef77c7d7ef7f9f70000f9f6f7f600f7f8f9faf5f6f7
c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c3c0c1c0c1c0c1c2c3c0c1c2c3c0c1c2c3c0c1c0c1c2c3c0c1c2c3c0c1c2c3c0c1c0c1c2c3c0c1c2c3c0c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c3c0c0c1c2c3c0c1c2c3c0c1c0c1c2c3c0c1c2c3c0c1c2c0c1c2c3c0c1c2c3c0c1c2c3c0c0c1c2c3c0c1c2c3c0c1c2c3c0c1c2c3
0102030405060708000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112131415161718000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122232425262728000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132333435363738000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4142434445464748000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000256102561026610206102961028610216101f61023610286102961028610206101d6101d61021610236101e6101e6101e6101e6101e6101e6101e6101e6101e6101f6101e6101b6101b6101d6101d610
01030000246253c6053c605286051e60512605306050e60523605136050f6051e605236050160520605096051d6051960508605066050b6050b6050d60507605116050e6050a6050660508605096050860501605
010100020c1500c1501010022100281000e100191002a10017100161002910018100181002a10026100201000a1001c100281001d100371002110020100281001c10007100091000810014100241000c10027100
010100020c7700c7701010022100281000e100191002a10017100161002910018100181002a10026100201000a1001c100281001d100371002110020100281001c10007100091000810014100241000c10027100
010800001a7001a7001a7021a7021c7001d7001f7002170024500247022470223700217001f7001c7001a70018700187001870018700187001850218702187021670014700127051270412705000000000000000
01080000000001c7001c7021c7021d7001f70023700247002670026502267022470023700217001f7001c7001a7001a7001a7001a7001a5001a7021a5021a7021870017700157051570415705000000000000000
01080000000000000024700247022670028700297002b7002d7002d7022d5022b7002970028700267002470021700217002170021500217002170221702215021f7001d7001c7051c7041c705000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300003c047300273c00730007370472b027370072b007390472d027390072d0073a0072e0073a0472e0273c047300273c00730007370472b047370372b037370272b027370172b017180071b007180071b007
011300003a0072e0073a0472e0073a0072e0073a0472e02735007290073504729027370472b027370072b0073a0072e0073a0472e007000070000700007000070c4220c2120c4320c2320c4320c2220c4220c212
01130000390072d007390072d047000000000000000000000000000000000000000000000000000000000000390072d007390072d047000000000000000000000c2320c2150c2301823018222182121821218215
011300000074000730007200073024610007300072000730007400073000720007302461000730007200073000740007300072000730246100073000720007300074000730007200073024610007300072000730
011300200c043279353393527935183230000033935279353393500000339352793518323000003393527935339353f9353393527935183230d95533935279353393500000339352793518323000003393527935
011300000074000730007200073000740007300072000730007400073000720007300074000730007200073000740007300072000730007400073000720007300074000730007200073000740007300072000730
011300003a0072e9353a0462e9353a0072e0073a0472e02735007290073504729027370472b027370072b0073a9352e9353a0462e935000070000700007000070c4220c2120c4321823118222182121821218215
011300003c047300273c93530007370472b027379052b905390472d027390072d0073a0072e0073a0472e0273c047300273c93530007370472b047370372b037370272b027370172b0170c4120c2220c4120c222
01130020390032d007390072d047183231830333935279353393500000339352793518323000003393527935390032d007390072d047183230d93533935279353393500000339352793518323000003393527935
011300000c00300700007000070024600007000070000700007000070000700007002460000700007000070000700007000070000700246000070000700007000070000700007000070024600007000070000700
0113000030047240273004724047370472b027370472b0473c047300273c04730047370072b007370472b0273a0472e0273a0472e02735000290003504729027390472d027390002d000370472b037370272b017
011300003000030000300003000030000300003000030000300003000030000300003a0472e0003a0002e0002e0002e0002e0002e000390472d935399352d935350002900035047290272b0002b0002b0002b000
011300200c0432793533935279351832300000339352793533935000003393527935393032d047399352d935339353f9353393527935370002b047370002b0003393500000339352793518323000003393527935
011300002223022210212302122021212214121f2301d2301b2301a2301823018210182301822018412184122223022210212302123021422214121f2301d2301b2301b2301b2201b2201b4101b2101b2121b412
011300002223022210212302122021212214121f2301d2301b2301a2301823018210182301842018212184121b2301b2101d2301d4201d2121d4121b2301a2301823018230184201822018410182121841218412
0113000011a4011a4011a3011a302461011a2011a1011a100ca400ca400ca300ca30246100ca20246100ca1011a4011a4011a3011a302461011a200aa400aa400ca400ca400ca300ca30246100ca200ca1024610
0113000011a4011a4011a3011a302461011a2011a1011a100ca400ca400ca300ca30246100ca20246100ca100fa400fa200fa400fa40246100fa200aa400aa200ca400ca400ca300ca30246100ca200ca1024610
0113000005b5005b5005b4005b4005b3005b3005b2005b2000b5000b5000b4000b4000b3000b3000b2000b2005b5005b5005b4005b4005b3005b3000b5000b5000b5000b5000b4000b4000b3000b3000b2000b20
0113000005b5005b5005b4005b4005b3005b3005b2005b2000b5000b5000b4000b4000b3000b3000b2000b2003b5003b3003b5003b4003b3003b200ab500ab3000b5000b5000b4000b4000b3000b3000b2000b20
011300200c04327935339352793518323370153393527935339353701533935279351832337015183232793533935279353393527935183230d95533935279353393537015339352793518323370153393518323
011300000c2100c2100c2100c2200c2200c2201323013230132301323013220132201321013212132121341212230122301223012230122201222012220122201221012210122101221012212122121241212412
011300000cb100cb200cb300cb400cb500cb600cb700cb700cb700cb700cb700cb700cb700cb700cb700cb7006a7006a7006a6006a6006a5006a5006a4006a4006a3006a3006a2006a2006a1006a1006a1006a10
011300000c2100c2100c2100c2200c2200c2201323013230132301323013222132221822018220182201841012230122301223012230122201222012220122201221012210122101221012212122121242212432
011300000ca700ca500ca300ca100ca700ca500ca300ca100ca700ca500ca300ca1008a7008a400fa700fa400ca700ca500ca300ca100ca700ca500ca300ca100ca700ca500ca300ca1008a7008a400fa700fa40
011300001323013220132101321513230132201321013215132301322013212132121223512235124351243513230132201321013215132301322013210132151323013220132121321212235122351243512435
01130000376002b601370272b016000000000024610186110023000220002100021008230082100f2300f210376002b601370272b016183230000000000000001832300000000000000018323000000000000000
01130000183330c2200c2100c2101833300b4000b2000b10183230000000000000001832318323183231832318323002200021000210002300022000210002100023000220002100021008230082100f2300f210
011300001f2201f2101f2101f21000000000000000037015186101861018610186101e2221e4121e2221e4121f2201f2101f2101f210000003701537015000001861018610186101861020222202122022220412
0113000037b1036b1135b1134b1133b1131b112fb112db112cb112ab1128b1126b1123b1121b111eb111db111bb111cb111eb1121b1123b1125b1127b1129b112bb112db112fb1131b1133b1134b1136b1136b15
0013000036b1035b1134b1133b1132b1130b112eb112cb112bb1129b1127b1125b1122b1120b111db111cb111ab111bb111db1120b1122b1124b1126b1128b112ab112cb112eb1130b1132b1133b1135b1135b15
01130000182101821018210182121a2101a2121b2101b2121721617210172102321617212172121721217215182102421618210182121a2101a2121b2161b2121e2101e2102a2161e2101e2121e2121e2151e202
01130000202101f2102b216202101f2101f2121b2101b2121e2102a2171e2102a2161e2101e2121e2121e21500000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0430000018940000000c0430000018940000000c0430000018940000000c0430000018940000000c0430000018940000000c0430000018940000000c0430000018940000000c043000001894000000
011000000ca400ca0018a3518a400ca400ca0018a400ca000aa400aa0016a4016a000aa400aa0016a400aa0008a4008a0014a3514a4008a4008a0014a4008a000aa400aa0016a4016a000aa400aa0016a400aa00
011000000c043000001894000000246150000018940000000c04300000189400c043246150000018940000000c0430c0031894000000246150000018940000000c0430c043189400000024615000001894000000
011000000ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a400ca450ca4018a3518a40
011000000aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a400aa450aa4016a3516a40
0110000008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a4008a4508a4014a3514a40
011000002423526245272352424524415304052224522416242452441524225222452e4153a2161f2452b40524235262452723524245244163041524245303352b245374152b2252924529415293152724533316
0110000029245294152922526245323053e216222452e4153a315224051f2452b415222452e4151f2453741627245273353340524245243353040526245263353242522245223352e4262624532425222452e426
01100000242453031529205262453230532216272452e4053a30533216292453531522205242452424530226242453030524235262453230532214272452731627245263152624522214222451f2361d24530205
011000001f0201f015270402703027030270202702227012260402603026022270402703027022240402404024040240302403024010240102401524000240000000000000180401803018020180101f0401f030
0110000024045300252b045370251f0452b0252c045380202c0402c0202b0402b04024030270402404024032370362b0161f0401f020220402202024040240202704024030270402702024040240201f0401f020
011000001f000130001f000130261f016130161f026130161f000130001f000130261f016130161f026130161f000130001f000130261f016130161f026130161f000130001f000130261f016130161f02613016
011000002400018000240001802624016180162402618016240001800024000180062402618016240161801624000180002400018006270261b016270161b016260261a016260161a01622026160162201616016
01100000260001a000260001a026260161a016260261a016260001a000260001a000260261a016260161a016260001a000260001a000290261d016290161d016270261b016270161b016260261a016260161a016
01100000220001600022000160262201616016220261601622000160002200016000220261601622016160161d000110001d000110001f026130161f016130162202616016220161601624026180162401618016
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001a7101a7101a5101a7101a7101a7101a5101a7101a7101a7101a5101a7151a7141a7151a7141a7151a7141a7151a7141a7151a7141a7151a7041a7050000000000000000000000000000000000000000
010c0000180001c7101c7101c5101c7101c5101c7101c5101c7101c5101c7101c5101c7141c7151c7141c7151c7141c7151c7141c7151c7141c7151c7041c7051800018000180001800018000180001800018000
010c00000000000000247102471024510247102471024710245102471024710247102451024715247142471524714247152471424715247142471524704247050000000000000000000000000000000000000000
01030000265602b560305600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000c160091610626103461326512c6412863125631216311f6311d6311c6311a631186311663114631146311362112621106210f6210d6210d6210c6210a62109621076110661106611056110461100001
00010000256102561026610206102961028610216101f61023610286102961028610206101d6101d61021610236101e6101e6101e6101e6101e6101e6101e6101e6101e6101f6101e6101b6101b6101d6101d610
01031c2018251196511805119651182511965118451193511835119251184511925118651197511825119751185511955118751192511805119351181511945118641194411863119431186210d0211821101411
00051c2032251376512a25133641222412e6411b2412564115241216410c2311d631092311963106231166310323112631022310e631012310a63100221086210022104621002210362100211026110021100611
__music__
01 08 09 0a 0d
00 0f 0e 10 0b
00 12 13 14 0b
00 12 13 14 0b
00 15 19 1b 17
00 16 1a 1b 18
00 1c 42 1b 1d
00 1e 42 1b 1d
00 20 22 21 1f
00 23 42 1b 1f
00 1c 42 1b 1d
00 1e 42 1b 1d
00 20 22 21 1f
00 23 42 1b 1f
00 24 25 1b 1f
00 24 25 1b 1f
00 26 42 1b 0b
00 27 42 1b 0b
02 27 42 43 0d
00 41 29 28 44
01 2e 2b 2a 44
00 2f 2c 2a 44
00 30 2d 2a 44
00 30 2c 2a 44
00 2e 2b 2a 44
00 2f 2c 2a 44
00 30 2d 2a 44
00 30 2c 2a 44
00 31 2b 2a 44
00 31 2c 2a 44
00 32 2d 2a 44
00 32 2c 2a 44
00 34 2b 2a 44
00 35 2c 2a 44
00 34 2d 2a 44
00 36 2c 2a 44
00 33 29 2a 44
02 33 29 28 44
04 38 39 3a 44
04 04 05 06 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
