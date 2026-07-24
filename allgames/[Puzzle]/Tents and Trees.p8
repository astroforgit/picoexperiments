pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- tents and trees
-- by frozax

-- sfx: gruber

-- try the original mobile game at https://www.frozax.com/tat

-- converts anything to string, even nested tables
-- https://www.lexaloffle.com/bbs/?pid=43636

function tostring(any)
  if (type(any)~="table") return tostr(any)
  local str = "{"
  for k,v in pairs(any) do
    if (str~="{") str=str..","
    str=str..tostring(k).."="..tostring(v)
  end
  return str.."}"
end



--
-- colors util.
--
-- https://github.com/nucleartide/pico-snippets/blob/master/colors.lua

colors = {
  black       = 0,
  dark_blue   = 1,
  dark_purple = 2,
  dark_green  = 3,
  brown       = 4,
  dark_gray   = 5,
  light_gray  = 6,
  white       = 7,
  red         = 8,
  orange      = 9,
  yellow      = 10,
  green       = 11,
  blue        = 12,
  indigo      = 13,
  pink        = 14,
  peach       = 15,
}


buttons = {
  up = 2,
  down = 3,
  left = 0,
  right = 1,
  b1 = 4,
  b2 = 5,
}


-- https://www.lexaloffle.com/bbs/?tid=37015

vec2mt={
    __add=function(v1,v2)
        return vec2(v1.x+v2.x,v1.y+v2.y)
    end,
    __sub=function(v1,v2)
        return vec2(v1.x-v2.x,v1.y-v2.y)
    end,
    __unm=function(self)
        return vec2(-self.x,-self.y)
    end,
    __mul=function(s,v)
        return vec2(s*v.x,s*v.y)
    end,
    __len=function(self)
        return sqrt(self.x*self.x+self.y*self.y)
    end,
    __eq=function(v1,v2)
        return v1.x==v2.x and v1.y==v2.y
    end,
}
vec2mt.__index=vec2mt

function vec2(x,y)
    v = setmetatable({x=x,y=y},vec2mt)
    return v
end


function showfps(c)
    if c then
        color(c)
    end
    print("fps "..stat(7).." "..flr(stat(1)*100).."%")
end

function showpct(c)
    pct = flr(stat(1)*100)
    if pct > 100 then
        c = colors.red
    elseif pct > 80 then
        c = colors.orange
    elseif not c then
        c = colors.black
    end

    pct = tostr(pct)
    if #pct == 1 then pct = "0"..pct end
    palt(0, false)
    y = 121
    rectfill(0, y, 4*#pct, 6+y, 1)
    palt(0, true)
    print(pct, 1, y+1, c)
end

function create_menu(mis, shadow)

    menu = {}
    menu.items=mis
    menu.hspacing = 3
    menu.button_bg_col = 6
    menu.button_shadow_col = shadow
    menu.button_text_col = 0
    menu.selection = 1
    menu.item_border_x = 4
    menu.item_border_y = 2
    menu.item_height = 5 + 2 * menu.item_border_y

    max_text_width = 0
    for mi in all(menu.items) do
        max_text_width = max(max_text_width, #mi.text+5)
    end
    menu.item_width = max_text_width * 4 - 1 + 2 * menu.item_border_x

    function menu:draw(y)
        for i=1,#self.items do
            self:draw_item(y, self.items[i].text, self.selection==i)
            y += self.item_height + self.hspacing
        end
    end

    function menu:input()
        if btnp(buttons.down) then
            if self.selection < #self.items then
                self.selection += 1
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.up) then
            if self.selection > 1 then
                self.selection -= 1
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.b1) then
            sound_menu_valid()
            self.items[self.selection].click()
        end
    end

    function menu:draw_item(y, _text, selected)
        local text=_text
        local x = 64 - self.item_width * 0.5
        local y=y

        local shad_col = self.button_shadow_col
        local text_col = self.button_text_col
        local text_width = #text * 4 - 1
        if selected then
            x+=1
            y+=1
            shad_col = nil
                --text_col=9
            --end
            --text="\x8f "..text.." \x8f"
            --if (flr(time() * 5)) % 2 == 0 then
                text="\x8f "..text.." \x8f"
                text_width += 8*2+4*2
            --end
        end

        if shad_col then
            rectfill(x+1, y+1, x + self.item_width, y + self.item_height, shad_col)
        end
        rectfill(x, y, x + self.item_width - 1, y + self.item_height - 1, self.button_bg_col)
        c = 0
        --if selected then
        --        c = 9
        --        rect(x-1, y-1, x + self.item_width, y + self.item_height, c)
        --end
        text_height = 5
        print(text, x + (self.item_width - text_width)/2, y + (self.item_height - text_height)/2, text_col)
    end

    return menu
end


function blink(speed, c0, c1)
    ti = flr(time() * speed)
    if ti % 2 == 0 then
        return c0
    end
    return c1
end

-- code from democart
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 if (_w<12 or _h<12) return(false) -- min size
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end

function draw_win(_x,_y,_w,_h,_c1,_c2)
 rectfill(_x,_y,_x+_w,_y+_h,_c1)
 rect(_x,_y,_x+_w,_y+_h,_c2)
end

-------------------------------
-- string width with glyphs
function strwidth(str)
 local px=0
 for i=1,#str do
  px+=(ord(str,i)<128 and 4 or 8)
 end
 --remove px after last char
 return px-1
end
-------------------------------
-- get centered on screen width
function center_x(str)
 return 64 - strwidth(str)/2
end
-------------------------------
function printc(_str,_y,_c)
 where=center_x(_str)
 if (where<0) where=0
 print(_str,where,_y,_c)
end

-------------------------------
-- centered and outlined
function printco(_str,_y,_c,_co)
 where=center_x(_str)
 if (where<0) where=0
 printo(_str,where,_y,_c,_co)
end

-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end

function array_contains(__l, __item)
    for __litem in all(__l) do
        if __litem == __item then
            return true
        end
    end
    return false

end

anims = {}

anims.twoframe=0 --two frame anims
anims.threeframe=0
anims.fourframe=0
anims.fiveframe=0
anims.sixframe=0
anims.sevenframe=0
anims.eightframe=0
anims.maxdelay=4
anims.framedelay=anims.maxdelay-1

