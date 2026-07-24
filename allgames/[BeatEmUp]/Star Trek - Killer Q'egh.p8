pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--star trek: killer q'egh
--by ridgek

---demo app
---initialize app
function _init()
  credits_init()
end

function credits_init()
  music(0)

  _update = credits_update
  _draw = credits_draw
end

function credits_update()
  if(time() > 8.7) then
    title_init()
    return
  end
end

function credits_draw()
  cls()

  if(time() < 3) then
    print_centered('a', nil, -21)
    print_centered('totally non-commercial', nil, -14)
    print_centered('fan game by:', nil, -7)
    print_centered('ridgek', nil, 7)
    print_centered('HTTPS://RIDGEK.ITCH.IO', nil, 14)
  elseif(time() < 6) then
    print_centered('all intellectual property', nil, -14)
    print_centered('contained within', nil, -7)
    print_centered('is the property of')
    print_centered('its respective owners', nil, 7)
  else
    print_centered("please don't sue me")
  end
end



---title app state

---override p8 loop
function title_init()
  if(stat(24) == -1) then
    music(0)
  end

  selection = 1

  _update = title_update
  _draw = title_draw
end

---update title menu
function title_update()
  --move cursor
  if(btnp(ƒ)) then
    sfx(8)

    selection = 2

  elseif(btnp(”)) then
    sfx(8)

    selection = 1
  end

  if(btnp(Ž)) then
    if(selection == 2) then
      config_init()
    else
      game_init()
    end
  end
end

---draw title menu
function title_draw()
  cls()
  camera()

  local cursor = 0

  draw_img(img)

  if(selection == 1) then
    cursor = 92
  else
    cursor = 99
  end

  rectfill(38, 90, 90, 105, 0)
  --cursor
  print('', 40, cursor, 7)

  print('start game', 48, 92, 7)
  print('options', 48, 99, 7)

  --version
  print('V1.0.0', 100, 120, 13)
end

function draw_img()
  local img="00000000000002555ddddddd5101111111112222112222222222221011222222221122221111111111221015555555552221002000000000000000000000000100000000000001555ddddddd5101111111122222222222222222222112222222222222222225552222221015555555552221112000000000000000000000000100000000000001555ddddddd51012111111111222222222222222221122222222222552555555555555210155555555522211d20000000000000000000000001000000000000015555dddddd5101222222222222222225522222252112225222222255552555555555521115555555552221dd10000000000000000010000001000000000000015555ddddd55101555555555555555555555555555115225555555555555555555555521115dd5555552225d120000000000000000001000001000000000000015555ddddd551015555555555dd55555555555555511555555555555555555555555555111555555555525d1150001111100000000000000001000001100012225555dddd55510155555d55dddd5555555555555551155555555555555555555555555511155555555555dd015000122210000010000000000100000220002555555555dd55510155555d55dddddd5dd55555dddd511555555555555555555555555555111555d555555dd11150001222100000000000000001000002200025555555dddddd5101555555555555555555555555552115525522522222555522522252211115555555555d5222d0001222100000000001100012000001200025555555dddddd510011110000000000000000000000010000000110001111111110000100001555555555d2552250001221000000112544422524000001200025555555dddddd51000000000000000000000000000000000000000000000000000000000000155555555d525525d00012210000024444442520240000001001255555555555dd510000000000000000000000000000000000000000000000000000000000001555555555225225d000122100000445211100002200000010012555555555555d510000000000000000000000000000000000000000000000000000000000001555555555225515d000122100001110001000002200000000012555555555555d510000000000000000000000000000000000000000000000000000000000001555555555225d11d000122100000000000000001200000000012555555ddd55dd510000000000000000000000000000000000000000000000000000000000001555555555225211d000122100000000011211101100000000012555555ddd5ddd51100000000000000000000000000000000000000000000000000000000000155555555d225115d00012200000011244444255110000000001255555ddd55ddd51000000000000000000000000000000000000000000000000000000000000155555555d525125d00012200000024444444455110000000001255555ddd5555d51000000000000000000000000000000000000000000001000011000000000155555555d525d25d0001210000002444444425211000011000125555555dd555551000000000011000000000000000000000000000000001000000100000000155555555d52dd25d100121012200244522211000100012220012555555dddccccccccc000cccccccccc00ccccccccc000ccccccccccc0000000000110000000155555555d22dd25d0001222224211110000000001000124210125555ddd5ccccccccc001ccccccccccc0cccccccccc000ccccccccccc0000011001111100000155555555d52dd25d1001222222211000011000001000122200125555dd5cccccccccc001cccccccccc00cccccccccc00cccccccccccc0000000001111000000155555555d52dd25d00022222222000000110000010000122001255555d5cccc00000000110000000000000000cccc0000000000cccc00000000111101100000155555555d55dd25d0101222211011001001000001000000000125555555cccc00000000110000000000000000cccc0000000000cccc00000000011000100100155555555d55dd22d0001210000001000001000001000000000122225555ccccc5511001111111000000000000cccc000000000cccc000000000001111101252255555555d55d11dd0001210000000001112211011000000000012225555cccccccc100011cccc100000ccc00cccc000ccccccccccc000000000001111125dd5555555555d55d11dd00012100000012544552100100000000001122555dddcccccccc00011cccc00000cccc00cccc00cccccccccccc000000000001111255dd2252255555d55dd2dd00012100000122211110000000000000000122252dd20ccccccc0001cccc00000cccc000cccc00ccccccccccc000000000000111122252222222255dd55dd2dd0001210000000000000000000000000000012225dd22200ccccc0011cccc0000cccc000cccc00ccccc00cccc0000000000000011222222222221125dd55dd2dd000121000000000000000000000000000011222511115500cccc001cccc0000cccc0000cccc00cccc000cccc00000000000000112112222222210125d55dd2dd100121000000000000000000000000000011222521111111cccc001cccc0000ccc00000cccc00cccc000cccc0000000000000011220011111110012d6256d1dd10012100000000000000000000000000001122255111111cccc000ccccc000cccc00000cccc0cccc000cccc00000000000000011252000011100015d625661dd000121000000000000000000000000000011222cccccccccccc000cccc000ccccccccccccc00cccc000cccc00000cccccccccc5ccccccccccc000ccccccccccdcccc21ccccccc0000000000000000000011222cccccccccccc0000cccc00cccccccccccccc0cccc0000cccc0111cccccccccccdccccccccccc00ccccccccccdccccccccccccc0000100000000000000000112ccccccccccc00000cccc00ccccccccccccccc0cccc000cccc00100cccccccccc0cccccccccccc00cccccccccc0cccccccccccc00000000000000000000000112220000000000001010000010000000000000001000011110000100200000000000700000cccc0001000000000050000000000000000000000000000000001122200000000000110000000110000000000000001000011100001115400000000006000000cccc001100000000002000000000000000000110000000000010112222552111111111000100111000000000001111111111111111101440111111000d77722cccc00d2225dd25dd2d2000122210000000110110000100000110112222555111111110000000110000001111001111001111111111105f4cccc10000ccccccccccc00ccccccccccdccccccc22210000000000000000100000010012222555510011110010001110000001111101111111111111111104f5cccc0000cccccccccccc06cccccccccddccccccccc210000001111111001101000010012222221111101000111110110000001111111111111111111111104fcccc00000ccccccccccc006ccccccccc00ccccccccc210000011111111001111110010012221110000100001101111110000011111111111111011111111104ecccc0000ccccc00cccc000cccc0000000cccc000cccc1111111111111000111111111001111110000000011000011111100011111111111111001111111112ecccc00000cccc000cccc002cccc0000000cccc000cccc0111111110111000111111110001100000000000110000001111100010111111111111111111111102ecccc00500cccc000cccc00cccc0000001cccc00001cccc111000000111000110111111011000000000000000000000111100001111111111111111111101000ccccc0940cccc000cccc000cccc0000000cccc00001cccc100000001111000110011111000000000000000000000000000000011111111111111100110001105cccc00f42cccc000cccc00cccccccccc0cccc000001ccccc10011111111001110011110110000000000000000000000000000010111111111111100110001104cccc00fecccc0000cccc00cccccccccc0cccc0040012cccc1111111111000111000111142000000000000000000000000000001111111111111110011111110cccc00affcccc000cccc00cccccccccc0ccccc0fffe42ccccc111100011101122011111442200100000000000011111001000001111111011100000000111110ef0000fffe000000000000000000000000200009ffffee000011544444555449924444445200000111101001111111110000000111111101100000000000110040000ff99900000000000000000000000200000994effa000004444444445444422544442000000111111000111111110000010111111111111010000000010059449f99990000000000000000002222244424444999999fff9452211111011110001445200000001100001111111511000022111111111111111100000001005499e999940000000000000021000222244424444944449aaaff4100000001111001444200011000ccc0cccc11ccc51cc000220cc111111ccccccc01ccccccc049499efffccccccc00ccc00ccccccc20cccccccc444cc499cccffe1000000111100244220001200ccc0cccc01ccc11ccc00022ccc11111ccccccc00cccccccc0449fffffcccccccccccc10ccccccc222cccccccc44ccc449ccc9ffe211110155154442200012200ccc0ccc000ccc00ccc01022ccc01111ccc000000ccc00ccc054eeffffccc00ccc00cc00ccc000000ccc00000004ccc04ccc009fff42222244144422001112100cc0ccc0000cc00ccc00000ccc00111ccc0000001cc00ccc000e9999fccc000ccc00c00ccc0000005ccc0000000ccc002ccc009ffff424425554520111211210cccccc0000ccc00ccc00000ccc00111ccc001111cccccccc000444999ccc00cccc00000ccc005555ccc0ccccccccccccccc00999fffe42525554200111101210ccccc00010cc00ccc00000ccc00111cccccccc11ccccccc000005444ccc00eccc00d20ccccccccdcccc0ccccc7ccccccccc0099fffffe205445620010110110cccccc0000ccc00ccc00000ccc00111ccccccc11ccc00ccc000000222ccc004ccc0077dcccccccccccc006ccc00ccc000cc00449ffffff9015427d0101150110cc0ccc0000ccc00ccc01000ccc01111ccc000000ccc00ccc010000002ccc04cccc07777ccc000000ccc006cc007cc000ccc00f949ffffee5055166501115010ccc0cccc00ccc00ccc00010ccc00111ccc000000ccc00ccc001100000ccc000ccc006f7ccc000000cccc06ccc00ccc006ccc0677f49fee640111166610111000cc000ccc00ccc00cccccc10cccccc11ccccccc11ccc00ccc001100000cccccccccc06f7ccccccc7cccccccccc07ccc06ccc00767cc244e7e4152155555545000cc000ccc0ccc00ccccccc1ccccccc1cccccccc11cc00ccc0021000000cccccccccc26ecccccccc44cccccccc00ccc006ccc00a7cccf44ef764441100221110000000000000000000000000100000001100000001100011000110000000000000000066770000000d20000000007700066000caaacc7f246f76d210000011000000000000000000000000001000000010000000011000000000000000000000000000f660000000066000000007700066c000ccca7cc7e24ee6611000001000000000000000000000011110000444451111111111100000000000000000000000001d6242222d66666666666c766666cccccccccaa7c776e7e66c1000001000000000000000000001112221100244450110111111100000000000000000000000001d4222214111d6666666d66666cccccccccccccacc7777e66cc00000000000000000000000001121122211122494011111111110000000000000000000000001122100111000001566ddddd6cccccccccccccccaaccfee6666c000000000000000000000000011111122221244442222222222210000000000000000000011210020000000000000126ddd6dccccccccccccccccaad242466dc0000000000000000000000000110111111222444d55ddddddddd50000000000000000000012100000000000000000000ddddd6ccccccccccccccc6aa000566d61111110000100000000000000111000001662449e666666666666100000000000000000011100000000000000000000002d2d6dcccccccccccccc16ad00266dd222222000111000000000000000000000066d449e6666666666661000000000000000000110000000000000000000000001d15ddcccccccc1111116f6102642d2222210001111000000000000000000000666549966666666666610000000000100000011000000000000000000000000001212dd1cccc11111111144110442c222111001111110000000000000000000d6664499e66666666666d00000000016000000100000000000000000000000000001112d11c11111111dd1df6c2622d111122111112110000000000000000001666644eee66666666666d00000000006d000011000000000000000000000000000011111111111111511115f6d1220111222211112221100000000000000000d6666d444e66666666666d0000000000660000100000000000000000000000000000011112dd1111110111115dd5210022222211112221100100000000000000d66666446777666666666d0000000000d61001100000000000000000000000000000001111111111d520112551d6d11122222101112221101555520000000001ddddddddde777766d6666d000000000026200100000000000000000000000000000000010001111d2010111ddd1d6d11222211011112111115ddd50000000002dddddddddd676e676ddddd00000000001d50010000000000000000000000000000000001100111d00000015d661d66d0212110111111111115ddd2000000001ddddddddddddd424e6ddddd10000000001dd1000000000000000000000000000000000000001111100011015d66d1c66121210001111111112555d100000001ddddddddddddddd222ddddddd00000000015dd00000000000000000000000000000000000000111d00001100ddd6d1666d2211000111111111555d5000000005dddddddddddddddd2eddddddd100000000011d10000000000000000000000000000000000000000100000110d66dd16666221000000001000155dd100000001ddddddddddddddddd2dddddddd100000000010000000000000000000000000000000000000000000000000110266661dd6d2100000000000005dddd100000002dddddddddddddddddddddddddd50000000001000000000000000000000000000000000000000000000000012016776006775100000000000015ddd5000000005dddddd6666666666ddddddddddd000000000100000000000000000000000000000000000000000000000000d01776dd1d775100000000001155ddd111000001ddd6666666767766666ddddddddd100000000110000000000000000000000000000000000000000000000000dd066d66dc662000000001015d55544222112224effffff666677776777666dd666d500000000110000000000000000000000000000000000000000000000000dd0d6dd6d0d6100000115555525222422224224effffffffff66766766677776444dd000000001111111221110000000000000000000000000000000000000001505ddd66667000001dddd510244244222224efffffffffffff77777666766641222d1000000012222225ddddd210000000000000000000000000000000000001101ddd66667000005dddd2002444422222effffffffffffffff66776666dddd1222dddd511111222222222ddddd5100000000000000000000000000000000000501d2d6616701001dddd2022242442424efffffffffffffffff6666d22d6676d11dddd2221111221221115ddddddddd100000000000000000000000000000000d11d12d6d67151015555222224422244fffffffffffffffffff6d5ddd666667d1dddd1111111111111125ddddddddd6ddd100000000000000000000000000000d505111d66711001111224222444224ffffffffffffffffffffed666666676662d2d2111111111111015ddddddddddddddd2000000000000000000000000000012011111d6611110000446d2224444ffffffffffffffffffffff677676677676dd221111111111111122d55ddddddddddddd510000000000000000000000000011011110156dd511001e6e6444d4efffffffee4444449effffff666666666677d222111111100110012255dddd225ddddd55dd100000000000000000000000000101111101dddd110024e7764444ffffffffe411000000524eee666666766666222111100000011011255dd5212ddddddd22222000000000000000000000000000001121005dddd211222e76664effffffffff40000000000002666666667666222111100100110112225d5112ddd5dddd2222210000000000000000000000000000125111d66666dd442467ed4ffffffffffff4000000000111d66d6dd66666212111000000100112225212ddd512dddd212222510000000000000000000000000011d515d666666d44424ed04fffffffffffff400000000001d6666266dd666d111100000010112225212ddd112dddddd11222dd10000000000000000000000000112225d666666d222222204ffffffffffffff400000000001666666566d66d1110000001101122222dd52125ddddddd11125ddd2100000000000000000000000211115d666666e2422221049f99effffffffff20000000002dd5666662666d1100000011011222222dd215ddddddddd111225d55225210000000000000000000111102d66666d44244221049e49fffff99ffffe000000000215d6d666dd6dd100000001101122222d521ddddddd2ddd1111221155dddddd21000000000000000111111566666d22444211049e49ff9effffffffe000000005dd6d1ddd65122000000000111122222d22ddddddd22ddd201111155555555ddd1000000000000000111100666666dd22420210494ef99ffffffffff64000000dd66d2dd66ddd200000000011112222222ddddddd21dddd21110122222255555510000000000000001111006666666d212224204424999ffffffffffff4000016d21d66641d2d100000000011122222225ddddd5215dddd2010111122222222551000000000000000011000666666d21001022252224e9effffffff9fffe00025dd2dd5d22d65100000000111112222225dddd521dddddd2001111111111221221000000000000000000000666666d10000001125224e4effeffff9efff7f50225dd4421dd215100000000110122222255dd55215dddddd500101111011222122100000000000000000000066666666d110000005224429f99f9999fffffff244dd215d66d221000000000111122222225dd5225ddddddd500011110011111122000000000000000000000066666666666dd51112522554f9f9249ffffffff6d5112d6d212dd200000000001012222522552225ddddddddd10011110111111111100000000000000000000066666666666666666d222224999229ffffffffff6212d52221d6500000000000001222252255222dddddddddd100110011111111100000000000000000000000666666666666666d2110022544424effeffffffff2125212222210000000000000112222222222ddddddddddd1010001101111110000000000000000000000006666666666666d221000002244524ffeffffffff7f21112dd21110000000000000112222222225d5ddddddddd2110011101111000000000111000000000000006666666666666d22100000005422599eefffffffffe1111112221000000000000001122222225555555d5dd25510011111110000010000010000000000000000666666666666666d111000000522254efeeffffffff41101111200000000000000011222122225555552552155101111110000011100001100000000000001006666666666666666dd11000000220549a9ffffffffffe00111110000000000000001112212522255552551125510000010000001100000010000000000000000666666666666666666d1110000020249fffffff9fffff50110000000000000000000112222222222222211155d1000000000000000000001000000000000000066666666666666666666d1110000112494444449fffffe0000000000000000000000111222222222222112555210000000000101110000000000000000000000666666666666666666666d1111000102422224efffffff6ddd55ddddd110000000000111122222222522551100000000000000111100000010000000000000006666666666666666666666621100000022224effffffff77666666666666d1000000011111222222222511000000001111111000000000100000000000000000666666666666666666666666d21000000254e9fffffffffff6666666666666d21100001111122121111100011222222255555555210000100000010000000000666666666666666666666666666d1010005e44ffffffffffff6666666666666d111000111111111111100112221222222222255dd5100000000000000000000066666666666666666666666666666d1100054efffffffffffff666666666666d111000011111111111011222112222222222222111000000110000000000000066666666666666666666666666666662100049fffffffffffe26666666666666d11000001111111111112111122111122222211000000000000000000000000066666666666666666666666666666666d100249ffffe4e77777777777766666665110000001111111111111122111222221111011110000000000000000000006666666666666666666666666666666666d1004eff42d777777777777777ee766d11100000111011111111111111121111111111111000000100000000000000666666666666666666666666666666666666d004e5004677777777ee7fee6e6766d11000000111111111111111111110011111111110000000000000000000006666666666666666666666666666666666666d102000246777777647764242446ed210000001111111111111111111100111111111100000000000000000000066666666666666666666666666666666666666610000222e777764677e2e442e22d5100000011001111111011111111111111111111000100000000000000000"

  for i=0,#img+1 do
    local chr=sub(img,i+1,i+1)
    pset(i%128,
    	flr(i/128),
	   	convert_hex2num(chr))
  end