function anims:update()
    -- update state, check input
    self.framedelay-=1
    if (self.framedelay==0) then
        self.twoframe = (self.twoframe+1) % 2 --two frame anims
        self.threeframe = (self.threeframe+1) % 3 --two frame anims
        self.fourframe = (self.fourframe+1) % 4 -- four frame anims
        self.fiveframe = (self.fiveframe+1) % 5 -- five frame anims
        self.sixframe = (self.sixframe+1) % 6 -- six frame anims
        self.sevenframe = (self.sevenframe+1) % 7
        self.eightframe = (self.eightframe+1) % 8
        self.framedelay=self.maxdelay
    end
end

function create_anim(frames, flips_x, flips_y)
    if flips_x == nil then
        flips_x = {}
        for i=1,#frames do add(flips_x, false) end
    end
    if flips_y == nil then
        flips_y = {}
        for i=1,#frames do add(flips_y, false) end
    end
    if type(frames[1]) == "number" then
        -- if frame numbers, convert to rects
        new_frames = {}
        for i=1,#frames do
            x = (frames[i] % 16) * 8
            y = (frames[i] \ 16) * 8
            add(new_frames, {x=x, y=y, w=8, h=8})
        end
        frames = new_frames
    end

    anim = {frames=frames, flips_x=flips_x, flips_y=flips_y}

    function anim:update()
        mod = 1
        if #self.frames == 1 then
            mod = 0
        elseif #self.frames == 2 then
            mod = anims.twoframe
        elseif #self.frames == 3 then
            mod = anims.threeframe
        elseif #self.frames == 4 then
            mod = anims.fourframe
        elseif #self.frames == 5 then
            mod = anims.fiveframe
        elseif #self.frames == 6 then
            mod = anims.sixframe
        elseif #self.frames == 7 then
            mod = anims.sevenframe
        elseif #self.frames == 8 then
            mod = anims.eightframe
        else
            assert(false, "unhandled nb frames")
        end
        self.frame = self.frames[mod + 1]
        self.flip_x = self.flips_x[mod + 1]
        self.flip_y = self.flips_y[mod + 1]
    end

    function anim:draw(p)
        --printh(tostring(self))
        sspr(self.frame.x, self.frame.y, self.frame.w, self.frame.h, p.x, p.y, self.frame.w, self.frame.h, self.flip_x, self.flip_y)
    end

    return anim
end


particles = {}
particles.p = {}

function particles:start()
    self.p = {}
    for ip=1,800 do
        left_side = rnd(1) < 0.5
        vx = (rnd(2) + 1) * 1.5
        vy = -rnd(2) * 2 - 2
        if left_side then
            x = -rnd(5) - 2
        else
            x = 132
            vx = -vx
        end
        p = {x=x,y=rnd(30) + 90,
            vx=vx,vy=vy,
            size=flr(rnd(3))+1,
            age=-rnd(30),
            life=rnd(100)+100,
            col=rnd({7, 9, 2, 9, 2})
            --col=7
        }
        add(self.p, p)
    end
end

function particles:update()
    for p in all(self.p) do
        p.age += 1
        if p.age > 0 then
            p.x += p.vx
            p.y += p.vy
            p.vy+=0.05
        end
    end
end

function particles:draw()
    for p in all(self.p) do
        if p.age > 0 and p.y > -10 then -- p.age < p.life then
            circfill(p.x, p.y, p.size, p.col)
        end
    end
end


function sound_move()
    sfx(8)
end

function sound_menu_back()
    sfx(12)
end

function sound_menu_valid()
    sfx(13)
end

function sound_menu_move()
    sound_move()
end

function sound_toggle()
    sfx(56)
end

function sound_win()
    sfx(42)
end

function sound_move_error()
    sfx(5)
end

function sound_toggle_error()
    sound_move_error()
end

function sound_menu_error()
    sound_move_error()
end


-- remove tents and grass
function _reset_state(level, clear)
    level.state = {}
    level.anims = {}
    for y=1,#level.def do
        row = {}
        row_anim = {}
        for x=1,#level.def[y] do
            stt = level.def[y][x]
            if (stt == TE or stt == GR) and clear then
                stt = UN
            end
            add(row, stt)
            add(row_anim, {})
        end
        add(level.state, row)
        add(level.anims, row_anim)
    end
end

function load_level(number, reset)
    level_number = number
    game_level = load_level_from_def(levels[level_number+1], reset)
    init_input()
end