end

local str2hex_table={}
str2hex_table["0"]=0
str2hex_table["1"]=1
str2hex_table["2"]=2
str2hex_table["3"]=3
str2hex_table["4"]=4
str2hex_table["5"]=5
str2hex_table["6"]=6
str2hex_table["7"]=7
str2hex_table["8"]=8
str2hex_table["9"]=9
str2hex_table["a"]=10
str2hex_table["b"]=11
str2hex_table["c"]=12
str2hex_table["d"]=13
str2hex_table["e"]=14
str2hex_table["f"]=15

function convert_hex2num(value)
	return str2hex_table[value]
end




---config app state

cfg = {
  music = true
}

---override p8 loop
function config_init()
  cfg = {
    cursor = 1,
    level = 1,
    music = true
  }

  _update = config_update
  _draw = config_draw
end

---update config menu
function config_update()
  --move cursor
  if(btnp(ƒ) and cfg.cursor < 4) then
    sfx(8)

    cfg.cursor += 1

  elseif(btnp(”) and cfg.cursor > 1) then
    sfx(8)

    cfg.cursor -= 1
  end

  --level select
  if(cfg.cursor == 1) then
    if(btnp(‘)) then
      sfx(8)

      cfg.level += 1

    elseif(btnp(‹) and cfg.level > 1) then
      sfx(8)

      cfg.level -= 1

    end

  --level music
  elseif(cfg.cursor == 2) then
    if(btnp(‹) or btnp(‘)) then
      sfx(8)

      cfg.music = not cfg.music
    end

  --save config
  elseif(cfg.cursor == 3) then
    if(btnp(Ž)) then
      game_init()
    end

  --cancel
  elseif(cfg.cursor == 4) then
    if(btnp(Ž)) then
      title_init()
    end
  end
end

---draw config menu
function config_draw()
	cls()
  camera()

  local cursor = (cfg.cursor * 7) + 7

  if(cfg.cursor >= 3) then
    cursor = (cfg.cursor * 7) + 14
  end

  print('config menu')

  --cursor
  print('', 0, cursor, 7)

  --menu options
  print('level: '..tostr(cfg.level), 8, 14, 7)

  if(cfg.music) then
    print('music: on', 8, 21, 7)
  else
    print('music: off', 8, 21, 7)
  end

  print('start game', 8, 35, 7)
  print('cancel', 8, 42, 7)
end



---game app state

---initialize game app state
function game_init()
  gameclock = 0

  _update = game_running_update
  _draw = game_running_draw

  camera_init()
  level:init()

  for table in all({e, p, powerups, ptflags, hud_dcors}) do
    for actor in all(table) do
      del(table, actor)
    end

    if(type(table.init) == 'function') then
      table:init()
    end
  end

  music(11, 0, 11)

  _update()
end

---update game running state
function game_running_update()
  if(p[1].lives == 0 and p[1].state == 'dead') then
    music(-1, 8000)
    --i forgot why but this
    --was originally 1
    --see in case
    --something breaks
    level.sclock = 0
    level.spawnrate = 2
    level.etospawn = 50

    _update = game_over_update
    _draw = game_over_draw
    return
  end

  level:update()
  e:update()
  p[1]:update()
  powerups:update()
  ptflags:update()

  gameclock += 1
end

---draw game app state
function game_running_draw()
  cls()
  camera_follow()

  map(level.map)

  e:draw()
  p[1]:draw()
  ptflags:draw()
  powerups:draw()

  level:draw()

  hud_draw()
end

---update game over state
function game_over_update()
  if(level.sclock >= 300 and (p[1].b4 or p[1].b5)) then
    title_init()
  end

  if(level.etospawn > 0 and
     level.sclock % level.spawnrate == 0
  ) then
    e:spawn()
    level.etospawn -= 1
  end
  e:update()

  p[1]:get_input()
  p[1]:update()

  level.sclock += 1
  gameclock += 1
end

--draw game over state
function game_over_draw()
  cls()
  camera_follow()

  map(level.map)

  p[1]:draw()
  e:draw()

  print_centered('game over!', cam.x, cam.y - 7, 7, true)
  print_centered('today is a good day to die.', cam.x, cam.y, 7, true)
  print_centered('your score: '..tostr(p[1].score), cam.x, cam.y + 7, 7, true)
end





-->8
---models
---actor base class

--store the default actors table
actors = {
  state = 'idle',
  sclock = 0,
  states = {idle = {}},
  x = 0,
  y = 0,
  xdir = 1,
  ydir = 1,
  speed = 1,
  rise = 8,
  cors = {}
}

---actors class constructor
function actors:new(o)
  local actor = o or {}
  setmetatable(actor, self)
  self.__index = self

  return actor
end




---players class model
p = actors:new()