function load_level_from_def(ldef, reset)
    level = {}
    level.show_numbers = true
    level.size = #ldef
    level.def = ldef
    level.no_anims=false
    pix_size = level.size * (cell_size)
    level.origin = vec2((128 - pix_size)/2, (128 - pix_size)/2 + 2)
    -- used to compute anim of level
    level.anim = 0

    -- compute numbers
    level.rows = {}
    level.cols = {}
    for i=1, level.size do
        r, c = 0, 0
        for j=1, level.size do
            -- row
            if level.def[i][j] == TE then
                r += 1
            end
            -- col
            if level.def[j][i] == TE then
                c += 1
            end
        end
        add(level.rows, {nb=r})
        add(level.cols, {nb=c})
    end
    if reset == nil or reset then
        clear = true
    else
        clear = false
    end
    _reset_state(level, clear)

    function level:launch_start_anim()
        self.anim = 0
        for y=1,self.size do
            for x=1,self.size do
                if self:get_cell_state(x, y) == TR then
                    self:set_cell_state(x, y, TR)
                end
                if self:get_cell_state(x, y) == TE then
                    self:set_cell_state(x, y, TE)
                end
            end
        end
    end

    function level:get_expected_state(x, y) -- lua: index is 1-based
        return self.def[y][x]
    end
    function level:get_cell_state(x, y) -- lua: index is 1-based
        return self.state[y][x]
    end
    function level:get_anim(x, y) -- lua: index is 1-based
        return self.anims[y][x]
    end
    function level:set_cell_state(x, y, stt) -- lua: index is 1-based
        old = self.state[y][x]
        if stt == TE then
            self.anims[y][x] = create_anim(tent_show)
            self.anims[y][x].cur_frame = 1
        elseif stt == TR then
            self.anims[y][x] = create_anim(tree_show)
            self.anims[y][x].cur_frame = flr(rnd(9)) - 23
        elseif old == TE then
            self.anims[y][x] = create_anim(tent_hide)
            self.anims[y][x].cur_frame = 1
        else
            self.anims[y][x] = {}
        end
        self.state[y][x] = stt
    end
    function level:get_cell_bg_color(x, y) -- lua: index is 1-based
        stt = self:get_cell_state(x, y)
        if stt == UN then
            return unknown_col
        else
            return grass_col
        end
    end
    function level:cycle_cell(x, y)
        stt = self:get_cell_state(x, y)
        if stt == UN then
            self:set_cell_state(x, y, GR)
            return true
        elseif stt == GR then
            self:set_cell_state(x, y, TE)
            return true
        elseif stt == TE then
            self:set_cell_state(x, y, UN)
            return true
        else
            return false
        end
    end
    -- returns "wip", "success", "error"
    function level:get_completion()
        res = "success"
        for y=1,self.size do
            for x=1,self.size do
                stt = self:get_cell_state(x, y)
                exp = self:get_expected_state(x, y)
                if exp == TE then
                    if stt == UN then
                        return "wip"
                    end
                    if stt != TE then
                        res = "error"
                    end
                end
                if stt == TE and exp != TE then
                    res = "error"
                end
            end
        end
        return res
    end
    -- returns object with nb (value expected), and color (depending on current nb of tents)
    -- i: 1-based
    function level:compute_col_infos(x)
        cnt = 0
        for y=1, self.size do
            if self:get_cell_state(x, y) == TE then
                cnt += 1
            end
        end
        return {nb=self.cols[x].nb, color=self:rc_colors(self.cols[x].nb, cnt)}
    end
    function level:compute_row_infos(y)
        cnt = 0
        for x=1, self.size do
            if self:get_cell_state(x, y) == TE then
                cnt += 1
            end
        end
        return {nb=self.rows[y].nb, color=self:rc_colors(self.rows[y].nb, cnt)}
    end
    -- return color to display number depending on state
    function level:rc_colors(expected, cur)
        if cur > expected then
            return numbers_error_col
        end
        if cur == expected then
            return numbers_ok_col
        end
        return numbers_wip_col
    end

    function level:update()
        self.anim += 1
    end

    function level:draw()
        --draw_grid(self)
        if self.show_numbers then
            draw_numbers(self)
        end
        draw_cell_bgs(self)
        draw_cell_sprites(self)
    end

    level:launch_start_anim()

    return level
end

function init_input()
    input = {}
    input.pos = vec2(0, 0) -- lua: 0-based
end

function input_game(level)
    if btnp(0) then
        if input.pos.x > 0 then
            input.pos.x -= 1
            sound_move()
        else
            sound_move_error()
        end
    end
    if btnp(1) then
        if input.pos.x < level.size - 1 then
            input.pos.x += 1
            sound_move()
        else
            sound_move_error()
        end
    end
    if btnp(2) then
        if input.pos.y > 0 then
            input.pos.y -= 1
            sound_move()
        else
            sound_move_error()
        end
    end
    if btnp(3) then
        if input.pos.y < level.size - 1 then
            input.pos.y += 1
            sound_move()
        else
            sound_move_error()
        end
    end
    if btnp(buttons.b1) then
        if level:cycle_cell(input.pos.x + 1, input.pos.y + 1) then
            sound_toggle()
        else
            sound_toggle_error()
        end
    end
    if btnp(buttons.b2) then
        sound_menu_back()
        pause_menu.selection = 1
        pause = true
    end
end

function draw_input()
    top_left = vec2(game_level.origin.x + input.pos.x * cell_size,
        game_level.origin.y + input.pos.y * cell_size)
    size = cell_size-1

    if (flr(time() * 3.0) % 2) == 0 then
        c = 0
    else
        c = 7
        --rect(top_left.x, top_left.y, top_left.x + size, top_left.y + size, c)
    end
    rect(top_left.x+1, top_left.y+1, top_left.x + size, top_left.y + size, c)
end

-- size
level_number_w, level_number_h = 13, 13

-- 0-based
function draw_level_number(x, y, number)
    --if save:completed(i) TODO
    if is_level_completed(number) then
        c = 3
    else
        c = 5
    end
    rectfill(x+1, y+1, x + level_number_w, y + level_number_h, shadow_col)
    rectfill(x, y, x + level_number_w - 1, y + level_number_h - 1, c)

    text = tostr(number + 1)
    x_text_shift = (level_number_w - (#text * 4 - 1)) / 2
    print(text, x_text_shift + x, level_number_h / 2 - 5 / 2 + y, colors.white)
end

function create_level_select(nb_levels)
    level_select = {}
    level_select.nb_levels = nb_levels
    level_select.selection = 0 -- 0-based
    level_per_row = 5
    rows = ceil(nb_levels / level_per_row)
    -- spacing
    level_select.sx, level_select.sy = level_number_w + 4, level_number_h + 4
    level_select.total_width = level_select.sx * (level_per_row - 1) + level_number_w
    level_select.origin_x = (128 - level_select.total_width) / 2

    function level_select:draw(origin_y)
        i = 0
        for y=0,rows-1 do
            for x=0,level_per_row-1 do
                draw_level_number(self.origin_x + x * self.sx, origin_y + y * self.sy, i)
                if i == self.selection then
                    c = blink(5, 0, 7)
                    rect(self.origin_x + x * self.sx - 1, origin_y + y * self.sy - 1, self.origin_x + x * self.sx + level_number_w, origin_y + y * self.sx + level_number_h, c)
                end


                i += 1
            end
        end
    end

    function level_select:input()
        if btnp(buttons.left) then
            if self.selection > 0 then
                self.selection-=1
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.right) then
            if self.selection < self.nb_levels - 1 then
                self.selection += 1
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.down) then
            if self.selection + level_per_row < self.nb_levels then
                self.selection += level_per_row
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.up) then
            if self.selection >= level_per_row then
                self.selection -= level_per_row
                sound_menu_move()
            else
                sound_menu_error()
            end
        end
        if btnp(buttons.b1) then
            sound_menu_valid()
            load_level(self.selection)
            mode = "game"
        end
        if btnp(buttons.b2) then
            sound_menu_back()
            mode = "home"
        end
    end

    return level_select
end

cartdata("frozax_tentsandtrees")

-- 0-based
function set_level_completed(i)
    dset(i, 1)
end

-- 0-based
function is_level_completed(i)
    return dget(i) == 1
end

function draw_tutorial(page)
    cls(bg_col)

    color(0)
    printc("\x8b  instructions "..page.."/3  \x91", 2)

    height = 7
    top = 17
    left = 4
    if page == 1 then
        l = {
            {GR,GR,TR,TE},
            {TR,TE,GR,GR},
            {TR,GR,GR,GR},
            {TE,TR,TE,GR}
        }
        tuto_level = load_level_from_def(l)
        tuto_level.origin.y += 6
        tuto_level.no_anims=true
        ti = flr(time()*2) % 10
        if ti > 1 then
            tuto_level:set_cell_state(2,3,GR)
            tuto_level:set_cell_state(3,3,GR)
            tuto_level:set_cell_state(4,3,GR)
        end
        if ti > 2 then
            tuto_level:set_cell_state(4,2,GR)
            tuto_level:set_cell_state(4,4,GR)
        end
        if ti > 3 then
            tuto_level:set_cell_state(1,4,TE)
            tuto_level:set_cell_state(3,4,TE)
        end
        if ti > 4 then
            tuto_level:set_cell_state(1,1,GR)
            tuto_level:set_cell_state(3,2,GR)
        end
        if ti > 5 then
            tuto_level:set_cell_state(2,2,TE)
            tuto_level:set_cell_state(3,2,GR)
        end
        if ti > 6 then
            tuto_level:set_cell_state(2,1,GR)
            tuto_level:set_cell_state(4,1,TE)
        end
        tuto_level:draw()
        color(text_col)
        print("trees are placed in a grid.", left, top)
        top += height
        print("you have to place a tent next\nto each tree.", left, top)
        top = 100
        print("the numbers around the grid\ntell you the number of tents\nin the corresponding row or\ncolumn.", left, top)
    elseif page == 2 then
        color(text_col)
        top += 5
        print("each tent must be in one of\nthe four adjacent cells of its\nassociated tree (horizontally\nor vertically but not\ndiagonally).", left, top)
        l = {
            {GR,GR,GR},
            {GR,TR,GR},
            {GR,GR,GR},
        }
        tuto_level = load_level_from_def(l, false)
        tuto_level.no_anims=true
        tuto_level.origin.x -= 4
        tuto_level.origin.y += 15
        tuto_level.show_numbers = false
        ti = flr(time()*2) % 4
        if ti == 0 then
            tuto_level:set_cell_state(1,2,TE)
        end
        if ti == 1 then
            tuto_level:set_cell_state(2,3,TE)
        end
        if ti == 2 then
            tuto_level:set_cell_state(3,2,TE)
        end
        if ti == 3 then
            tuto_level:set_cell_state(2,1,TE)
        end
        tuto_level:draw()
    elseif page == 3 then
        top += 5
        print("tent cannot touch each other,\nnot even diagonally", left, top, text_col)
        l = {
            {GR,GR,TR,TE},
            {TR,TE,GR,TE},
            {TE,GR,GR,TR},
            {TR,GR,GR,GR},
        }
        tuto_level = load_level_from_def(l, false)
        tuto_level.origin.x -= 4
        tuto_level.origin.y += 8
        tuto_level.show_numbers = false
        tuto_level.no_anims=true
        tuto_level:draw()
        ti = flr(time() * 3)
        if ti % 2 == 0 then
            sx, sy, sw, sh = 11, 0, 11, 11
            sspr(sx, sy, sw, sh, tuto_level.origin.x + 3 * 12 + 1, tuto_level.origin.y + 1)
            sspr(sx, sy, sw, sh, tuto_level.origin.x + 1 * 12 + 1, tuto_level.origin.y + 1 * 12 + 1)
        end
    end
end

function input_tutorial()
    if btnp(buttons.b1) or btnp(buttons.b2) or btnp(buttons.right) then
        sound_menu_valid()
        tutorial = (tutorial + 1) % 4
    end
    if btnp(buttons.left) and tutorial != 1 then
        sound_menu_valid()
        tutorial = tutorial - 1
    end
end

function draw_grid(level)
    x0, y0 = level.origin.x, level.origin.y
    x1 = x0 + level.size * cell_size
    y1 = y0 + level.size * cell_size

    for i=0, level.size do
        x = level.origin.x + i * cell_size
        y = level.origin.y + i * cell_size
        line(x, y0, x, y1, grid_col)
        line(x0, y, x1, y, grid_col)
    end
end

function draw_numbers(level)
    srand(0)
    for i=0, level.size-1 do
        -- rows
        row = level:compute_row_infos(i+1)
        if (10) < level.anim-20 or level.no_anims then
            print(row.nb, level.origin.x - cell_size/2, level.origin.y + (i + 0.5) * cell_size - 2, row.color)
        end
        -- cols
        col = level:compute_col_infos(i+1)
        if (10) < level.anim-20 or level.no_anims then
            print(col.nb, level.origin.x + (i + 0.5) * cell_size - 1, level.origin.y - cell_size * 0.5, col.color)
        end
    end
end

function draw_cell_bgs(level)
    srand(1)
    ys = level.origin.y + 1
    size = cell_inner_size - 1 -- because it's final pixel, not size of rect
    for y=1, level.size do
        xs = level.origin.x + 1
        for x=1, level.size do
            this_size = (level.anim - rnd(10))*2
            this_size = min(this_size, size)
            this_size = max(this_size, -1)
            if level.no_anims then
                this_size = size
            end
            if this_size >= 0 then
                shft = (size-this_size)/2
                c = level:get_cell_bg_color(x, y)
                rectfill(xs+shft, ys+shft, xs + shft + this_size, ys + shft + this_size, c)
            end
            xs += cell_size
        end
        ys += cell_size
    end
end