---players class constructor
function p:new(o)
  local player = o or actors:new(o)
  setmetatable(player, self)
  self.__index = self

  player.pnum = #p

  player.cors = {}
  player.dcors = {}

  return player
end





-->8
---controllers
---global controller functions

---get map cel
function cel(n)
  return flr(n/8)
end

---check if map tile is solid
function solid(x, y)
  local tile = mget(cel(x), cel(y))

  return fget(tile,0)
end

---gravitational acceleration
function gravity(clock, m)
  local m = m or 1

  g = ceil((clock/2)^2) * m

  if(clock == 2) then
    return 2
  else
    return g
  end
end




---actors class controller

---change actor state
function actors:change_state(state)
  self.state = state
  self.sclock = 0

  self:update_state()
end

---update coroutines
function actors:update_cors(cors)
  for cor in all(cors) do
    if(costatus(cor) == 'suspended') then
      coresume(cor)
    elseif(costatus(cor) == 'dead') then
      del(cors, cor)
    end
  end
end

--actor collision coordinates
function actors:get_xmin()
  return self.x + self.hitbox.ox
end

function actors:get_xmax()
  return self.x + self.hitbox.ox + self.hitbox.w
end

function actors:get_ymin()
  return self.y + self.hitbox.oy
end

function actors:get_ymax()
  return self.y + self.hitbox.oy + self.hitbox.h
end

---check x-axis map collision
function actors:map_coll_x(x,y,w,h,xdir)
  local x = x or self.x
  local y = y or self.y
  local w = w or self.hitbox.w
  local h = h or self.hitbox.h
  local xdir = xdir or self.xdir

  local cx = x + self.hitbox.ox
  local cy = y + self.hitbox.oy

  if(xdir == 1) then
    cx = cx + w - 1
  end

  local inc = 1

  if(h ~= 8) then
    if(h % 8 == 0) then
      inc = 8
    elseif(h < 8 and h % 2 == 0) then
      inc = h
    elseif(h > 8 and h % 6 == 0) then
      inc = 6
    elseif(h > 8 and h % 4 == 0) then
      inc = 4
    elseif(h > 8 and h % 2 == 0) then
      inc = 2
    end
  end

  for i=cy, cy + h - 1, inc do
    if(solid(cx,i) or solid(cx,i+inc-1)) then
      return true
    end
  end

  return false
end

---check y-axis map collision
function actors:map_coll_y(x,y,w,h,ydir)
  local x = x or self.x
  local y = y or self.y
  local w = w or self.hitbox.w
  local h = h or self.hitbox.h
  local ydir = ydir or self.ydir

  local cx = x + self.hitbox.ox
  local cy = y + self.hitbox.oy

  if(ydir == 1) then
    cy = cy + h - 1
  end

  local inc = 1

  if(w ~= 8) then
    if(w % 8 == 0) then
      inc = 8
    elseif(w < 8 and w % 2 == 0) then
      inc = w
    elseif(w > 8 and w % 6 == 0) then
      inc = 6
    elseif(w > 8 and w % 4 == 0) then
      inc = 4
    elseif(w > 8 and w % 2 == 0) then
      inc = 2
    end
  end

  for i=cx, cx + w - 1, inc do
    if(solid(i,cy) or solid(i+inc-1,cy)) then
      return true
    end
  end

  return false
end

---get altitude
function actors:get_altitude()
  for i=self.y, 127, 8 do
    local c = self:map_coll_y(nil, i + 1, nil, nil, 1)

    if(c == true) then
      local ground = cel(i + self.hitbox.oy + self.hitbox.h) * 8
      --altitude
      return ground - self:get_ymax()
    end
  end

  return 128
end

---aabb sprite collision
function actors:coll_aabb(actor)
  local l = self
  local r = actor

  --set leftmost actor
  if(l.x > r.x) then
    l, r = r, l
  end

  local l_xmin = l:get_xmin()
  local l_xmax = l:get_xmax()
  local l_ymin = l:get_ymin()
  local l_ymax = l:get_ymax()

  local r_xmin = r:get_xmin()
  local r_xmax = r:get_xmax()
  local r_ymin = r:get_ymin()
  local r_ymax = r:get_ymax()

  --check hitbox overlap
  if(l_xmin < r_xmax and
      l_xmax > r_xmin and
      l_ymin < r_ymax and
      l_ymax > r_ymin
  ) then
    return true,
      r_xmin,
      max(l_ymin, r_ymin),
      min(l_xmax, r_xmax),
      min(l_ymax, r_ymax)
  end
end

---move actor left/right
function actors:movex(dx)
  --if(dx and dx ~= 0) then
    --assert((dx > 0 and self.xdir == 1) or (dx < 0 and self.xdir == -1), "can't move in opposite direction of xdir. "..'dx:'..dx..', xdir:'..self.xdir)
  --end

  local dx = dx or (self.speed * self.xdir)
  local c = self:map_coll_x(self.x + dx, self.y)

  if(c == false) then
    return dx
  end

  local inc = self.xdir * -1

  for i = dx + inc, 0, inc do
    c = self:map_coll_x(self.x + i, self.y)

    if(c == false) then
      return i
    end
  end

  return 0
end

---move actor up/down
function actors:movey(dy)
  --if(dy and dy ~= 0) then
    --assert((dy > 0 and self.ydir == 1) or (dy < 0 and self.ydir == -1), "can't move in opposite direction of ydir"..'dy:'..dy..', ydir:'..self.ydir)
  --end

  local dy = dy or (self.speed * self.ydir)
  local c = self:map_coll_y(self.x, self.y + dy)

  if(c == false) then
    return dy
  end

  local inc = self.ydir * -1

  for i = dy + inc, 0, inc do
    c = self:map_coll_y(self.x, self.y + i)

    if(c == false) then
      return i
    end
  end

  return 0
end

---fall distance
function actors:fall(m)
  assert(self.altitude, 'altitude is not set')

  local dy = gravity(self.sclock, m)

  if(dy > self.altitude) then
    return self.altitude
  end

  return dy
end

---jump distance
function actors:jump(rise, m)
  local rise = rise or self.rise
  local decel = gravity(self.sclock, m)

  if(decel >= rise) then
    return 0
  else
    return -(rise - gravity(self.sclock))
  end
end