function draw_cell_sprites(level)
    ys = level.origin.y + 1
    size = cell_inner_size - 1 -- because it's final pixel, not size of rect
    for y=1, level.size do
        xs = level.origin.x + 1
        for x=1, level.size do
            stt = level:get_cell_state(x, y)
            anm = level:get_anim(x,y)
            if anm != nil and anm.frames then
                if anm.cur_frame < (#anm.frames*2) then
                    anm.cur_frame += 1
                end
                if level.no_anims then
                    anm.cur_frame = 2*#anm.frames
                end
                if anm.cur_frame > 1 then
                    anm.frame = anm.frames[anm.cur_frame \ 2]
                    anm:draw(vec2(xs, ys))
                end
            end
            --if stt != UN then
            --    if stt == TE then
            --        anim = tent_show
            --        tent_show.frame = tent_show.frames[4]
            --    elseif stt == TR then
            --        anim = tree_show
            --        tree_show.frame = tree_show.frames[4]
            --    end
            --    anim:draw(vec2(xs, ys))
            --end
            xs += cell_size
        end
        ys += cell_size
    end
end


GR = 0
TE = 1
TR = 2
UN = 3
levels = {}
l = {
{GR,TR,TE,TR,TE,},
{GR,GR,GR,GR,GR,},
{GR,TE,GR,GR,GR,},
{GR,TR,GR,GR,GR,},
{TE,TR,TR,TE,GR,},
}
add(levels, l)
l = {
{GR,GR,TE,TR,TR,},
{TR,GR,GR,GR,TE,},
{TE,GR,TR,GR,GR,},
{GR,GR,TE,GR,TE,},
{GR,GR,GR,GR,TR,},
}
add(levels, l)
l = {
{TE,TR,GR,GR,GR,},
{GR,GR,GR,GR,TR,},
{GR,TE,GR,GR,TE,},
{GR,TR,GR,GR,GR,},
{TR,TE,GR,TE,TR,},
}
add(levels, l)
l = {
{GR,GR,GR,GR,TR,},
{TE,TR,TE,GR,TE,},
{TR,GR,GR,GR,GR,},
{TE,TR,GR,GR,GR,},
{GR,GR,GR,TR,TE,},
}
add(levels, l)
l = {
{GR,TR,GR,GR,TR,TE,},
{GR,TE,GR,TE,TR,TR,},
{GR,GR,GR,TR,GR,TE,},
{GR,TR,GR,TE,GR,GR,},
{GR,TE,GR,GR,GR,GR,},
{GR,GR,GR,TR,TE,GR,},
}
add(levels, l)
l = {
{TR,GR,TR,GR,GR,TE,},
{TE,GR,TE,GR,GR,TR,},
{GR,GR,GR,GR,GR,GR,},
{TE,TR,GR,GR,TE,GR,},
{GR,GR,GR,GR,TR,GR,},
{GR,TE,TR,GR,TR,TE,},
}
add(levels, l)
l = {
{TE,TR,GR,GR,GR,GR,},
{GR,GR,TR,TE,GR,GR,},
{GR,TR,GR,GR,GR,TR,},
{GR,TE,GR,TE,TR,TE,},
{GR,GR,GR,GR,GR,GR,},
{GR,TE,TR,GR,TE,TR,},
}
add(levels, l)
l = {
{GR,TE,GR,TE,TR,TR,},
{GR,TR,GR,GR,GR,TE,},
{TR,TE,TR,TE,GR,GR,},
{GR,GR,GR,GR,GR,GR,},
{GR,TE,GR,TR,GR,GR,},
{GR,TR,GR,TE,GR,GR,},
}
add(levels, l)
l = {
{GR,GR,GR,GR,TE,TR,TE,},
{GR,TE,TR,GR,GR,TR,TR,},
{TR,GR,TR,TE,GR,TE,GR,},
{TE,GR,GR,GR,GR,GR,GR,},
{GR,GR,GR,GR,GR,TR,GR,},
{TE,GR,GR,GR,GR,TE,GR,},
{TR,GR,TR,TE,GR,GR,GR,},
}
add(levels, l)
l = {
{GR,GR,TE,GR,GR,GR,GR,},
{TE,GR,TR,GR,TE,TR,TE,},
{TR,TR,TE,GR,GR,GR,TR,},
{GR,GR,GR,GR,TR,TE,GR,},
{TR,TE,GR,TE,GR,GR,GR,},
{GR,GR,GR,TR,TR,TE,GR,},
{GR,TE,TR,GR,GR,GR,GR,},
}
add(levels, l)
l = {
{GR,GR,GR,GR,TE,TR,GR,},
{TE,TR,TE,TR,GR,GR,GR,},
{GR,GR,GR,GR,TE,TR,GR,},
{GR,TR,TE,GR,GR,GR,GR,},
{GR,GR,GR,GR,TE,GR,TR,},
{GR,GR,GR,TR,TR,GR,TE,},
{GR,TE,TR,TE,GR,GR,GR,},
}
add(levels, l)
l = {
{GR,GR,GR,GR,TE,GR,TR,},
{GR,TE,TR,GR,TR,GR,TE,},
{GR,GR,GR,TR,TE,GR,GR,},
{TE,GR,GR,GR,GR,GR,GR,},
{TR,GR,TE,GR,GR,TE,TR,},
{TE,TR,TR,GR,GR,TR,GR,},
{GR,TR,TE,GR,GR,TE,GR,},
}
add(levels, l)
l = {
{TE,TR,TE,GR,GR,GR,GR,GR,},
{TR,GR,TR,GR,TE,GR,TR,TE,},
{TE,GR,TE,GR,TR,GR,GR,GR,},
{GR,GR,TR,TR,GR,GR,GR,GR,},
{GR,TR,GR,TE,TR,TE,GR,TE,},
{GR,TE,GR,GR,GR,GR,GR,TR,},
{TR,GR,TR,GR,GR,GR,TE,GR,},
{TE,GR,TE,TR,TE,GR,TR,GR,},
}
add(levels, l)
l = {
{GR,TE,TR,GR,GR,GR,GR,TE,},
{TR,GR,GR,GR,TE,TR,GR,TR,},
{TE,GR,GR,GR,GR,TR,TE,GR,},
{GR,GR,GR,TE,TR,GR,GR,GR,},
{TE,GR,GR,GR,GR,TE,GR,TE,},
{TR,GR,TR,TE,GR,TR,GR,TR,},
{GR,GR,TR,GR,TR,GR,TE,GR,},
{TE,TR,TE,GR,TE,GR,TR,GR,},
}
add(levels, l)
l = {
{GR,GR,GR,GR,GR,TE,TR,GR,},
{TE,GR,TE,GR,GR,GR,GR,TR,},
{TR,GR,TR,GR,TR,TE,GR,TE,},
{GR,TE,GR,GR,TR,GR,GR,GR,},
{GR,TR,GR,GR,TE,GR,TR,GR,},
{GR,GR,GR,GR,GR,GR,TE,GR,},
{TE,TR,GR,GR,GR,GR,GR,TR,},
{GR,GR,TR,TE,TR,TE,GR,TE,},
}
add(levels, l)
l = {
{TR,TE,GR,GR,GR,TR,GR,GR,},
{GR,GR,GR,GR,GR,TE,GR,TE,},
{TR,TE,GR,TE,GR,GR,GR,TR,},
{GR,GR,TR,TR,TR,GR,TE,GR,},
{TE,GR,TE,GR,TE,GR,TR,GR,},
{TR,GR,GR,GR,GR,TR,TE,GR,},
{GR,GR,TR,TE,GR,GR,GR,TR,},
{TE,TR,GR,GR,GR,TE,TR,TE,},
}
add(levels, l)
l = {
{GR,TR,GR,GR,GR,TR,TE,TR,TE,},
{GR,TE,TR,TE,GR,GR,GR,TR,GR,},
{GR,GR,GR,GR,GR,TE,TR,TE,GR,},
{TE,GR,TE,TR,GR,GR,GR,GR,GR,},
{TR,GR,GR,GR,TE,TR,GR,TE,GR,},
{GR,TR,GR,GR,GR,GR,GR,TR,TR,},
{GR,TE,GR,GR,GR,GR,TR,GR,TE,},
{GR,GR,GR,TE,GR,GR,TE,GR,GR,},
{GR,TE,TR,TR,GR,GR,GR,TR,TE,},
}
add(levels, l)
l = {
{TR,TE,GR,GR,GR,GR,GR,GR,TR,},
{GR,GR,GR,GR,TE,TR,TE,TR,TE,},
{GR,TE,TR,GR,GR,GR,GR,TR,GR,},
{GR,GR,GR,GR,TR,GR,GR,TE,GR,},
{TE,TR,TE,TR,TE,GR,GR,TR,GR,},
{GR,GR,GR,GR,GR,GR,GR,TE,GR,},
{GR,TE,TR,TE,TR,TR,GR,GR,GR,},
{TR,GR,GR,GR,GR,TE,GR,GR,GR,},
{TE,GR,GR,TE,TR,GR,GR,TE,TR,},
}
add(levels, l)
l = {
{TR,TE,GR,GR,GR,TR,TE,GR,TE,},
{GR,GR,GR,TE,TR,GR,GR,GR,TR,},
{GR,TE,TR,GR,GR,TE,GR,TE,GR,},
{GR,GR,GR,GR,GR,TR,GR,TR,TR,},
{GR,TE,TR,TE,TR,GR,GR,GR,TE,},
{GR,GR,GR,GR,GR,GR,TE,GR,TR,},
{TR,GR,GR,GR,TE,TR,TR,GR,TE,},
{TE,GR,TE,GR,GR,GR,GR,TR,GR,},
{GR,GR,TR,GR,GR,TE,TR,TE,GR,},
}
add(levels, l)
l = {
{GR,GR,TR,TE,GR,TE,GR,GR,GR,},
{TR,TE,GR,GR,GR,TR,GR,TR,TE,},
{GR,TR,GR,TE,TR,GR,GR,GR,GR,},
{GR,TE,GR,GR,GR,GR,TE,GR,GR,},
{GR,TR,GR,TE,TR,GR,TR,TR,TE,},
{GR,TE,GR,GR,GR,GR,GR,GR,TR,},
{TR,GR,GR,GR,GR,GR,TE,TR,TE,},
{TE,GR,GR,GR,TR,GR,GR,GR,TR,},
{GR,TR,TE,GR,TE,TR,TE,GR,TE,},
}
add(levels, l)



function _update()
    anims:update()
    if tutorial != 0 then
        input_tutorial()
    else
        if mode == "home" then
            if credits then
                if btnp(buttons.b1) or btnp(buttons.b2) then
                    sound_menu_back()
                    credits = false
                end
            else
                home_menu:input()
            end
        elseif mode == "level_select" then
            level_select:input()
        elseif mode == "game" then
            game_level:update()
            if pause then
                pause_menu:input()
            elseif eol_anim then
                particles:update()
            elseif eol then
                particles:update()
                eol_menu:input()
            else
                input_game(game_level)
            end
        end
    end
end

function draw_title()
    local y = 4
    sspr(0, 32, 128, 3*16, 0, y)
    
    f = flr(time()*3) % 3
    sspr(74 + f * 8, 20, 8, 12, 10, 24+y)
end

function _draw()
    if tutorial != 0 then
        draw_tutorial(tutorial)
    else
        if mode == "home" then
            cls(bg_col)
            draw_title()
            home_menu:draw(55)
            y = 100
            printc("tents and trees is also", y, text_col)
            printc("available on mobile:", y+6, text_col)
            printc("www.frozax.com/tat", y+16, text_col)
            if credits then
                y = 44
                draw_rwin(8+1, y+1, 127-16, 127-48, shadow_col, shadow_col)
                draw_rwin(8, y, 127-16, 127-48, bg_col, 0)
                y += 9
                c = text_col
                printc("programming:", y, c)
                printc("francois guibert - @frozax", y+7, c)
                printc("art:", y+25, c)
                printc("vincent guibert", y+32, c)
                printc("sound:", y+50, c)
                printc("@gruber_music", y+57, c)
            end
        elseif mode == "level_select" then
            cls(bg_col)
            draw_title()
            level_select:draw(54)
        elseif mode == "game" then
            cls(bg_col)
            if game_level.size < 9 then
                draw_level_number(127 - level_number_w-1, 1, level_number)
            end
            game_level:draw()
            if pause then
                y = 40
                draw_rwin(16, y, 127-32, 51, bg_col, 0)
                pause_menu:draw(y + 8)
            elseif eol_anim then
                particles:draw()
                if time() - eol_anim_start > 2 then
                    eol_anim = false
                    eol = true
                end
            elseif eol then
                y = 40
                draw_rwin(24, y, 127-48, 50, bg_col, 0)
                printc("congratulations!", y + 7, text_col)
                eol_menu:draw(y + 20)
                particles:draw()
            else
                draw_input()
                completion = game_level:get_completion()
                if completion == "success" then
                    set_level_completed(level_number)
                    eol_menu.selection = 1
                    eol_anim_start = time()
                    particles:start()
                    eol_anim = true
                end
            end
            if game_level.size <= 6 then
                -- draw input
                printc("\x8b\x91\x94\x83: select a cell", 105, text_col)
                printc("c/\x8e: change cell state", 111, text_col)
                printc("v/\x97: display menu", 117, text_col)
            end
        end
    end

    --showpct(0)
end

function _init()
    mode = "home"
    tutorial = 0
    credits = false
    eol = false
    eol_anim = false

    anims.maxdelay=3
    
    -- setup palette
    -- rose -> rouge fonc (14 -> 8+128)
    pal(14, 128+8, 1)
    -- vert -> vert fonc (11 -> 11+128)
    pal(11, 128+11, 1)
    -- violet (13 -> 2+128)
    pal(13, 128+2, 1)
    -- jaune devient tronc (10 -> 4+128)
    pal(10, 128+4, 1)
    -- ombre titre: bleu fonc
    -- texte titre: gris foncé
    pal(1, 128+14, 1)
    pal(5, 128+5, 1)

    -- (done)couleur fond: 6 --> 128+5
    -- (done)herbe: 2 --> 128+7

    w, h = 11, 11
    tent_show = {{x=44, y=0, w=w, h=h},
        {x=33, y=0, w=w, h=h},
        {x=22, y=0, w=w, h=h},
        {x=0, y=0, w=w, h=h}}
    tent_hide = {{x=0, y=0, w=w, h=h},
        {x=22, y=0, w=w, h=h},
        {x=33, y=0, w=w, h=h},
        {x=44, y=0, w=w, h=h},
        {x=0,y=0,w=0,h=0}} -- empty frame
    tree_show = {
        {x=33, y=11, w=w, h=h},
        {x=22, y=11, w=w, h=h},
        {x=11, y=11, w=w, h=h},
        {x=0, y=11, w=w, h=h}}

    cell_inner_size = 11
    cell_size = 12

    shadow_col = 1
    bg_col = 15
    grass_col = 2
    pal(2, 128+7, 1)
    unknown_col = 6
    pal(6, 128+5, 1)
    grid_col = 5
    numbers_wip_col = unknown_col
    numbers_error_col = 8
    numbers_ok_col = 3
    input_col = 0
    text_col = unknown_col

    bplay = {text="play"}
    function bplay:click()
        mode = "level_select"
    end
    bhtp = {text="how to play"}
    function bhtp:click()
        tutorial = 1
    end
    bc = {text="credits"}
    function bc:click()
        credits = true
    end
    home_menu = create_menu({bplay,bhtp,bc}, shadow_col)

    bres = {text="resume"}
    function bres:click()
        pause = false
    end
    bquit = {text="quit"}
    function bquit:click()
        pause = false
        eol = false
        eol_anim = false
        mode = "home"
    end
    pause_menu = create_menu({bres, bhtp, bquit}, shadow_col)
    pause = false

    bnl = {text="next level"}
    function bnl:click()
        if level_number+1 < #levels then
            load_level(level_number+1)
        else
            -- no more levels, back home
            mode = "home"
        end
        eol = false
    end
    eol_menu = create_menu({bnl, bquit}, shadow_col)

    home_menu.button_text_col = colors.white
    pause_menu.button_text_col = colors.white
    eol_menu.button_text_col = colors.white

    load_level(0)
    init_input()
    --level_select = create_level_select(#levels)
    level_select = create_level_select(20)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077700077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008ee0000007770777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888ee000000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888ee00000007770000000088e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088d88ee00000777770000008888e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ddd8ee00007770777000088d88ee0000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088ddd8eee007770007770088ddd8eee0008d888e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08ddddd8ee00070000070008ddddd8ee008ddddd8e0000888e000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033bbb00000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000333bb000000033b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000733bb000000033b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000333bb000000333bb0000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000773b7000000773b7000000033b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000333bb000000333bb000000773b700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300aa400000000aa40000000333bb000000033b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b0aa403b00000aa400000000aa4000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000900000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000090000000900000009000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000900900000009000000900000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000009000000900000090090000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000099000000909000000900000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000049900000499000094990000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000994a0000994a0000994a0000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000044a4900044a4900044a49000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaa00aaaaaa00aaaaaa000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000003333bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000003333bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000003333bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000333333bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000333333bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000773333bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005555773333bbbb55500000000005555557055555575500005575555557005550000000000000000000000000000000000
00000000000000000000000000000005555333333bbbb55510000000007755777055777775550005577755777055775000000000000000000000000000000000
00000000000000000000000000000005555333333bbbb55510000000000055700055700005555005570055700055707000000000000000000000000000000000
00000000000000000000000000000005555777733bb7755510000000000055700055700005575705570055700055500000000000000000000000000000000000
00000000000000000000000000000005555777733bb7755510000000000055700055555005575505570055700075550000000000000000000000000000000000
00000000000000000000000000000005555333333bbbb55510000000000055700055777705577575570055700007555000000000000000000000000000000000
00000000000000000000000000000005555333333bbbb55510000000000055700055700005570555570055700000755700000000000000000000000000000000
0000000000000000000000000000000555555aaaa445555510000000000055700055700005570755570055700050055700000000000000000000000000000000
000000000000000000000000000008ee55555aaaa445555510000000000055700055555575570075570055700075557700000000000000000000000000000000
000000000000000000000000000088eeee555aaaa445555510000000000077700077777777770007770077700007777000000000000000000000000000000000
000000000000000000000000000088eeee555aaaa4455333bb000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000888888eee55aaaa4455333bb100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000888888eee555555555555511100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008888888eeee55555555555510000000000000000000000000005555557055555000555555755555570555000000000000000000
00000000000000000000000008888888eeee5555555555551000000000000000000eee0000000755777055775500557777755777775577500000000000000000
0000000000000000000000008888dd8888eee55555555555100000000000000000ee0ee000000055700055705570557000055700005570700000000000000000
0000000000000000000000008888dd8888eee11111111111100000000000000000ee0ee000000055700055705570557000055700005550000000000000000000
00000000000000000000000888dddddd88eeee00000000000000000000000000000eee0000000055700055555770555557055555000555000000000000000000
00000000000000000000000888dddddd888eeee000000000000000000000000000eeee0e00000055700055755700557777055777700055500000000000000000
00000000000000000000a08888dddddd888eeee00a00000000000000000000000ee00eee00000055700055705500557000055700000005570000000000000000
00000000000000000000a088dddddddddd88eeee0a04000000000000000000000ee000ee00000055700055705570557000055700005005570000000000000000
00000000000000000000a888dddddddddd888eeeea040000000000000000000000eeee0ee0000055700055705570555555755555570555770000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000077700077707770777777777777770777700000000000000000
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
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff7777777777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff755555555555755555555555fffffffffffffffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffff7777777777777ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff333fffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff33333ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffff822ffffffff33333ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffffffff88822fffffff73333ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffffffff88822fffffff33333ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffff8818822ffffff77337ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffff8111822ffffff33333ffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffffff881118222fff3ff224fffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000ffffffffffffffffffffffffffffffffffffffffffffffff811111822fff33f224f33ff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000fffffffffffffffffffffffffffffffffffffffffffffff55555555555fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000111122223333444455556666777788889999aaaabbbbccccddddeeeeffff000011111111111122225555ddddffff22229999aaaa333333335555eeeeeeee
0000111122223333444455556666777788889999aaaabbbbccccddddeeeeffff000011111111111122225555ddddffff22229999aaaa333333335555eeeeeeee
0000111122223333444455556666777788889999aaaabbbbccccddddeeeeff7f070011111111111122225555ddddffff22229999aaaa333333335555eeeeeeee
0000111122223333444455556666777788889999aaaabbbbccccddddeeeeffff000011111111111122225555ddddffff22229999aaaa333333335555eeeeeeee
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
010200000472005731067410c75110761077610070000700007001970000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000800000f04013051170511800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000c1600e151101411213113121141111511115115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006450084500d4500f4501a450214402243000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000400000c5600f55114051180511b0411d0412000017000140000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000190611c0511f04122031280051f000220002200021000220001f0001f000220002200021000220001f0001f0002e0012e0002d0002e0002b0002b0002b0022b005000000000000000000000000000000
000200000c1540d1510e5510f54110041110411273113731147311573500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002152526535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300002f73534735000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003053534535044000440010400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000180251f535260452a55512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
0002000019045000001e0450000023045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000260452b035300253000500703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000400002474526745297452e7453074532745357453a7452400526005290052e0053000532005350053a00500000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000197770c700197770c7001c7670c7001c7570c7001e7570c700217470c700217370c700237370c700237270c700257170c700287170c7000c7000c700135000c600135000c600135050c605135050c605
00010000287770c700257770c700257670c700237570c700237570c700217470c700217370c7001e7370c7001c7270c7001c7170c70019717127050c700127050070000700007000070000700007000070000700
00020000016100d6111c61131611146110c61108611056110261501601016050c600116001a600006000060000600006000060000600006000060000600006000000000000000000000000000000000000000000
00020000052670061710267006171236700617123570161712357016170a157006170d147006170d147006170b047006170b037006170a037006170a727006170b727006170c717006170b117006170811700617
000400002763022630206201b6201661015610116100d6100b6100761005610036100261002610026100261001610016100161501600016000160001600000000000000000000000000000000000000000000000
00070000386303062025610206101c61019610176101561012610106100f6100d6100b6100a613086130761306613046130361303613006050060500605006050060500605006050060500605006050060500605
000200000c475152740f474186651646515264114540e6550d4550b24408445066440443502234014340062500424002240041500615000040000400004000040000400004000040000400004000040000400004
0002000012055112550f0450e2450d0450c2450b0350a235090350823507025062250502504225030150221501015012150400503205010050760506605066050560504605046050360502605016050160501605
00020000010541325514045142451203515235110351622510025172250e0250a2250702508225050250621503015042150400503205010050760506605066050560504605046050360502605016050160501605
000200003f643232333a64121231346411e2312f641172312a63112221246310d2211e63109221186310522111621032110c62101211086250121504625002150261500615006000060500600006000060000600
000300000c363236650935520641063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00051c2032251376512a25133641222412e6411b2412564115241216410c2311d631092311963106231166310323112631022310e631012310a63100221086210022104621002210362100211026110021100611
000500001235311353103530f3530e3530e3530d3530d3430c3430c3430b3430b3430a3430a343093330933308333083330733307333063330632305323053230432304323033230332302313023130131301313
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000500000c466186660c456186560c446186460c436186360c416186160c406184060040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
0002000002215006200341500630052150063008415006300b215006400d415006401022500640124250065011225006400f425006400d2150064009415006300621500630054150063003215006300341500620
000200003f6142646525361242512345122341212413f6041f3050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100200a4133b2110a1133b4110b013302110b313302210a1133b2110a4133b2110a0133b2210a1133b211091133a211091133a6110a4133b2210a1133b2110a7133b2210a3133b2110a1133b2110a6133b411
000100003b35039350363503475032750307502e7502b750297502675023750235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
00020000133551f3552b3553735537305003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000000
000100001d251202512f2512c2513e2513d2511d0001d0001d0001d0001d0001d0001d00000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000100002b52329543265532555323551215511f5511c5511955118551165511455113541105410d5310b52108521075210551103511025110151102400023000130003400024000140001400024000240001400
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c15515003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000014163007000c1000000000000000001015300700000000000000000000000b14300700000000000000000000000613300700000000000000000000000312300700000000000000000000000111300700
000200000c05006731037150070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0005000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
000600000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002406025051270412f0002b0512c0512d0412e0312f0212f0052f00032000030000000037000370002f0002f0002f0002f000000003300004000000000000000000000000000000000000000000000000
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002e3322b33128332263312333221331203321d3311b3221a3211932217321153221332112322103210e3120c3110b31209311073120631104312033110231201311013120031100300003000030000300
00010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000013150132501345000002660021600196001260011607116070c60710607156071a6071e607206072260722607206001d6001c60018600156001560014600166001a6001c6001c600166000f60000000
000200001d3551d7451d3351375513345137350070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000a00022474129741000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001d61506323156002d60001600016000160002600026000360003600036000d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0007000023745287452d3021e105370021c0051330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021320207002070022b0001f0001f0021f0021f002
000400002f3402f3402f3403434034340343403433034330343303433034330343203432034310343103431034310343103431500300003000030000300003000030000300003000030000300003000030000300
000200001d6651e655083410a4410b3410c4310d3310f43111321134211532117411193111b4111b3011d3011830510305163050f3050e3050d3050c3050b3050a30509305083050630505305043050000000000
000900000864514645070450654502204006050550005500266002460023600216001f6001d6001c6001a60018600176001660015600146000030000300003000030000300003000030000300003000030000300
00020000071540f163163730b22332643216331c6231861315613136130e6130a61304600000000000000000000000b1010710105101031010110100000000000000000000000000000000000000000000000000
0012000015753047000500005700070000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
000600002336311000103330400010705107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000137371c537142371d737155471e147167471f547161571f757175572015718767215671916722767115771a177127771b57718100210001950022100140001d500151001e000165001f1001700020500
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