---spritesheet animation
function actors:set_sprite(sprites, clock)
  local sprites = sprites or self.states[self.state].sprites
  local clock = clock or self.sclock

  if(#sprites.frames == 1) then
    return sprites.frames[1], sprites.frames[1].hitbox
  end

  local d = sprites.lpf * #sprites.frames
  local aclock = 0
  local f = 0

  if(clock == 0 and sprites.r) then
    sprites.r = false
  end

  if(not sprites.rev) then
    aclock = clock % d
    f = flr((aclock / d) * #sprites.frames) + 1

  elseif(sprites.rev) then
    local rframes = (#sprites.frames * 2) - 2
    local rd = sprites.lpf * rframes

    aclock = clock % rd

    if(not sprites.r) then
      f = flr((aclock / d) * #sprites.frames) + 1

      if(clock > 0 and aclock == (d - 1)) then
        sprites.r = true
      end

    else
      f = abs(flr((aclock / rd) * rframes) - (#sprites.frames * 2) + 1)

      if(f == 2 and aclock == (rd - 1)) then
        sprites.r = false
      end
    end
  end

  return sprites.frames[f], sprites.frames[f].hitbox
end




---players class controllers





-->8
---views
---actors class views

---draw the actor to the screen
function actors:draw_sprite()
  if(type(self.sprite) == 'number') then
    local flip_x = self.xdir == -1

    spr(self.sprite,
        self.x,
        self.y,
        1,
        1,
        flip_x,
        false
    )
  elseif(type(self.sprite == 'table')) then
    local flip_x = self.sprite.flip_x or self.xdir == -1
    local flip_y = self.sprite.flip_y
    local dw = self.sprite.dw or self.sprite.sw
    local dh = self.sprite.dh or self.sprite.sh

    sspr(self.sprite.sx,
         self.sprite.sy,
         self.sprite.sw,
         self.sprite.sh,
         self.x,
         self.y,
         dw,
         dh,
         flip_x,
         flip_y
    )
  end
end





-->8
---demo models
---game level model

level = {
  map = {
    celx = 0,
    cely = 0,
    sx = 0,
    sy = 0,
    celw = 24,
    celh = 16
  }
}

---initialize level
function level:init()
  level.state = 'start'
  level.sclock = 0
  level.current = cfg.level or 1
  self:get_difficulty()
  level.music = cfg.music
end

---calculate difficulty
function level:get_difficulty()
  self.spawnrate = max(45, 60 - (self.current * 2))
  self.maxspeed = min(4, max(1, self.current / 3))
  self.etospawn = min(50, max(10, self.current * 5))
  self.eremaining = self.etospawn
  self.tnt = min(.25, self.current * .03)
  self.powerups = 1/900
  self.bouncy = min(.5, self.current * .04)
  self.lead = .1
end





---player 1 model

--describe default player properties
p.speed = 2

p.defaulthitbox = {
  w = 6,
  h = 16,
  ox = 5,
  oy = 0
}

p.states= {
  idle = {
    sprites = {
      lpf = 1,
      sheet = true,
      frames = {
        {
          sx = 0,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        }
      }
    }
  },
  jumping = {
    sprites = {
      lpf = 1,
      frames = {
        {
          sx = 64,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        }
      }
    }
  },
  running = {
    sprites = {
      lpf = 5,
      rev = true,
      frames = {
        {
          sx = 16,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        },
        {
          sx = 32,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        },
        {
          sx = 48,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        }
      }
    }
  },
  sliding = {
    sprites = {
      lpf = 1,
      frames = {
        {
          sx = 112,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = {
            w = 14,
            h = 14,
            ox = 1,
            oy = 2
          }
        }
      }
    }
  },
  hit = {
    sprites = {
      lpf = 1,
      frames = {
        {
          sx = 80,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = p.defaulthitbox
        }
      }
    }
  },
  drinking = {
    sprites = {
      lpf = 5,
      frames = {
        {sx=32,sy=32,sw=16,sh=16,hitbox = p.defaulthitbox},
        {sx=48,sy=32,sw=16,sh=16,hitbox = p.defaulthitbox}
      }
    }
  },
  berserker = {
    sprites = {
      lpf = 1,
      frames = {
        {sx=64,sy=32,sw=16,sh=16,hitbox = p.defaulthitbox}
      }
    }
  },
  dead = {
    sprites = {
      lpf = 1,
      frames = {
        {
          sx = 96,
          sy = 0,
          sw = 16,
          sh = 16,
          hitbox = {
            w = 16,
            h = 5,
            ox = 0,
            oy = 9
          }
        }
      }
    }
  }
}

p.states.falling = {
  sprites = p.states.jumping.sprites
}

--instantiate player 1

---initialize player
function p:init()
  local newplayer = add(p, p:new({
    lives = 3,
    score = 0,
    prevscore = 0,
    x = 0,

    state = 'idle',
    sclock = 0
  }))

  newplayer.sprite, newplayer.hitbox = newplayer:set_sprite()
  newplayer:spawn()
end

---spawn player
function p:spawn()
  self.health = 100
  self.powerup = nil
  self.hits = nil
  self.y = 0
  self.altitude = self:get_altitude()
end




---enemies class model

--store default enemy table
e = actors:new({
  rise = 10,
  aclock = 0,
  sprites = {
    lpf = 3,
    frames = {
      {sx=16,sy=16,sw=16,sh=16},
      {sx=32,sy=16,sw=16,sh=16},
      {sx=48,sy=16,sw=16,sh=16},
      {sx=64,sy=16,sw=16,sh=16},
      {sx=80,sy=16,sw=16,sh=16},
      {sx=96,sy=16,sw=16,sh=16},
      {sx=112,sy=16,sw=16,sh=16}
    }
  },
  aclock = 0,
  hitbox = {
    w = 9,
    h = 10,
    ox = 3,
    oy = 6
  },
  states = {
    exploding = {
      sprites = {
        lpf = 1,
        frames = {
          {
            sx = 0,
            sy = 32,
            sw = 32,
            sh = 32,
            hitbox = {
              w = 28,
              h = 28,
              ox = 2,
              oy = 2
            }
          },
          {
            sx = 0,
            sy = 32,
            sw = 32,
            sh = 32,
            dw = 48,
            dh = 48,
            hitbox = {
              w = 42,
              h = 42,
              ox = 3,
              oy = 3
            }
          }
        }
      }
    }
  }
})

--initialize enemies
function e:init()
  self.cors = {}
end

---enemies class contructor
function e:new(o)
  local enemy = o or actors:new(o)
  setmetatable(enemy, self)
  self.__index = self

  enemy.cors = {}
  enemy.dcors = {}

  return enemy
end

---spawn enemies
function e:spawn(variant, arg)
  local x = 0
  local xdir = 1

  --spawn near player 1
  if(rnd() > .5) then
    x = min(((level.map.celx + level.map.celw) * 8) - 16, p[1].x + rnd(64))
  else
    x = max(level.map.celx * 8, p[1].x - rnd(64))
  end

  --track player
  if(x > p[1].x) then
    xdir = -1
  end

  --properties
  local props = {
    x = x,
    y = 0,
    firstfall = true,
    xdir = xdir,
    speed = max(1, rnd(level.maxspeed))
  }

  --variants
  if(variant == 'tnt') then
    props.tnt = 90

  elseif(variant == 'bouncy') then
    local arg = arg or 1

    props.bouncy = ceil(rnd(arg))

    props.rise = min(12, 13 - (arg * arg))
    props.speed = max(.5,rnd())

  elseif(variant == 'lead') then
    props.lead = true
    props.rise = 0
    props.speed = .5
  end

  add(self.cors, cocreate(function()
    for i=1, ceil(rnd(level.spawnrate)) do
      yield()
    end

    add(e, e:new(props))
  end))
end

---delete enemies
function e:delete()
  for enemy in all(self) do
    if(enemy.x <= -(enemy.sprite.sw) or
       enemy.x >= (level.map.celx + level.map.celw) * 8 or
       enemy.y >= (level.map.cely + level.map.celh) * 8 or
       (enemy.state == 'exploding' and enemy.sclock > 30)
    ) then
      del(self, enemy)
    end
  end
end




---point flag class

--store the default table
ptflags = actors:new()

---point flag class constructor
function ptflags:new(o)
  --assert(o, 'no point data given')
  local ptflag = o
  setmetatable(ptflag, self)
  self.__index = self

  ptflag.cors = {cocreate(function()
    for i=1, 8 do
      ptflag.y -= 1
      yield()
    end
  end)}

  return ptflag
end

---delete flags
function ptflags:delete()
  for ptflag in all(self) do
    if(costatus(ptflag.cors[1]) == 'dead') then
      del(self, ptflag)
    end
  end
end



---powerups base class
powerups = actors:new({
  sprite = {sx=0,sy=24,sw=8,sh=8},
  hitbox = {w=6,h=5,ox=1,oy=2}
})

---initialize powerups
function powerups:init()
  powerups.lastspawn = 0
end

---powerups class constructor
function powerups:new(o)
  local powerup = o or actors:new(o)
  setmetatable(powerup, self)
  self.__index = self

  return powerup
end

---spawn powerups
function powerups:spawn()
  local x = 0

  self.lastspawn = gameclock

  --spawn near player 1
  if(rnd() > .5) then
    x = min(((level.map.celx + level.map.celw) * 8) - 16, p[1].x + rnd(64))
  else
    x = max(level.map.celx * 8, p[1].x - rnd(64))
  end

  local props = {
    x = x,
    bubbles = {}
  }

  if(rnd() < .30) then
    props.variant = 'health'
  else
    props.variant = 'berserker'
  end

  add(powerups, self:new(props))
end





-->8
---demo controllers
---game level controllers

---update level
function level:update()
  self:update_state()

  if(p[1].state ~= 'dead') then
    self.sclock += 1
  end
end

---pause music
function level:pause_music()
  if(stat(24) > 11 and
     stat(24) < 32) then
    level.music = stat(24)
    music(-1)
  end
end

---resume music
function level:resume_music()
  if(type(level.music) == 'number') then
    music(level.music, 3000, 11)
  else
    music(12, 0, 11)
  end
end

---update level state
function level:update_state()
  if(self.state == 'start') then
    self:update_start()
    self.draw = self.draw_start

  elseif(self.state == 'running') then
    self:update_running()
    self.draw = self.draw_running

  elseif(self.state == 'over') then
    self:update_over()
    self.draw = self.draw_over
  end
end

function level:update_start()
  if(self.sclock == 90) then
    sfx(13)

    actors.change_state(self, 'running')
    return

  elseif(self.sclock % 30 == 0) then
    sfx(12)
  end

  if(level.music and
     stat(24) == 11 and
     stat(26) >= 210
  ) then
    self:resume_music()
  end
end

function level:update_running()
  if(self.eremaining == 0 and
     self.etospawn == 0 and
     #e == 0
  ) then
    self:pause_music()

    actors.change_state(self, 'over')
    return
  end

  self:spawn_enemies()
  self:spawn_powerups()
end

function level:update_over()
  if(self.sclock == 0) then
    music(11, 0, 11)

  elseif(self.sclock == 90) then
    self.current += 1

    self:get_difficulty()

    actors.change_state(self, 'start')
    return
  end
end

---spawn enemies
function level:spawn_enemies()
  if(p[1].state ~= 'dead' and
     self.etospawn > 0 and
     self.sclock % self.spawnrate == 0
  ) then

    if(self.current == 1) then
      e:spawn()
      self.etospawn -=1

    elseif(self.current == 2) then
      if(rnd() < self.bouncy) then
        e:spawn('bouncy')
        self.etospawn -= 1
      else
        e:spawn()
        self.etospawn -=1
      end

    elseif(self.current == 3) then
      if(rnd() < self.bouncy) then
        e:spawn('bouncy')
        self.etospawn -= 1
      elseif(rnd() < self.lead) then
        e:spawn('lead')
      else
        e:spawn()
        self.etospawn -=1
      end

    elseif(self.current == 4) then
      if(rnd() < self.bouncy) then
        e:spawn('bouncy')
        self.etospawn -= 1
      elseif(rnd() < self.lead) then
        e:spawn('lead')
      elseif(rnd() < self.tnt) then
        e:spawn('tnt')
      else
        e:spawn()
        self.etospawn -=1
      end

    elseif(self.current == 5) then
      if(rnd() < self.bouncy) then
        e:spawn('bouncy', 2)
        self.etospawn -= 1
      elseif(rnd() < self.lead) then
        e:spawn('lead')
      elseif(rnd() < self.tnt) then
        e:spawn('tnt')
      else
        e:spawn()
        self.etospawn -=1
      end

    elseif(self.current > 5) then
      if(rnd() < self.bouncy) then
        e:spawn('bouncy', 3)
        self.etospawn -= 1
      elseif(rnd() < self.lead) then
        e:spawn('lead')
      elseif(rnd() < self.tnt) then
        e:spawn('tnt')
      else
        e:spawn()
        self.etospawn -=1
      end
    end
  end
end

function level:spawn_powerups()
  if(level.state == 'running' and
     rnd() < self.powerups and
     gameclock - powerups.lastspawn > 900
  ) then
    powerups:spawn()
  end
end



---player 1 controllers

---update player 1 data
function p:update()
  self:update_cors(self.cors)

  self:get_input()

  self.altitude = self:get_altitude()

  self.hits = self:get_hits(e)

  self.powerup = self:get_hits(powerups)

  self:update_state()

  self:bonus_lives()

  self.sclock += 1
end

---get player input
function p:get_input()
  self.b4_hold = self.b4

  if(self.state ~= 'falling') then
    self.b5_hold = self.b5
  else
    self.b5_hold = false
  end

  for i=0, 5 do
    self['b' .. tostr(i)] = btn(i, self.pnum)
  end
end

---check sprite collision
function p:get_hits(actors)
  local hits = {}

  for i=1, #actors do
    local hit, xmin, ymin, xmax, ymax = self:coll_aabb(actors[i])

    if(hit) then
      if(actors == e and
         actors[i].state ~= 'dead'
      ) then
        add(hits, {
          id = i,
          xmin = xmin,
          ymin = ymin,
          xmax = xmax,
          ymax = ymax
        })

      elseif(actors == powerups) then
        return i
      end
    end
  end

  if(#hits > 0) then
    return hits
  end
end

---override actors:movex
function p:movex(dx)
  local dx = dx or (self.speed * self.xdir)
  local c = self:map_coll_x(self.x + dx, self.y)

  if(c == false and
     self.x + dx >= level.map.celx * 8 and
     self.x + dx <= (level.map.celx + level.map.celw) * 8 - self.sprite.sw
  ) then
    return dx
  end

  local inc = self.xdir * -1

  for i = dx + inc, 0, inc do
    c = self:map_coll_x(self.x + i, self.y)

    if(c == false and
       self.x + i >= level.map.celx * 8 and
       self.x + i <= (level.map.celx + level.map.celw) * 8 - self.sprite.sw
      ) then
      return i
    end
  end

  return 0
end
---invincibility
function p:invincibility(t)
  local t = t or 60

  self.hits = nil
  self.invincible = true

  add(self.cors, cocreate(function()
    for i=1, t do
      self.invincible = true
      yield()
    end

    self.invincible = nil
  end))
end

--oneup bonus
function p:bonus_lives()
  --track oneup bonus
  if(not self.oneup and
    (self.score - self.prevscore) + (self.prevscore % 10000) >= 10000
  ) then
    add(self.cors, cocreate(function()
      self.oneup = true
      self.lives += 1

      sfx(49)

      repeat
        yield()
      until((self.score - self.prevscore) + (self.prevscore % 10000) < 10000)

      self.oneup = nil
    end))

    add(hud_dcors, cocreate(function()
      for i=1, 60 do
        if(i % 10 < 5) then
          print_shadow(p[1].score, cam.x + 25, 1, 11)
          print_shadow('X'..tostr(p[1].lives), cam.x + 120, 1, 11)
        end

        yield()
      end
    end))
  end
end

---controls player 1's state
function p:update_state()
  self.sprite, self.hitbox = self:set_sprite()

  if(self.state == 'idle') then
    self:state_idle()
  elseif(self.state == 'running') then
    self:state_running()
  elseif(self.state == 'falling') then
    self:state_falling()
  elseif(self.state == 'jumping') then
    self:state_jumping()
  elseif(self.state == 'sliding') then
    self:state_sliding()
  elseif(self.state == 'hit') then
    self:state_hit()
  elseif(self.state == 'drinking') then
    self:state_drinking()
  elseif(self.state == 'berserker') then
    self:state_berserker()
  elseif(self.state == 'dead') then
    self:state_dead()
  end
end

---idle state
function p:state_idle()
  if(self:get_hit_state()) then
    self:change_state('hit')
    return
  end

  if(self.powerup) then
    self:change_state('drinking')
    return
  end

  if(self.altitude > 0) then
    self:change_state('falling')
    return
  end

  if(self.b0 or self.b1) then
    self:change_state('running')
    return
  end

  if((self.b4 and not self.b4_hold) and
    self.altitude == 0
  ) then
    self:change_state('jumping')
    return
  end

  if(self.b5 and not self.b5_hold) then
    self:change_state('sliding')
    return
  end
end

---running state
function p:state_running()
  if(self:get_hit_state()) then
    self:change_state('hit')
    return
  end

  if(self.powerup) then
    self:change_state('drinking')
    return
  end

  if(self.altitude > 0) then
    self:change_state('falling')
    return
  end

  if(not self.b0 and not self.b1) then
    self:change_state('idle')
    return
  elseif(self.b0) then
    self.xdir = -1
    self.x += self:movex()
  elseif(self.b1) then
    self.xdir = 1
    self.x += self:movex()
  end

  if((self.b4 and not self.b4_hold) and
    self.altitude == 0
  ) then
    self:change_state('jumping')
    return
  end

  if(self.b5 and not self.b5_hold) then
    self:change_state('sliding')
    return
  end
end

---falling state
function p:state_falling()
  if(self:get_hit_state()) then
    self:change_state('hit')
    return
  end

  if(self.powerup) then
    self:change_state('drinking')
    return
  end

  if(self.altitude == 0) then
    self:change_state('idle')
    return
  end

  if(self.sclock > 0) then
    if(self.b0) then
      self.xdir = -1
      self.x += self:movex()
    elseif(self.b1) then
      self.xdir = 1
      self.x += self:movex()
    end
  end

  self.ydir = 1
  self.y += self:fall()
end

---jumping state
function p:state_jumping()
  if(self:get_hit_state()) then
    self:change_state('hit')
    return
  end

  if(self.powerup) then
    self:change_state('drinking')
    return
  end

  if(not self.b4) then
    self:change_state('falling')
    return
  end

  if(self.b0) then
    self.xdir = -1
    self.x += self:movex()
  elseif(self.b1) then
    self.xdir = 1
    self.x += self:movex()
  end

  self.ydir = -1

  local dy = self:movey(self:jump())

  if(dy == 0) then
    self:change_state('falling')
    return
  else
    self.y += dy
  end
end

---sliding state
function p:state_sliding()
  if(not self.b5 or
    (self.sclock > 8 and
    self.b5_hold)
  ) then
    self:change_state('idle')
    return
  end

  if(self.b4) then
    self:change_state('jumping')
    return
  end

  if(self.powerup) then
    self:change_state('drinking')
    return
  end

  --test next move
  local x = self.x
  local dx = self.xdir * self.speed * 2

  for i=0, dx, self.xdir do
    self.x = x + i
    self.hits = self:get_hits(e)

    if(self.hits and
       #self.hits > 0
    ) then
      for k,v in pairs(self.hits) do
        if(e[v.id].lead) then
          self.x = x
          self.x += self:movex(i + -(self.xdir))
          return

        elseif(e[v.id].state ~= 'dead' and
          not e[v.id].justhit and
          e[v.id].altitude <= 8 and
          ((self.xdir == 1 and e[v.id]:get_xmax() >= self:get_xmax()) or
          (self.xdir == -1 and e[v.id].x <= self.x))
        ) then
          e[v.id]:hitby(self.pnum)

        elseif(e[v.id].state ~= 'dead' and
          not e[v.id].justhit and
          not self.invincible and
          ((self.xdir == 1 and e[v.id].x <= self.x + 8) or
          (self.xdir == -1 and e[v.id].x >= self.x + 8))
        ) then
          self.x = x
          self.x += self:movex(i)

          self:change_state('hit')
          return
        end
      end
    end
  end

  self.x = x
  self.x += self:movex(dx)
end

---check if state should
--change to hit state
function p:get_hit_state()
  if(self.hits and
     #self.hits > 0
  ) then
    for k,v in pairs(self.hits) do
      if(e[v.id].lead) then
        if(self.x < e[v.id].x) then
          self.x += self:movex(v.xmin - v.xmax)
        else
          self.x += self:movex(v.xmax - v.xmin)
        end

      elseif(not self.invincible and
        not e[v.id].justhit) then
        return true
      end
    end
  end
end

---hit state
function p:state_hit()
  if(self.sclock == 0) then
    sfx(10)

    self.health -= 20

  elseif(self.sclock > 15) then
    if(self.health <= 0) then
      self:change_state('dead')
      return
    else
      self:invincibility()

      self:change_state('idle')
      return
    end
  end
end

---drinking state
function p:state_drinking()
  if(self.powerup) then
    self.poweredby = powerups[self.powerup].variant

    del(powerups, powerups[self.powerup])
  end

  if(self.altitude > 0) then
    self.ydir = 1
    self.y += self:fall()
  end

  if(self.sclock == 30) then
    if(self.poweredby == 'berserker') then
      self.poweredby = nil

      self:change_state('berserker')
      return

    elseif(self.poweredby == 'health') then
      self.poweredby = nil

      self.health = min(100, self.health + 20)

      self:invincibility()

      add(hud_dcors, cocreate(function()
        local bars = ceil(self.health / 20)

        for j=1, 60 do
          if(j % 10 < 5) then
            print_shadow('spine', cam.x + 66, 1, 11)

            for i=0, bars - 1 do
              rectfill(cam.x + (i * 5) + 87, cam.y + 2, cam.x + (i * 5) + 88, cam.y + 4, 11)
            end
          end

          yield()
        end
      end))

      sfx(49)

      self:change_state('idle')
      return
    end
  end
end

---berserker state
function p:state_berserker()
  if(self.sclock == 30) then
    local t = 150
    local m = 2

    add(self.cors, cocreate(function()
      self.berserker = true

      if(level.music) then
        level:pause_music()
        music(32, 0, 11)
      end

      for i=1, t do
        self.speed = (p.speed * m) - ((m * i) / t)
        yield()
      end

      if(level.music and
        level.state == 'running'
      ) then
        level:resume_music()
      end

      self.speed = ospeed
      self.berserker = nil
    end))

    self:invincibility(150)

    self:change_state('idle')
    return
  end

  if(self.altitude == 0) then
    self.y -= 1
  end

  if(self.altitude > 0) then
    self.ydir = 1
    self.y += self:fall()
  end
end

---dead state
function p:state_dead()
  if(self.altitude > 0) then
    self.ydir = 1
    self.y += self:fall()
  end

  if(self.lives > 0 and self.altitude == 0 and self.sclock > 30) then
    if(self.b4 or self.b5) then
      self:spawn()
      self.lives -= 1

      self:invincibility(90)

      self:change_state('idle')
      return
    end
  end
end




---enemies class controllers

---update enemies
function e:update()
  self:update_cors(self.cors)

  for enemy in all(self) do
    enemy:update_cors(enemy.cors)

    enemy.altitude = enemy:get_altitude()

    enemy:update_state()

    if(enemy.state ~= 'exploding') then
      enemy.sprite = enemy:set_sprite(self.sprites, enemy.aclock)
    else
      enemy.sprite, enemy.hitbox = enemy:set_sprite()
    end

    if(enemy.tnt) then
      enemy.tnt -= 1
    end

    enemy.sclock += 1
    enemy.aclock += 1
  end

  self:delete()
end

---reverse x direction
function e:revx()
  self.xdir *= -1
  self.speed = max(0.5, self.speed - (self.speed / 2))
end

---bounce off level boundary
function e:lvlbounce()
  local xmin = level.map.celx * 8
  local xmax = ((level.map.celw - level.map.celx) * 8) - 16

  if(self.x <= xmin) then
    self.x = xmin
    self:revx()

  elseif(self.x >= xmax) then
    self.x = xmax
    self:revx()
  end
end

---enemy state controllers
function e:update_state()
  if(self.state == 'idle') then
    self:state_idle()
  elseif(self.state == 'falling') then
    self:state_falling()
  elseif(self.state == 'jumping') then
    self:state_jumping()
  elseif(self.state == 'roaming') then
    self:state_roaming()
  elseif(self.state == 'dead') then
    self:state_dead()
  elseif(self.state == 'exploding') then
    self:state_exploding()
  end
end

---idle state
function e:state_idle()
  if(self.altitude > 0) then
    self:change_state('falling')
  end
end

--falling state
function e:state_falling()
  if(self.altitude == 0 and self.rise == 0) then
    self.speed = max(0.5, self.speed - (self.speed / 2))

    if(self.lead) then
      sfx(9)
    end

    self:change_state('roaming')
    return
  end

  self.ydir = 1
  self.y += self:fall()

  if(not self.firstfall) then
    local dx = self:movex()

    if(dx ~= 0) then
      self.x += dx

      self:lvlbounce()

    elseif(dx == 0) then
      self.xdir *= -1
      self.speed = max(0.5, self.speed - (self.speed / 2))
      self.x += self:movex()
    end
  end

  if(self.altitude == 0 and self.rise > 0) then
    self.firstfall = false
    self.rise *= .75
    if(self.rise < 1) then
      self.rise = 0
    end

    self:change_state('jumping')
    return
  end
end

--jumping state
function e:state_jumping()
  if(self.rise == 0) then
    self:change_state('roaming')
    return
  end

  self.ydir = -1

  local dy = self:movey(self:jump())

  if(dy == 0) then
    self:change_state('falling')
    return
  else
    self.y += dy
  end

  local dx = self:movex()

  if(dx ~= 0) then
    self.x += dx

    self:lvlbounce()

  elseif(dx == 0) then
    self.xdir *= -1
    self.speed = max(0.5, self.speed - (self.speed / 2))
    self.x += self:movex()
  end
end

--roaming state
function e:state_roaming()
  if(self.lead) then
    self.x += self.speed * self.xdir
    return
  end

  if(self.altitude > 0) then
    self.rise = min(8, self.altitude / 4)
    self:change_state('falling')
    return
  end

  if(self.tnt and self.tnt <= 0) then
    self:change_state('exploding')
    return
  end

  local dx = self:movex()

  if(dx ~= 0) then
    self.x += dx

    self:lvlbounce()

  elseif(dx == 0) then
    self:revx()
    self.x += self:movex()
  end
end

--exploding state
function e:state_exploding()
  --move to match expolosion
  --sprite frames
  if(self.sclock == 0) then
    self.x -= 8
    self.y -= 6

    cam.shake = 2

    sfx(50)

  elseif(self.sclock == 1) then
    self.x -= 8
    self.y -= 8
  elseif(self.sclock > 1) then
    if(self.sclock % 2 == 0) then
      self.x += 8
      self.y += 8
    else
      self.x -= 8
      self.y -= 8
    end
  end

  local self_i = 0

  for i=1, #e do
    if(e[i] ~= self and
      self:coll_aabb(e[i])
    ) then
      if(e[i].tnt) then
        if(e[i].state ~= 'exploding') then
          e[i]:change_state('exploding')
        end

      elseif(self.sclock <= 5 and
             e[i].state ~= 'dead'
      ) then
        e[i].rise = e.rise
        e[i]:change_state('jumping')
      end
    end
  end
end

---hit by player
function e:hitby(pnum)
  if(self.tnt and
     self.state ~= 'exploding'
  ) then
    self.state = 'exploding'
    self.sclock = 0
    return

  elseif(self.tnt and
    self.state == 'exploding'
  ) then
    return

  elseif(self.bouncy and self.bouncy > 0) then
    self.y = p[pnum+1].y
    self.xdir = p[pnum + 1].xdir
    self.speed = 3
    self.bouncy -= 1
    self.rise = min(12, 13 - (self.bouncy * self.bouncy))

    self.justhit = true
    add(self.cors, cocreate(function()
      repeat
        yield()
      until(not self:coll_aabb(p[pnum+1]))

      self.justhit = nil
    end))

    p[pnum + 1].prevscore = p[pnum + 1].score
    p[pnum + 1].score += 50

    add(ptflags, ptflags:new({
      x = self.x,
      y = self.y,
      pts = 50
    }))

    sfx(51)

    self.state = 'jumping'
    self.sclock = 0
    return

  else
    self.y = p[pnum+1].y
    self.xdir = p[pnum + 1].xdir

    p[pnum + 1].prevscore = p[pnum + 1].score
    p[pnum + 1].score += 100

    add(ptflags, ptflags:new({
      x = self.x,
      y = self.y,
      pts = 100
    }))

    sfx(11)

    self.state = 'dead'
    self.sclock = 0

    level.eremaining -= 1
  end
end

---dead state
function e:state_dead()
  self.x += (self.xdir * 4)
  self.y -= 3
end




---point flag controllers

function ptflags:update()
  for ptflag in all(self) do
    ptflag:update_cors(ptflag.cors)
  end

  self:delete()
end



---powerups controllers

---update powerups
function powerups:update()
  for powerup in all(self) do
    powerup.altitude = powerup:get_altitude()

    powerup:update_state()

    powerup.sclock += 1
  end
end

---update powerups state
function powerups:update_state()
  if(self.state == 'idle') then
    self:state_idle()
  elseif(self.state == 'falling') then
    self:state_falling()
  elseif(self.state == 'decaying') then
    self:state_decaying()
  end
end

---idle state
function powerups:state_idle()
  if(self.altitude > 0) then
    self:change_state('falling')
    return
  end

  if(self.sclock == 30) then
    self:change_state('decaying')
  end
end

---falling state
function powerups:state_falling()
  if(self.altitude == 0) then
    self:change_state('idle')
  end

  self.ydir = 1
  self.y += self:fall(.05)
end

---decaying state
function powerups:state_decaying()
  if(self.sclock >= 90) then
    del(powerups, self)
  end
end




-->8
---demo views
---global view functions

---print centered
function print_centered(str, camx, camy, col, shadow)
  local camx = camx or 0
  local camy = camy or 0
  local col = col or 7

  local x = camx + 64
  local y = camy + 60

  if(shadow) then
    print_shadow(str, x - (#str * 2), y, col)
  else
    print(str, x - (#str * 2), y, col)
  end
end

---print with drop shadow
function print_shadow(str, camx, camy, col, scol)
  local camx = camx or 0
  local camy = camy or 0
  local col = col or 7
  local scol = scol or 1

  print(str, camx + 1, camy + 1, scol)
  print(str, camx, camy, col)
end



---demo actors views

---draw smoke
function actors:draw_smoke(ox, oy, r)
  --smoke
  if(self.sclock % 5 == 0) then
    add(self.dcors, cocreate(function()
      local ox = ox or 0
      local oy = oy or 0
      local r = r or 1
      local x = self.x + ox
      local y = self.y + oy

      for i=1, 20 do
        if(i % 2) then
          y -= .3
          r += .1
          circfill(x, y, r, 7)
        end
        yield()
      end
    end))
  end
end




---demo hud views

hud_dcors = {}

---draw hud
function hud_draw()
  print_shadow('score:'..tostr(p[1].score), cam.x + 1, 1, 7)

  --print health
  print_shadow('spine', cam.x + 66, 1, 7)
  hud_health(cam.x + 85, 1)

  if(level.state == 'running') then
    print_shadow('e:'..tostr(level.eremaining), cam.x + 48, 1, 7)
  end

  --print lives
  spr(32, cam.x + 111, 0)

  print_shadow('X'..tostr(p[1].lives), cam.x + 120, 1, 7)

  actors.update_cors(nil, hud_dcors)
end

---draw health
function hud_health(x, y)
  for i=0, 4 do
    rect(x + (i * 5) + 2, y + 1, x + (i * 5) + 5, y + 5, 1)
    rect(x + (i * 5) + 1, y, x + (i * 5) + 4, y + 4, 7)
  end

  local bars = ceil(p[1].health / 20)

  for i=0, bars - 1 do
    rectfill(x + (i * 5) + 2, y + 1, x + (i * 5) + 3, y + 3, 8)
  end
end



---game level views

---draw level start state
function level:draw_start()
  if(self.sclock > 1 and self.sclock <= 90) then
    print_centered('level '..tostr(level.current), cam.x, cam.y - 7, 7, true)
    print_centered('ready', cam.x, cam.y, 7, true)
    print_centered(tostr(ceil((90 - self.sclock) / 30)), cam.x, cam.y + 7, 7, true)
  end
end

---draw level running state
function level:draw_running()
  if(self.sclock <= 30) then
    print_centered('engage!', cam.x, cam.y, 7, true)
  end
end

---draw level over state
function level:draw_over()
  print_centered('level cleared!', cam.x, cam.y, 7, true)
end



---camera follow player 1
function camera_init()
  cam = {
    x = 0,
    y = 0,
    shake = 0
  }
end

function camera_follow()
  local newx = mid(0, p[1].x - 56, 64)
  local dx = newx - cam.x

  if(dx > 1) then
    cam.x += 2
  elseif(dx < -1) then
    cam.x -= 2
  else
    cam.x = newx
  end

  cam.y = 0

  camera_shake()

  camera(cam.x, cam.y)
end

function camera_shake()
  if(cam.shake > 0) then
    cam.x += cam.shake - (rnd(cam.shake * 2))
    cam.y += cam.shake - (rnd(cam.shake * 2))

    cam.shake *= .9

    if(cam.shake < .1) then
      cam.shake = 0
    end
  end
end



---player 1 views

---draws player 1 to screen
function p:draw()
  if(self.berserker) then
    self:draw_berserker()
  elseif(self.invincible) then
    self:draw_invincible()
  else
    self:draw_sprite()
  end

  self:update_cors(self.dcors)
end

function p:draw_berserker()
  if(self.sclock % 2 == 0) then
    pal(4, 8)

    self:draw_sprite()

    if(self.xdir == 1) then
      self:draw_smoke(5, 4)
    else
      self:draw_smoke(11, 4)
    end

     pal()
  else
    if(self.xdir == 1) then
      self:draw_smoke(5, 4)
    else
      self:draw_smoke(11, 4)
    end

    return
  end

end

function p:draw_invincible()
  if(self.sclock % 2 == 0 and
     self.state ~= 'hit' and
     self.state ~= 'berserker'
  ) then
    return
  else
    self:draw_sprite()
  end
end




---enemies class views

---draw enemies to screen
function e:draw()
  for enemy in all(self) do
    enemy:draw_shadow()

    if(enemy.tnt) then
      enemy:draw_tnt()

    elseif(enemy.bouncy) then
      enemy:draw_bouncy()

    elseif(enemy.lead) then
      pal(12, 13)
      enemy:draw_sprite()

    else
      enemy:draw_sprite()
    end

    enemy:update_cors(enemy.dcors)

    pal()
  end
end

function e:draw_shadow()
  if(self.altitude > 0) then
    local length = max(1, 120 / self.altitude)

    if(length > 6) then
      length = 6
    end

    local ox = (16 / length) + 1

    if(self.xdir == 1) then
      ox += 1
    end

    line(self.x + ox, 119, self.x + ox + length, 119, 1)
  end
end

function e:draw_tnt()
  pal(12, 8)

  self:draw_sprite()

  if(self.state ~= 'exploding') then
    --timer
    local timer = ceil(self.tnt / 30)
    local xmod = 6

    if(self.xdir == -1) then
      xmod = 7
    end

    if(timer == 1) then
      if(self.sclock % 2 == 0) then
        print_shadow(timer, self.x + xmod, self.y + 8, 8)
      else
        print_shadow(timer, self.x + xmod, self.y + 8, 9)
      end
    else
      print_shadow(timer, self.x + xmod, self.y + 8)
    end

    self:draw_smoke(7, 6)
  end
end

function e:draw_bouncy()
  if(self.bouncy == 1) then
    pal(12, 9)
  elseif(self.bouncy == 2) then
    pal(12, 10)
  elseif(self.bouncy > 2) then
    pal(12, 7)
  end

  self:draw_sprite()
  pal()
end



---point flag views

---draw point flags to screen
function ptflags:draw()
  for ptflag in all(ptflags) do
    print_shadow(ptflag.pts, ptflag.x + 1, ptflag.y + 1)
  end
end




---powerups views

---draw to screen
function powerups:draw()
  for powerup in all(self) do
    powerup:draw_state()
  end
end

---draw bubbles
function powerups:draw_bubbles()
  local color = 8

  if(self.variant == 'health') then
    color = 11
  end

  --bubbles
  if(gameclock % 3 == 0) then
    add(self.bubbles, cocreate(function()
      local x = self.x + 3.5 + 1.5 - rnd(3)
      local y = self.y + 3
      local r = 2
      local cstate = self.state
      local sclock = 0

      repeat
        if(cstate == 'falling') then
          y = y - .2 + gravity(sclock, .05)

          if(y > self.altitude + self.hitbox.h) then
            return
          end
        else
          y -= .2
        end

        r -= .1
        sclock += 1

        circfill(x, y, r, color)

        yield()
      until(r <= 0)
    end))
  end

  for bubble in all(self.bubbles) do
    if(costatus(bubble) == 'suspended') then
      coresume(bubble)
    elseif(costatus(bubble) == 'dead') then
      del(self.bubbles, bubble)
    end
  end
end

---draw state
function powerups:draw_state()
  if(self.state ~= 'decaying') then
    self:draw_bubbles()
    self:draw_shiny()
  else
   local blink = ceil((90 - self.sclock) / 720) + 1

    if(self.sclock % blink ~= 0) then
      self:draw_bubbles()
      self:draw_shiny()
    end
  end
end

---draw shinies
function powerups:draw_shiny()
  if(not self.shiny or
     costatus(self.shiny) == 'dead'
  ) then
    self.shiny = cocreate(function()
      --flash
      for i=1, 30 do
        if(i % 10 < 5) then
          pal(11, 10)
        else
          pal(11, 1)
        end

        self:draw_sprite()
        pal()

        yield()
      end

      --shine
      for i=0, 31 do
        pal(11, 1)
        self:draw_sprite()

        local x = flr(i / 4)

        for y=0, 7 do
          if(sget(self.sprite.sx + x, self.sprite.sy + y) == 5 or
             sget(self.sprite.sx + x, self.sprite.sy + y) == 6 or
             sget(self.sprite.sx + x, self.sprite.sy + y) == 7
          ) then
            pset(self.x + x, self.y + y, 10)
          end
        end

        pal()

        yield()
      end

      --sparkle
      local r = 0

      repeat
        pal(11, 1)
        self:draw_sprite()
        pal()

        r += .5
        circ(self.x + 7, self.y + 2, r, 7)

        yield()
      until(r == 3)
    end)
  else
    coresume(self.shiny)
  end
end



__gfx__
00000011410000000000000000000000000000114100000000000000000000000000001141000000000000000000000000000000000000000000000000000000
00000114441000000000001141000000000001144410000000000011410000000400011444100400000000114100000000000000000000000000000000000000
00001114444000000000011444100000000011144440000000000114441000004440111444404440000001144410000000000000000000000001141000000000
00011414141100000000111444400000000114141411000000001114444000000491141414119400000011147460000000000000000000000011444100000000
00011444444100000001141414110000000114444441000000011414141100000991144444419900000114161611000000000000000000000111444400000000
00011144111100000001144444410000000111441111000000011444444100000091114411119000000114447471000000000000000000001141414104400000
0000104414100000000111441111000000001044141000000001114411110000000911441e190000000111441111000000000000000000001144444494400000
00000011111000000000114414100000000001111110000000001144141044000000911414190000000011441e10000000000000000110000114411194000000
0000001566900000000091111110000000000995694400000009991111194400000009565190000000004114141040000000000000111100005441e191110000
00000991956000000049999561000000000099945694000000449956699990000000009566500000000444566194440000000000011141100056414191111110
00000999995900000444909999440000000009444560000000449095659900000000009955600000000049956659400000000111961411110095666511111100
00000944499440000040011999440000000001149950000000000199560000000000001111111000000000995560000001111119554444410999555511011000
00000144111400000001011111000000000000111110000000010111110000000000011111111100000000111110000011111119955441410999999111000000
00000111111000000011111111100000000001111110000000111111111000000000011100011100000001111111000011111119195541440990009111111110
00000111011000000111111001100000000001110100000001111110011000000000001110001110000111110111000011001119199944400940000011111111
00000111111100000100000001110000000000111000000001000000011100000000000110000000000111000111100010000000011944004444000000000111
00011410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00114441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01114444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11144111000000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000
010441410000000000001ccccc11000000001ccccc11000000001ccccc11000000001ccccc11000000001ccccc11000000001ccccc11000000001ccccc110000
00000010000000000001ccc1ccc110000001ccccccc110000001ccc1ccc110000001ccccccc110000001ccccccc110000001ccc1ccc110000001ccccccc11000
0000000000000000001ccccccccc1100001cc1ccc1cc1100001cccc1cccc1100001cccccc1cc1100001ccccccccc1100001cccc1cccc1100001cc1ccc1cc1100
0bbbbbb000000000001ccccccccc1100001ccc1ccccc1100001cccc1cccc1100001ccccc1ccc1100001ccccccccc1100001cccc1cccc1100001ccccc1ccc1100
b566667b00000000001c1111111c1100001cccc1cccc1100001cccc1cc1c1100001cccc1cccc1100001c1111111c1100001c1cc1cccc1100001cccc1cccc1100
0b5555b000000000001ccccccccc1100001ccccc1ccc1100001cccc1cccc1100001ccc1ccccc1100001ccccccccc1100001cccc1cccc1100001ccc1ccccc1100
0b5667b000000000001ccccccccc1100001cccccc1cc1100001cccc1cccc1100001cc1ccc1cc1100001ccccccccc1100001cccc1cccc1100001cc1cccccc1100
0b5555b0000000000001ccccccc110000001ccccccc110000001ccc1ccc110000001ccccccc110000001ccc1ccc110000001ccc1ccc110000001ccccccc11000
0b5667b00000000000001ccccc11100000001ccccc11100000001ccccc11100000001ccccc11100000001ccccc11100000001ccccc11100000001ccccc111000
00bbbb00000000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000
00000000000000000000000000000000000000114100000000000000000000000000001114100000000000000000000000000000000000000000000000000000
00000000007000000000000000000000000001144410000000000011410000000000011144410000000000000000000000000000000000000000000000000000
000000000000888888a0000000000000000011144710000000000114441000000000111414100000000000000000000000000000000000000000000000000000
00000000000089999880070000090070000114141657570000001114471000000001141411110000000000000000000000000000000000000000000000000000
00000000a00899899888800000000000000114444656560000011414165757000001144444410000000000000000000000000000000000000000000000000000
007000000889aa7789999888000a0000000111441654560000011444465656000001114411110000000000000000000000000000000000000000000000000000
000000088899a778aaa899998000000000001044164445000001114416545600000011441e100000000000000000000000000000000000000000000000000000
0000008899aaa88877aaa88880000000000000111504990000001044164445000000011414100000000000000000000000000000000000000000000000000000
00900089aa7a7997998a98a988000000000000156699990000000011151499000000995651990000000000000000000000000000000000000000000000000000
000088998a78877a899898aa98000000000009919569900000000991956999000009999566599000000000000000000000000000000000000000000000000000
00a88998a8aa8a88789998aaa90a0000000009999959000000000999995990000009944954499000000000000000000000000000000000000000000000000000
000877878aaa88889989977aa9900009000009444990000000000944499000000000944114490000000000000000000000000000000000000000000000000000
00087888aa8a877989888897aa980007000001441110000000000144111000000000001111100000000000000000000000000000000000000000000000000000
000778887a88777989a88897aa9a0000000001111110000000000111111000000000011111110000000000000000000000000000000000000000000000000000
0008898798887799a7899998aa980000000001110110000000000111011000000000011101110000000000000000000000000000000000000000000000000000
0008898aa8a8779a7798a888a888a000000001111111000000000111111100000000111101111000000000000000000000000000000000000000000000000000
000899a788a889877798a78aa8988000111111111111111111111111111111111111c11111111c1111111115111c11111111c11111111c1111111115111c1111
00009997a88a898777a9a7a7789880006666666666666666666666666666666611111111dddddddddd1111151111111111111111111111111111111511111111
00008997788999989aa977a788a880006d666d666d666d666d666d666d666d665555555d1d6666661dd555551555555555555555555555555555555515555555
0000899a7a99998aa8a987788a898000d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6444114d6661d661d661d41151111111144411111114411444444411511114444
0000088a7798898aa8998788aaa980006d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d44444d66666d11d66661d4151dddddd1141dddddd11444444444441511144444
0009088aa9a888a999987a88a7998000d6d5d5111111d5d1111115d5111111d544444dd66d1666d1661dd411dddddddd11dddddddd1444444444441511444444
000008889aaa8889998888a7778800906565611cccc11111cccc11111cccc11594499d6d166666661dd1d41111111dd11111111dd1149ddddddd441514999999
00000008899a8a8889988aa899800000d5d511cccccc111cccccc111cccccc1144449d6ddddddddddd11d1dddddd1111dddddd111114dd666666dd1514499999
00700008889aaaaa8a98aa998800a00016d6111cccc11111cccc11111cccc11144944d6d666666666d111dddddddd11dddddddd1111d6dddddddd6d519444444
000000000888988888989998800000001d11111111111111111111111111111144944ddd666666666d1d11dddddd1111dddddd1111d6d666666d666d19444444
0000000000889a88aaa9988000000000111cccc11111cccc11111cccc111111144994d6d666666666dd11d111111111d111111111d6d66666666d661d9944444
0000070000008a99889980000000000011cccccc111cccccc111cccccc11114142899d6ddddddddddd111ddd1111111ddd111111ddd6666666666d1ddd999444
000000000a0008899888000000700000111cccc11111cccc11111cccc111441124988d6d611166666d111dddd111111dddd11111dd66666dd66666dd1d888222
000000000000008888000000000000001c11111111c11111111c11111111111144999ddd666666666d1d1dddddd1d11dddddd1d1d66666d66d66666d1d994444
0000000a0000000000000070000000001c11111111c11111111c11111111111144499d6d666666666dd112dddddd1112dddddd11d6666d6666d6666d1d999444
000000000000070000000000000000001cc1111111cc1111111cc1111111114141444d6ddddddddddd11122d111111122d111111d666d666666d666d1d444444
16d6d6d616d51d165555555555555555555555516155555561561555555555555555555555555555191c11114191c11114191c111141441566d6666d1d222222
1d656dd51d51d51555555555555555555555555161555556155615555555555555555555555555551c99944411c99944411c9994441111156d66666dd5555525
16d6d6d6151d5d1655551111111111555555555161555561555615555555555555555555555555551cc1111111cc1111111cc11111111115d66666d1d5555255
1d6ddd6d11d5d51555510000000000155555555161555615555615555555555555555555555555551c1c111111c1c111111c1c111111111566666d1d55552555
16d6d6d51ddd5d16555100000000001555555551615561555556155555555555555555555555555519c1c111419c1c111419c1c1114111156666ddd555525555
1dd56d51d5d5d51555510000000000155555555161561555555612222555555522222555555552221c99444411c99444411c994444111115666dd55555255555
16d6d51d5d5d5d1655510000000000155555555161615555555224422255552244422255555224421c1c111111c1c111111c1c1111111115dddd555552555555
1d6d51d5d5d5d51555510000000000155555555166155555552222224425522222224425552222221cc1c11111cc1c11111cc1c1111111152222222225555555
16d51ddd5d5d5d1d5551000000000015555555516155555552444424444222444424444244244442111c11111111c11111111c111111111555555d6d66666666
1d51d5d5d5d5551555510000000000155555555161555555242442224422242442224422422244221111111111111111111111111111111555555ddd66666666
151d555d5d5d5d1655510000000000155511555161555552442442442222442442442222424422421555555555555555555555555555555555555d6d66666666
11d551155555d51555510000000000155561555161555524222442224224222442224224422242421111444444411444444411444444411555552d6ddddddddd
1dd515d1155d5d1d55510000000000155615555161555524444224444224444224444224244442421114444444444444444444444444441555525d6d61116666
d5515555d155551555510000000000156155555161555524444224444224444224444224244442221144444444444444444444444444441555255d6d66666666
551555555d1d5d1d555100000000001615115551615555242224422242242224422242244222422514999999944999999944999999944415525555dd66666666
515555555d1555155551000000000061556155516155555244244244222244244244225242442255144999994444999994444999994444152222222222222222
155555515d1d5d1d5551000000000615561555516155555524244242255224244242255542422555194444444494444444494444444444156d111d2dd111111d
555555d15d1555155551000000006115615555516155555552444422225522444422225544422255194444444494444444494444444422156d1d1dddddd1d11d
5555515d1d1d5d1d5551000000061016151155516155555555222222442552222222442522224425199444444499444444499444444444156dd11ddddddd111d
1155d15d1d155515555100000061006155615551615555555244442444425244442444424424444218999444428999444428999444424415dd111ddd1111111d
5d115d1d15d15d1d5551000006100615561555516155555524244222442224244222442242224422198882222498882222498882222444156d111dddd111111d
d1d15d1555d155155551000061006115615555516155555244244244222244244244222242442242199944444499944444499944444441156d1d51ddddd11151
15d15d1555d15d1d1111111611161116111111116155552422244222422422244222422442224242149994444449994444449994444411156dd5551111111555
55d1555555d155155555556155615561555555116155552444422444422444422444422424444242144444444144444444144444444111152222222222222222
5d15555555d1551d5555561516666661555551616111112444422444422444422444422424444222155555555555555555555555555555552dd11111d6666d66
d155555555d15515555561551d6d6d6155551d61615555242224422242242224422242244222422511111111111111111111111111111115ddddd1d1d66666d6
1555555555d1551d555615561666d66155516661615555524424424422524424424422524244225511111111111111111111111111111115dddddd111d66666d
155555555d115515556155611d6d6d61551d6661615555552424424225552424424225554242255511cccccc111cccccc111cccccc111115dd11111111d66666
15555555d151551d56155615166666d1516666616155555552444422555552444422555544225555111cccc11111cccc11111cccc1114415ddd11111555d6666
1555555d155d1515615561551d6d6d111d6d6d6161555555552222555555552222555555225555551c11111111c11111111c111111111115ddddd1115555d666
155555d1555d151d155615561666d11c1666666111555555555555555555555555555555555555551c11111111c11111111c1111111111151111111555555ddd
15555d15555d1515556155611d6d11cc166d6d6155555555555555555555555555555555555555551cc1111111cc1111111cc111111111152222222222222222
1555d155555d151d56155615114144111d6d6d6d15d5d5d5666666661111111114191c1111414415191c11114191c11100000000000000000000000000000000
155d1555555d1515615561554411111116d6d6661d5dd6dd565555551111111141111111141111151c99944411c9994400000000000000000000000000000000
15d15555555d151d15561555111111111d6d6d6d15d5d5d5556555555555555511222222111111151cc1111111cc111100000000000000000000000000000000
1d155555555d1515556155551111111116d666d61d5d5d56555655554444411512222222211111151c1c111111c1c11100000000000000000000000000000000
11555555555d151d56155555114111111d6d6d6d15d5d5d55555655544444415112222221141111519c1c1111111111100000000000000000000000000000000
15555555555d1515615555554411111116d6d6d61d5ddd5d555556554444441512111111111111151c911ddddddddd1100000000000000000000000000000000
55d15555555d151515555551111111111d6d6d6d15d5d5d5555555659994441512221111111111151c1111111111111100000000000000000000000000000000
5d155555555d15155555551d1111111116d666d61d5d5d5655555556994444151222211111111115111ddddddddddd1100000000000000000000000000000000
d1d15555555d15115555516615555555156d6d6d15d5d5d5111c11111111c11112222221111111111ddddddddddddddd11111c11000000000000000000000000
1d1555555551551555551d661155555516d6d6d61d5d5d5d11111111111111111d22222211111111ddddddddddddddddd1111111000000000000000000000000
d155555555d15155555166661d1555551d6d6d6d1555d5d515555555555555551dd21111115511ddddddddddddddddddddd11115000000000000000000000000
1555555555d11555551d666d1661555516d6d6d61d5d5d5d111111111111144412d221111141ddddddddddddddddddddddddd111000000000000000000000000
5555555555d1555551666666166d155515dd656d15d555d5111ddddddddd11441222222111111111111111111111111111111111000000000000000000000000
555555555d1555551d6d6d6d1666615516d6d6d61d5d5d5d1ddddddddddddd141222222211411ddddddddddddddddddddd111114000000000000000000000000
55555555d1555555166666661d666d151d6ddd6d1555d555111ddddddddd111912221111119441ddddddddddddddddddd1111999000000000000000000000000
5555555d15555555166d6d6d1666666116d6d6d61d5d5d5d1dd11111111111191222211111444411dddddddddddddddd11144999000000000000000000000000
555555d155555551166666661d6d6d6d15dd65dd155555d51dddddd111111114112222211144441511ddddddddddddd114494444000000000000000000000000
55555d15555555151d6d6d6d1666666616d6d6d61d5d5d5d1ddddddd111111141111111111442215111ddddddddddd1144494444000000000000000000000000
5555d155555551551666d6661d6d6d6615d5dd6d155555551ddddddd111111141211111111444415191111111111111114499444000000000000000000000000
155d1555555515551d6d6d6d1666666616d6d6d61d5d5d5d1dddddddd11111141222111111424415111ddddddddddd1111189994000000000000000000000000
15d1555555515555166666661d6d6d6d15ddd5dd1555555511dddddddd11111212222111112444111ddddddddddddddd11118882000000000000000000000000
1d155555551555551d6d6d6d1666d66616ddd6d61d5d5d5d1d111111111111141222222111444111ddddddddddddddddd1111144000000000000000000000000
11555555515555551666d6d61d6d6d6d15d5ddd51555555511ddddd1111111141d222222114411ddddddddddddddddddddd11114000000000000000000000000
15555555155555551d6d6d6d1666666616d6d6d61d555d5511dddddd111111141dd211111141ddddddddddddddddddddddddd111000000000000000000000000
555555555555555516d666d616d6d6d615d5d5dd1555555561dddddd1111116612d2211111111111111111111111111111111111000000000000000000000000
55555555555555551d6d6d6d1d656dd516ddd6d6515d5d5d51ddddddd11111551222222111511ddddddddddddddddddddd111115000000000000000000000000
555555555555555516d6d6d616d6d6d615d5d5d55515555551ddddddd111115512222222115551ddddddddddddddddddd1111555000000000000000000000000
55555555555555551d6d6d6d1d6ddd6d1dd656d655515d5551dddddddd1111551222111111555511dddddddddddddddd11165555000000000000000000000000
555555555555555516d666d616d6d6d615d5d5d55555155551dddddddd111155122221111155555511ddddddddddddd115556555000000000000000000000000
55555555555555551d6d6d651dd56d55165dd6dd5555515d51dddddddd1111555122222111555555511ddddddddddd1155555655000000000000000000000000
555555555555555516d6d6d616d6d51615d5d5d55555551555111111111115555511111115555555555111111111115555555565000000000000000000000000
55555555555555551d6d6d6d1d6d51151d565dd65555555166666666666666666666666666666666666666666666666666666666000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000
__map__
8283848485868788898788858687888987888586878889870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9293948495969798969799959697989697999596979896970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a2a3a484a5a6a7a8a6a7a9a5a6a7a8a6a7a9a5a6a7a8a6a70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2c2b4e1b5b6b7b8b6b7b9b5b6b7b8b6b7b9b5b6b7b8b6b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2d2b365666764656667646566676465666764656667d3f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2e27475767774757677747576777475767774757677e3d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f28a8b8cc38a8b8cc38a8b8cc38a8b8cc38a8b8cc3c4e30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f2f39a9b9cc79a9b9cc79a9b9cc79a9b9cc79a9b9cc7d4c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8081aaabacadaaabacadaaabacadaaabacadaaabacade4d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091babbbcbdbabbbcbdbabbbcbdbabbbcbdbabbbcbdf4e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a18a8b8c8d8a8b8c8d8a8b8c8d8a8bc8c9cacb8c8dc5f40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b19a68696a6b6c6d6e6f9b9c9dd6d7d8d9dadbdc9dd5c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1aa78797a7b7c7d7e7fabacade6e7e8e9eaebecade5d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f19e9faeafbebf8e8ff1f1c6f6f7f8f9fafbfcf1f5e50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
018000001806218062180621806218062180621806218062180621806218062180621806218062180621806218062180621806218062180621806218062180621806218062180621806218062180621806218062
018000001812018120181201812018120181201812018120181201812018120181201812018120181201812018120181201812018120181201812018120181201812018120181201812018120181201812018120
01ff00003f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f610
0010000018b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b0000b00
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000010050130501405016050180501a04021030290202e010000001d0001f00023000290002c0000e0002c700247002470022700227002270022700000000000000000000000000000000000000000000000
0102000014050110500d0500905006040050300302000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001815019150181501815017140161401413013120111100a10009100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000300002733022330273302a3302e3302c3002c3002e3002d3001430011300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000c0000210502100021000210002c7002c7002470024700227002270022700227000a0000500005000080000800000000000000a0000a0000a0000a000000000000000000000000000000000000000000000000
000400002e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0502e0402e0302e0202e010000000000000000000000000000000000000000000000000000000000000
012000002291422910229102291022910229102291022910229102291022910229102291022910229102291022910229102291022910229102291022910229102291022910229102291022910229102291022910
018000081690016900169241692016920169201692016920169001690016900169001690016900169001690016900169001690016900169001690016900169001690016900169001690016900169001690016900
018000080a9000a9000a9000a9000a9240a9200a9200a9200a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a9000a900
0180000822910229102291022910229102291022910229102e8002e80029800298002c8002c80024800248002e8002e80029800298002c8002c8002480024800228002280029800298002c8002c8002480024800
01800008169201692016920169201692016920169201692029800298002c8002c8002480024800228002280000000000000000000000000000000000000000000000000000000000000000000000000000000000
014000002e8242e8202e8202e825298242982029820298252c8242c8202c8202c825248242482024820248252e8242e8202e8202e825298242982029820298252c8242c8202c8202c82524824248202482024825
010800001176011760117601176011760117601176011760167601676016760167601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b7601b760
010800001a7601a7601a7601a7601a7601a7601a7601a76016760167601676016760167601676016760167601376013760137601376013760137601376013760187601876018760187601d7601d7601d7601d760
010800001d7601d7601d7601d7601d7601d7601d7601d7601d7601d7601d7601d7601d7501d7501d7501d7501d7401d7401d7401d7401d7301d7301d7301d7301d7201d7201d7201d7201d7101d7101d7101d715
010800001156011560115601156011560115601156011560165601656016560165601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b5601b560
010800001a5601a5601a5601a5601a5601a5601a5601a56016560165601656016560165601656016560165601356013560135601356013560135601356013560185601856018560185601d5601d5601d5601d560
010800001d5601d5601d5601d5601d5601d5601d5601d5601d5601d5601d5601d5601d5501d5501d5501d5501d5401d5401d5401d5401d5301d5301d5301d5301d5201d5201d5201d5201d5101d5101d5101d515
011400001d5701d5701d5701d5701d5701d5701d5701d5701d5750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001d10020160201602016020160201602016020160201650010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011400001170019760197601976019760197601976019760197650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001970014070140701407014070140701407014070140700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000a220052200a2210a2250a2200a2250a220032200322008220032200322008220032210822003220052200a22005220052250a2200a220052200a2200a220052200a2200a2200a220052200a22005220
010e00000a220052210a2210a2250a2200a2250a220032200322008220032200322008220032210822003220052200a22005220052250a2200a220052200a2200a220052200a2200a2200a220002210022305200
010e00001d4321d4002246118400264301f4002243029430184002443124432244321843118400284002b400274302840029430244002b4302b40027430294322943229432274312743227432294302b43027430
010e00001d4321d4002246118400264301f4002243029430184002443124432244321843118400284002b40029451284002743024400264302b40022430244322443224432244322443218431004000040000400
010e00001d4321d4002246118400264301f4002243029430184002443124432244321843118400284002b400274302840029430244002b4302b40027430294322943229432294322943227431224312243222432
010e00002943129432294320040027431274322743200400264312643226431224312243222432264312643224432244322443224432244322443224432244322943224432214321d4321d4333ca243ca203ca20
010700201806305200308000a2003ca100a2003ca100320018063052003ca100a2003ca100a2003ca10032001806305200308000a2003ca103ca103ca103ca1518063052003ca100a2003ca100a2003ca1003200
010e00001d0002202626026290261865022026260262902618000200262402627026186502002624026270261d000220262602629026186502202626026290261d00022026260262902618650220262602629026
010e00001d0002202626026290261865022026260262902618000200262402627026186502002624026270261d000220262602629026186502202626026290261d00018650260262902618650220262602629026
010e00000a230052310a2310a2350a2300a2350a2300323003230082300323003230082300323108230032300a230052310a2310a2350a2300a2350a230032300323008230032300323008230032310823003230
010e00001d0002202626026290261d400220262602629026180002002624026270261d4002002624026270261d0002202626026290261d4002202626026290261d0002202626026290261d400220262602629026
010700201806305200308000a2003ca100a2003c8000320018063052003c8000a2003ca100a2003c800032001806305200308000a2003ca103c8003c8003c80018063052003c8000a2003ca100a2003c80003200
010e00001865000000000000000018650000000000000000186500000000000000001865000000000000000018650000001865000000186500000018650000002464524645246452464524645246452464524645
010e00000000000000000000000018650000000000000000000000000000000000001865000000000000000000000000000000000000186500000000000000000000000000000000000018650000000000000000
010e00000000000000000000000018650000000000000000000000000000000000001865000000000000000000000000000000000000186500000000000000000000018650000000000018650000000000019400
010e00002e7312e7322e7322e7322e7322e7322e7322e73229731297322973229732297322973229732297322c7312c7322c7322c7322c7322c7322c7322c7322473124732247321873133322323222e3222e322
01e000023ca25248002230018300263001f30022300293002430018300243001d3002430026300283002b300273002830029300243002b3002b30027300293002930029300003000030000300003000030000000
01e000023c8003ca242230018300263001f30022300293002430018300243001d3002430026300283002b30029300283002730024300263002b30022300243002930029300003000030000300003000030000000
010e00002e7312e7322e7322e7322e7322e7322e7322e73229731297322973229732297322973229732297322c7312c7322c7322c7322c7322c7322c7322c7322473124732247321873124322293222e32235322
01140000295502c5502c5502c5502c5502c5502c5502c5502c555132001320000000263000000022300000002430000000000000000000000000000000000000243000c0000000000000243000c300243000c000
010900000b6701066017650076500065007650006500b653006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
000100000d760107700f7700c7600c76010760117701177012770107600d760117701377013760117500d7400d76010770157601676016750147401274014750177501a76018760187401374015730197301c720
010a00002a9602a9602a9602a9622a9622a96227960279602796027965239602c9602a9602a9602a9602a9622a9622a9622796027960279602796227962279652a9602a9602a9602c9602c9602c9602d9602d960
010a00002d9602c9602c9602c9652a960239602a9602896028960289602896228962289622896525960259652a9602a960299612896127961269612596124951239512295121951209411f9411e9411d9411c733
010a000027851278402784027842278422784223841238402384023840238450f8002784127840278402784227842278422384123840238402384223842238422784127840278402784227842278422a8402a840
010a00002a840288402884028840278401b8412680025841258402584025840258422584225842258450080000800008000080000800008000080000800008000080000800008000080000800008000080000800
010a00000b7600b7600b7600b7600b7600b7600876008760087600876008760087600b7600b7600b7600b7600b7600b7600876008760087600876008760087600b7600b7600b7600d7600d7600d7600e7600e760
010a00000e7600d7600d7600d7600b7600b76525700097600976009760097600976009760097600176001765067600576104751037410273101721007110b7000a70009700087000770006700057000470003700
010a0000180630000018063186503ca0005200180630000018063186503ca100000018063000003ca0018650180000520018063000003ca00186503ca10000001806300000180631865018000052001806300000
010a000018063186503ca1018000180630000000000186500000000000180630000000000186503ca100000018063000000000018063000000000018063000001800018063000001800018053180431803318023
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100002a7002a7002a7002670026700267002670000000000002a7002a7002a7002a7002a7002a7002670026700267002670026700267000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0e 0f 10 44
00 11 12 13 44
00 11 12 14 44
00 11 12 15 44
00 11 12 16 17
00 11 12 43 18
00 11 12 14 19
00 11 12 15 44
00 11 12 16 17
00 11 12 43 18
04 11 12 43 19
04 1a 1b 1c 1d
00 41 1e 43 20
00 41 1e 43 21
00 41 1f 43 22
00 41 1f 43 23
01 24 1e 25 44
00 24 1e 26 44
00 24 1e 25 44
00 24 1e 26 44
00 24 1e 25 20
00 24 1e 26 21
00 24 1e 25 22
00 24 1e 26 23
00 29 27 28 2e
00 29 27 28 2f
00 29 27 25 44
00 29 27 28 2a
00 2e 1e 2b 30
00 2f 1e 2c 2d
00 29 1e 2b 30
02 29 1e 2c 2d
01 34 36 38 3a
04 35 37 39 3b
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
