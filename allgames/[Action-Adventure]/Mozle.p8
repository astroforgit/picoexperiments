pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- mozle
-- by tarro

season="normal"
state = {}
objects = {}
types = {}
cam = {}
is_dead = false
letters = {}
spell_progress = {}
message = ''
progress = { levels = {} , score = 0 , lives = 3, time = 100, items={} }
dbg=""
difficulty = {}

 local splash="00111111000000001000100000011111000000000000000000000000000000000000000070000000777777777777777766666777666666667777766677777777111111110000000000000000001111110000000000000000000000000000000000000000760000007777777777776667666666776666666677776666777777771111111100000000000001100001111100000000000000000000000000000000000000007600000077777777777666666666667766666666777766667777777711111111000000010000011000011111000000000000000000000000000000000000000076000000677777777766666666666677666666667777666677777777111111110000001100000110001111100000000000000000000000000000000000000000760000006777777777666666666666776666666677776666777777771111111100000011000000110011111000000000000000000000000000000000000000007600000067777777776666666666667766666666777766667777777711111111000001110000000000111110000000000000000000000000001000000000000066100011777777777776666666666677666666667777666677777777111111110000011100000000001111000000000000000000000000000110000011000000611111117777777777776667666667776666666677777666666677771161111100000001000000000110010000000000000000000000000011110000110000006111111177777777777777776666677766666666777776666666667711111111000000010000000000000100000000000000000000000000111100001100000161111111777777777777777766667777666666667777776666666667111111110000000000000000000000000000000000006000000000001111110011000111610000117777777677777777666777776666666677777776666666661111111100000000000000000000000000000000000000000000000011111110110011110000000077777776777777776677777766666666677777776666666611111111000000000000000000000000000000000000000000000000111111100000011100000000777777767777777777777777776666666777777766666666000111110000000000000000000000000000000000000000000000000111111000000111000000007777776677777777777777777777777766777777666666660001111100000000000000000000000000000000000000000000000001111110000001000000000077777760777777777777777777777777667777776666666600000111000000000000000000000000000000000000000000000000000001100000000000000000777776607777777777777777777777776677777766666666000001110010011000000000000000000000000000000000000000000000011100000000000000007777760076667777777777777777777766777777666666660000011100011111000000000000000000000000000000d000000000000001100000000000000000777766006666677777777777777777776677777d666666660000011100011111000000000000000000000000000000d000000000000000000000000000000000777760006666667777777776777777776677777d66666666110011110001111100000000000000000000000000000d6d00000000000000000000000000000000777660006666667777777776d7777777677777d66666666611110011000011110000000000000000dd000000000dd676000000000000000000000000000000007766000066666677777777766dd777776777dd676666666611000011000000001101ddd000000000dd00000000000d6dddddddddd000000ddddddddddddddddddddddddd66666777dddddddddddddddd777777d6666666660000000100000000111ddfd010000000fdd00001dd0000ddfffffffdd0000dddffffffffffffffffdfffffdd76667777fffffffddfffffff7777777d66666667000000000000000011ddfed000000000efdd0001fdd000ddeeeeeeefd000ddffeeeeeeeedeeeeeeedeeeeedd77777777eeeeeeeddeeeeeee7777777d6666667700000000000000001ddfeed000000001eefdd000efdd000deeeeeeeed00ddfeeeeeeeeeed4eeeeeedeeeeed077777776eeeeeeeddeeeeeee777777776666777700000000000000000dfeeed000000010eeefd000eefdd00deeeeeeeed0ddfeeeeeeeeeeeddeeeeeedeeeeed077777766eeeeeeeddeeeeeee77777777777777770000000000000000ddeeeed000000000eeeedd00eeefdd0de44444eedddfeeeee44444440d4eeeeedeeeeed07777666044eeeeedd4444444777777777777777700111111d0000000dfeeeed00000000deeeefdd0eeeefd0d4ddddd4eddfeeeeeeddddddd0ddeeeeedeeeeed0d7766000ddeeeed6dddddddd777777777777777700001111d0000000feeeeed0000000ddeeeeefddeeeeed0ddd000dd40deeeee4edd0000000d4eeeedeeeeed06dd611117deedd67777777777777777777777777000011116d000000eeeeeedd000000dfeeeeeefd4eeeedddd00000ddddeeee4defd0000000ddeeeedeeeeed0d6600000ddeeeed677dddddd77777777777777770001111176dd0000eeeeedd6d0000ddeeeeeeeeddeeeefdd0000000ddfeeeeddeedd0000000d4eeedeeeeed060100000ffeeeeed77dfffff7777777777777777001111116d000000eeeeeedddd00ddfeeeeeeeefdeeeeedd00000000deeeeed0eefd0000000ddeeedeeeeed000000000eeeeeeed77deeeee777777771677777700011111d0000000eeeeeed0fddddfeeeeeeeeeedeeeeedd00000000deeeeed0eeedd0000000d4eedeeeeed000000000eeeeeeed77deeeee777777771106677700001111d0000000eeeeeed0efddfeeeeeeeeeeedeeeeedd00000000deeeeed0eeefd0000000ddeedeeeeed000000000eeeeeeed77deeeee67777777111000660000111100000000eeeeeed0eeddeeeeeeeeeeeedeeeeedd0000000ddeeeeeddeeeedd0000000d4edeeeeed00000000044eeeeed66d44444006666660000000000000011000000004eeeeed0eeffeeeeeeeee4eefeeee4ddd00000ddd4eeeefdeeeefd0000000ddedeeeeed000000000ddeeeeed00dddddd00000000000000000000001100000000deeeeed0eeeeeee4eeeeed4eeeeeeddddd000ddfddeeeeefeeeeedd0000000dedeeeeed0000000000deeeeed0000000000000000000000000000001100000000deeeeed0eeeeee4deeeeedd4eeee4d0dfdddddfe0d4eeeeeeeeeefd0000000d4deeeeed0ddddddddddeeeeeddddddddd00000000000000000000000100000000deeeeed0eeeeeeddeeeeedddeee4dd0defffffee1dd4eeeeeeeeeeddddddddddfeeeeeddffffffffffeeeeeddfffffff00000000000000000000000100000000deeeeed04eeee4d0eeeeed0dee4dd00deeeeeeee01dd4eeeeeeeeefdffffffffeeeeeeddeeeeeeeeeeeeeeeddeeeeeee00000000000000000000000100000000deeeeed0d4ee4dd0eeeeed0de4dd000deeeeeeeed00dd4eeeeeeeeedeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeddeeeeeee00000000000000000000000000000000deeeeed0dde4dd00eeeeed004dd0000d4eeeee44dd00dd44eeeeeeefeeeeeeeeeeeeeeddeeeeeeeeeeeeeeed6deeeeee0000000d000000000000000000000000d44444d00d4dd00044444d00dd00000dd44444ddfd000ddd4444444444444444444444dd444444444444444d76dd444400000dd6000000000000000000000000ddddddd00ddd0000dddddd000000000dddddddd0dd000000dddddddddddddddddddddddddddddddddddddddd6ddddddd0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000000001100006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000111111110000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000b3f4000000000011000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035754000000000000000000000000000000001100000000000000000000000008888800000000088000000000000000000000000000000000000000000000000f7c750000000000000000000000000000000011000000000000000000000000088888000000000880000000000000000000000000000000000000000000000005c7c311000000060000000000000000000001110000000000000000000000000800000000000888800000000000000000000000000000000000000000000000057cc51110000000000000000000000000000111000000000000000000000000028000000000888220000000000000000000000000000000000000000000000005ccc51110000000000000000000000000000011000000000000000008000000082208888008822880000000000000000000000000000000000000000000000005ccc50000000000000000000110000000000001100000000000000008888000088828888002288880000000000000000000000000000000000000000000000005cc151110000000000000000111110100000001100000000000000008888800088882888502888880000000000000000000000000000000000000000000000003ccc500011000000000000001001111000000001000000000000000088888888888222887528888800000505000000000000000000000000000000000000000053115000000000000100000000011000000000000000000000000000888888888222222876588888000057650000000000000000000000000000000000000000511150000000000000000000000100000000000000000000000000008888888822222222575888820000577600000000000000000000000000000000000000004515300000000000001000100000000000000000000000008000000088888888222222287598222200000777000000000000000000000000000000000000000004340000000000000011010011100000000000000000000080000000888888882222228865f9f999000000560000000000000000000000000000000000000000000000000000000001000000011000000000000000000000880000008888822819988888611ffff100000006000000000000000000000000000000000000000000000000000000000000000001100000000000000000000088000000828800021ff99888611fff11002955570000000000000000000000000000000000000000000000000000000000000000000100000000000000000000880000008880000877ff9f88671ff177029957770000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000008800000077ffff80ff2ff1170299575500000000000000000000000000000000000000000000000000000000000000000fffffff0000000000000000000000000000500077ffff80ff2ff227299995000000000000000000000000000000000000000000000000000000000000000000b33ff444000000000000000000000000000575007ff98800eefff2779999900000000000000000000000000000000000000000000000000000000000400000013ff7775500000000000000005000000000057505fee9dc000ff7774449999000000000020000000000000000000000000000000000000000000000004000000035577c5500000000000000007500000000057557fff9dcc000ff444f49999000000000020000000000000000000000000000000000000000000000005b000000f7777c77000000030000000070000000ccc775779991cccc000fffff49999000000000020000000000000000000000000000000000000000111000005b000000f777c777000000030000000050000000ccc76775dd11111c00001ddd499990000000000200000000000000000000000000000000000000001110000053000000577cc7330000000f000000007500000011c76667c1110111c0001ccc4999955500000002000000000000000000000000000000000000000011100000330000005cc77ccc00000004000000007750000005775665ccc00000cccccccc4449055500000002000000000000000000000000000000000000000011100000330000005c77cccc00000004000000005550000005775557c1cc00005cccccccbbbbbbb5000000bb00700000000700000000000000000000000000001110000054000000577ccccc00000004000000005000000047750057cc1cccc4bcccccccbbbbbbbbbbbbbbbb0000000b00000000000000000000000000000000011100005400000057cccccc000000040000000050000000499bbb57ccccccccbbccccccbbbbbbbbbbbbbbbb00bbbbbb0000000300000000000000000000000000110000540000005ccccccc0000000400000000bb000000499bbbb5cccccc11bbb1ccccbbbbbbbbbbbbbbbbbbbbb3bb0000003300000000000000000000000000000000540000005ccccccc0000000400000000bbbbbb004992bbbb11111114bbbb1111bbbbbbbbbbbbbbbbbbb33bbb00bbb3b300000000000000000000000000000000540000005ccccccc00000004b0000000bbbbbbbb9992bbbbb5555bb4bbbbbbbbbbbbbbbbbbbbbbbb3b3bb37bbbbb3bb300000007000000000000000000000000540000005ccccccc00000004bbb00000bbbbbbbb9992bbbbbb553333bbbbbbbbbbbbbbbbbbbbbbbb376bb3bbbbbb367700000bbb000000000000000000000000540000005cccccc100000003bbbbbb00333bbbbb99923333bb333333bbbbbbbbbbbbbbbbbbbbbbbb76c73bbbbbb3737c00bbbbbb000000000000000000000000540111005ccccc1100000003bbbbbbbb3333bbbb99923333bb333333bbb33bbbbbbbbbbbbbbbbbbb7333bbbbbbb37333bbbbbbbb000000000000000000000000530011003cccc11cbb000003bbbbbbbb33333bbb3992333333333333bb3333bbbbbbbbbbbbbbbbbb73333bbbbb377333bbbbbbbb000000bb0000000000000000530010003cccc1ccbbbbb003bbbbbbbb333333bb3222333333333333bb333333bbbbbbbbbbbbbbbb77773bbbbb377777bbbbbbbb000bbbbb000000000000000054001000533c1cc1bbbbbb0bbbbbbbbb333333bb3333333333333333bbb33333bbbbbbbb333bbbbb55773bbbbb377775bbbbbbbb00bbbbbb00000000000000005400110053311c11bbbbbbbbbbbbbbbb333333333333333333333333bbbbb333bbbbbbbbb73bbbbb557b3333bb3b7755bbbbbbbbbbbbbbbb000000000000000053000000b31cc1ccbbbbbbbb3bbbbbbb333333333333333333333333bbbbb333bbbbbbbb7b3bbbbb57b333b7bbb3b788bbbbbbbbbbbbbbbb000000bb000000005300000033331111bbbbbbbb333b33bb333333333333333333333333bbbbb333bbbbbbbb73bbbbbb3b3b7737bbbb3333bbbbbbbbbbbbbbbb0001bbbb000000005300000033333111bbbbbbb33333333b333333333333333333333333bbbb3333bbbbbbbbb3bbbbbb77773377bbbbbb77bbbbbbbbbbbbbbbb001bbbbb000000003001000033333335bbbbbb333333333b333333333333333333333333bbbb3333bbbbbbbb3bbbbbbb3b77737bbbbbbbbbbbbbbbbbbbbbbbbb0bbbbbbb000000000010000033333333bbbbb3333333333b333333333333333333333333bbbbb333bbbbbbbb3bbbbbbb37777333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000003310000033333333bbbb33333333333b33333333bbb33333bbbbbbbbbbbbbbbbbbbbbbbb33333bbb73b37733bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbb000000bb3330000033333333bbbb33333333333b33333333bbbb3333bbbbbbbbbbbbbbbb3bbbbbbb3333333373bbb733bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbb00000bbb3333000033333333bbb33333333333bb33333333bbbbbbbbbbbbbbbbbbbbbbbb33bbbbbb33333333bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbb3333331133333333bb3333333b33bbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbb333bbbbb33333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11bbbbbb3333333133333333b3333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbbbb333333333333333333333333bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333bbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbbbb333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333bb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333bbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333b3333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333333333333333bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333333333333333bbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333333333333333bb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333333333333333333333333333333333b3333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333333333333333333333333333bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333333333333333333333333333bbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333333333333333333333333333333333333333bb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333333333333333333333333333333333333333333333333bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb33333333333333333333333333333333333333333333333333333333bbbbb333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333bbbbb33333333333333333333333333333333333333333333333333333333bb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bb3333333333333333333333333333333333333333333333333333333333333333bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbbbb333333333333333333333333333333333333333333333333333333333333333333333333bb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bb33333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbb333bbbbbbbbbbbbbbbbbbbbbbbb333bbbbb333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb33bbbbbbbb33bbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333300000000"
 function draw_splash_screen()
     local mem=0x6000
     for i=1,128*128-4,8 do
         poke4(mem,tonum("0x"..sub(splash,i,i+3).."."..sub(splash,i+4,i+7)))
         mem+=4
     end
 end

--animation timing
message_t=0

function init_levels()
	hub_world = parse[[x=0,y=0,w=320,name=hub_world,score=0,rounds={}]]
	level = hub_world
	level_list = parse[[
		{x=0,y=1,w=256,name=moon stone,score=0,fizzles=0,rounds={},max_round=3,is_snow=true},
		{x=0,y=1,w=256,name=green belt,score=0,fizzles=0,rounds={},max_round=3},
		{x=0,y=1,w=256,name=flat surface,score=0,fizzles=0,rounds={},max_round=3},
		{x=0,y=3,w=384,name=plain plains,score=0,fizzles=0,rounds={},max_round=3},
		{x=0,y=2,w=384,name=lost woods,score=0,fizzles=0,rounds={},max_round=3,is_fall=true},
		{x=0,y=1,w=256,name=freezing hills,score=0,fizzles=0,rounds={},max_round=3,is_snow=true},
		{x=0,y=1,w=256,name=golden age,score=0,fizzles=0,rounds={},max_round=3}
	]]
end
function init_items()
	difficulty_list = parse[[
		{name=cakewalk,selected=false,hovered=true},
		{name=casual,selected=false,hovered=false},
		{name=adventurous,selected=false,hovered=false}
	]]
	item_list = parse[[
		{id=2,name=water,spr=35,selected=false,hovered=false},
		{id=3,name=fire,spr=34,selected=false,hovered=false},
		{id=5,name=thunder,spr=37,selected=false,hovered=false},
		{id=7,name=wind,spr=36,selected=false,hovered=false},
		{id=11,name=earth,spr=38,selected=false,hovered=false},
		{id=13,name=plant,spr=39,selected=false,hovered=false},
		{id=19,name=light,spr=40,selected=false,hovered=false},
		{id=23,name=dark,spr=41,selected=false,hovered=false}
	]]
	combos = parse[[
	{id=4,msg=alternative palette,fx=score_multiply},
	{id=6,msg=ten extra time,fx=score_multiply},
	{id=10,msg=you change color,fx=score_multiply},
	{id=14,msg=double points,fx=score_multiply},
	{id=22,msg=double points,fx=score_multiply},
	{id=26,msg=ten points,fx=score_multiply},
	{id=38,msg=bonus game 2,fx=score_multiply},
	{id=46,msg=ten extra time,fx=score_multiply},
	{id=9,msg=double points,fx=score_multiply},
	{id=15,msg=hundred points,fx=score_multiply},
	{id=21,msg=double points,fx=score_multiply},
	{id=33,msg=double points,fx=score_multiply},
	{id=39,msg=level one toggle,fx=score_multiply},
	{id=57,msg=you turn invisible,fx=score_multiply},
	{id=69,msg=alternative palette,fx=score_multiply},
	{id=25,msg=double points,fx=score_multiply},
	{id=35,msg=nothing,fx=change_season,opt=snow},
	{id=55,msg=points doubled,fx=score_multiply},
	{id=65,msg=red mozle,fx=score_multiply},
	{id=95,msg=bonus game one,fx=score_multiply},
	{id=115,msg=huge fizzles,fx=score_multiply},
	{id=49,msg=thirty extra time !,fx=score_multiply},
	{id=77,msg=double points,fx=score_multiply},
	{id=91,msg=game over just joking,fx=score_multiply},
	{id=133,msg=extra life,fx=score_multiply},
	{id=161,msg=one point,fx=score_multiply},
	{id=121,msg=level two toggle,fx=score_multiply},
	{id=143,msg=double points,fx=score_multiply},
	{id=209,msg=double points,fx=score_multiply},
	{id=253,msg=strange warp effect,fx=score_multiply},
	{id=169,msg=double points,fx=score_multiply},
	{id=247,msg=thousand points,fx=score_multiply},
	{id=299,msg=level three toggle,fx=score_multiply},
	{id=361,msg=double points,fx=score_multiply},
	{id=437,msg=double points,fx=score_multiply},
	{id=529,msg=hundred thousand points !,fx=score_multiply}]]

	local effects={
		score_multiply= fx_score_multiply,
		change_season= fx_change_season,
	   }
	   
	for k,comb in pairs(combos) do
		comb.fx=effects[comb.fx]
	end

end


function fx_score_multiply() progress.score +=2000 end
function fx_change_season(opt) season = opt end

function find_combo(item1,item2)
	local c = item1
	local v = item1.id*item2.id
	foreach(combos, function(combo)
		if combo.id == v then
			c=combo
		end 
	end)	
	return c
end

function resolve_combine(items)
	local combine = {}
	foreach(items,function(item)
		if item.selected then
			add(combine, shallowcopy(item))
			del(progress.items,item)
		end
	end)
	selected = 0
	local c = find_combo(combine[1],combine[2])
	message = c.msg
	if c.opt then c.fx(c.opt) else c.fx() end
end

function init_spellbook()
	spellbook = parse[[cakewalk=
	{bang,fuze,grax,mean,plof,abot,cupo,dims,enyl,haze,ipou,jolt,kupa,lyan,noxe,obam,quiz,ruse,snax,tibo,ulag,vulp,welp,xode,zeta},casual=
	{flipu,bidon,manti,pingu,wonks,rifaz},adventurous=
	{fableto,bepliaf,kultima,purtiva,ledubas,matonic,warbops,squilft,crejams}]]
end
function init_gfx()
	bg_colors=parse"15,6,2,1,2,1,2,1,1,0,0,0,0,0"
	spal=parse"1,2,6,13,5,6,7,8,9,10,7,12,13,14,15"
	fpal=parse[[   
		1 , 2 , 9,   
		4 , 5 , 6 , 7,
		8 , 9 , 10, 4,
		12, 13, 14, 15
	]]
	lpal=parse[[   
		1 , 2 , 8,   
		4 , 5 , 6 , 7,
		8 , 9 , 10, 10,
		12, 13, 14,15
	]]
	dpal1 = parse[[0, 1, 1,
	2, 2,13, 6,
	2, 4, 9, 3,
	13,5, 8]]
	dpal2 = parse[[   0, 0, 0,
	1, 1, 5, 5,
	1, 2, 4, 1,
	5, 2, 2]]
	bg_patterns={0b101111110101111,0b10110100101,0b10110100000,0b1010000} 
end

--sfx
-------------------
--58 => cursor movement
--62 => deepvoice
--63 => score


--graphics
-------------------
--fade
function fadeto(nxt,rev)
	fade_rev=rev
	fade_nxt=nxt
	fade_n=0
end
--maths utils

nums={}
for i=0,9 do nums[""..i]=true end
function parse(str,ar)
 local c,lc,ar,field=1,1,{}

 while c<=#str do
  local char=sub(str,c,c)
  if char=='{' then

   local sc,k=c+1,0
   while sub(str,c,c)~='}' or k>1 do
	char=sub(str,c,c)
	if char=='{' then k+=1
	elseif char=='}' then k-=1 end
	c+=1
   end

   local v=parse(sub(str,sc,c-1))
   if field then
	ar[field]=v
   else
	add(ar,v)
   end

   lc=c+2
   c+=1
  elseif char=='=' then
   field,lc=sub(str,lc,c-1),c+1
  elseif char==',' or c==#str then
   if c==#str then c+=1 end
   local v,vb=sub(str,lc,c-1),sub(str,lc+1,c-1)
   local fc=sub(v,1,1)
   if nums[fc] then v=v*1
   elseif fc=='%' then v=rnd(vb)
   elseif v=='true' then v=true
   elseif v=='false' then v=false
   end
   if field then
	if nums[sub(field,1,1)] then field=field*1 end
	ar[field]=v
   else
	add(ar,v)
   end
   field,lc=nil,c+1
  elseif char=='\n' then
   lc+=1
  end
  c+=1
 end
 return ar
end

function flr8(v) return flr(v/8) end	
function lerp(a,b,t) return (1-t)*a+t*b end
function coswave(w,opt,speed) local o=opt or 0 local s=speed or 100 return w*cos(ticks/s*4+o) end



--level engine
function load_lvl(lv_x,lv_y,lv_w)
	foreach(objects,del_object)
	--current level
	level.x = lv_x 
	level.y = lv_y 
	level.w = lv_w 
	-- entities
	for tx=0,flr8(lv_w)-1  do
		for ty=0,15 do
			local tile = mget(lv_x*flr8(lv_w)+tx,lv_y*16+ty);
			foreach(types, 
			function(type) 
				if type.tile == tile then
					init_obj(type,tx*8,ty*8) 
				end 
			end)	
		end
	end
end





--object factory
function init_obj(type,x,y)
	local obj={}
	obj.type = type
	obj.collideable=true
	obj.solids=true
	obj.spr = type.tile
	obj.flip = {x=false,y=false}
	obj.x = x
	obj.y = y
	obj.hitbox = { x=0,y=0,w=8,h=8 }
	obj.spd = {x=0,y=0}
	obj.rem = {x=0,y=0}
	obj.x%=level.w
	obj.collide=function(type,ox,oy)
		local other
		for i=1,count(objects) do
			other=objects[i]
			if other ~=nil and other.type == type and other != obj and other.collideable and
				other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and 
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and 
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy then
				return other
			end
		end
		return nil
	end
    obj.move=function(ox,oy)
        obj.x%=level.w
		local amount
		-- [x] get move amount
 		obj.rem.x += ox
		amount = flr(obj.rem.x + 0.5)
		obj.rem.x -= amount
		obj.move_x(amount,0)
		-- [y] get move amount
		obj.rem.y += oy
		amount = flr(obj.rem.y + 0.5)
		obj.rem.y -= amount
		obj.move_y(amount)
	end
	obj.move_x=function(amount,start)
			obj.x += amount
	end
	obj.move_y=function(amount)
			obj.y += amount
	end
	add(objects,obj)
	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj
end

positions={}
function register_pos(obj)
	local p={}
	p.x=obj.x
	p.y=obj.y
	add(positions,p)
	if #positions>30 then
		del(positions,positions[1])
	end
end

function drw_object(obj)
	if obj.type.draw ~=nil then
		pal()
		obj.type.draw(obj)
	elseif obj.spr > 0 then
		pal()
		spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
	end
end

function del_object(obj)
	del(objects,obj)
end



--game utils
function glet(word,n)
	return sub(word,n+1,n+1)
end

function add_let(n)
	for l in all(letters) do
		if not l.act and glet(level.spell,n)==l.let then
		 l.act=true
		 add(spell_progress,l)
		end
	end
	if #spell_progress == #letters then   
		init_obj(exit_door,0,36)
	end  
end
function rnd_let()
	value = flr(rnd(#letters)) +1
	value%=#letters
	for l in all(letters) do
		if l.act and glet(level.spell,value)==l.let then
			value = rnd_let()
		end
	end
	return value
end

function total_score()
	local total = 0
	foreach(progress.levels,function(donelevel)
		total += donelevel.score
	end)
	total += progress.score
	return total
end

function fsc(s) return sub("0000000"..s, -8) end
function fmin(t) return flr(t/60) end
function fsec(t) return flr(t)%60 end
function printo(str,startx,starty,col,col_bg)
	print(str,startx+1,starty,col_bg)
	print(str,startx-1,starty,col_bg)
	print(str,startx,starty+1,col_bg)
	print(str,startx,starty-1,col_bg)
	print(str,startx+1,starty-1,col_bg)
	print(str,startx-1,starty-1,col_bg)
	print(str,startx-1,starty+1,col_bg)
	print(str,startx+1,starty+1,col_bg)
	print(str,startx,starty,col)
end
function printw(str,x,y,col,force,speed,out)
	local s=speed or 100
	local f=force or 2.5
	local o=out or false
	for i=0,#str,1 do
		if o then
		printo(glet(str,i),x+(i*4),y+coswave(f,i/8,s),col,o)	
		else
		print(glet(str,i),x+(i*4),y+coswave(f,i/8,s),col)	
		end	
	end
end

function printc(str,x,y,col,col_bg,special_chars)
	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	printo(str,startx,starty,col,col_bg)
end

function text_center(str,cw) return 64-(#str*cw) end

function mcpy(dest,src)
	for i=0,319,4 do
	 poke4(dest+i,peek4(src+i))
	end
end
   
function print_big(text,x,y,col,factor)
	poke(0x4580,peek(0x5f00+col))
	poke2(0x4581,peek2(0x5f00))
	poke4(0x4583,peek4(0x5f28))
	poke2(0x4587,peek2(0x5f31))
	poke(0x4589,peek(0x5f33))
	poke(0x5f00+col,col)
	poke2(0x5f00,col==0 and 0x1100 or 0x0110)
	mcpy(0x4440,0x0)
	mcpy(0x0,0x6000)
	camera()
	fillp(0)
	rectfill(0,0,127,4,(16-peek(0x5f00))*0x0.1)
	print(text,0,0,col)
	mcpy(0x4300,0x6000)
	mcpy(0x6000,0x0)
	mcpy(0x0,0x4300)
	camera(peek2(0x4583),peek2(0x4585))
	sspr(0,0,128,5,x,y,128*factor,5*factor)
	mcpy(0x0,0x4440)
	poke(0x5f00+col,peek(0x4580))
	poke2(0x5f00,peek2(0x4581))
	fillp(peek2(0x4587)+peek(0x4589)*0x.8)
end

function upd_message()
	if #message > 0 then message_t +=1 end
	if message_t > #message*16 and #message > 0 then
		message = ""
		message_t = 0
	end
end

function init_camera(target)
	local c=
	{
		tar=target,--target to follow.
		pos={x=target.x,y=target.y},
		pull_threshold=8, 
		update=function(self)
			self.pos.x=self.tar.x
			if self:pull_max_y()<self.tar.y then
				self.pos.y+=min(self.tar.y-self:pull_max_y(),4)
			end
			if self:pull_min_y()>self.tar.y then
				self.pos.y+=min((self.tar.y-self:pull_min_y()),4)
			end
		end,
		cam_pos=function(self)
			return self.pos.x-64,self.pos.y-64
		end,
		pull_max_x=function(self)
			return self.pos.x+self.pull_threshold
		end,
		pull_min_x=function(self)
			return self.pos.x-self.pull_threshold
		end,
		pull_max_y=function(self)
			return self.pos.y+self.pull_threshold
		end,
		pull_min_y=function(self)
			return self.pos.y-self.pull_threshold
		end
	}
	return c
end

--game objects
world_door = {
	tile = 32,
	init=function(this)
		this.flip=false
		this.levitate=0
		this.spr_x=0
		this.spr_y=17
		this.hitbox = { x=0,y=0,w=8,h=15 }
		this.destination=level
		this.loop_spr = rnd(100)
		if (this.x == 56) this.destination=level_list[1]
		if (this.x == 0) this.destination=level_list[2]
		if (this.x == 8) this.destination=level_list[3]
		if (this.x == 64) this.destination=level_list[4]
		if (this.x == 224) this.destination=level_list[5]
		if (this.x == 176) this.destination=level_list[6]
		if (this.x == 216) this.destination=level_list[7]
		foreach(progress.levels,function(donelevel)
			if this.destination.name == donelevel.name then
				this.isclosed=true
			end
		end)
	end,
	update=function(this)
		this.loop_spr+=5
		local hit=this.collide(mozle,0,0)
		if hit~=nil and not this.isclosed then
			init_obj(vanish,this.x,this.y)
			is_dead=true
			destination = this.destination	
			 fadeto(level_screen,true) 
		end

	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
				pal()
				printc(''..this.destination.name,this.x+4+i,this.y-6+coswave(2.5),7,0,0)
				if this.isclosed then
					pal(12,13,0)
					pal(4,5,0)
				else
					for j=300,540,60 do
						if this.loop_spr > j then
							local a,b,c = 0,0,0
							if j == 360 then a=5 b=5 c=-5 end
							if j == 420 then a=-6 b=5 c=0 end
							if j == 480 then a=5 b=-6 c=0 end
							pal(7,7+a,0)  
							pal(12,7+b,0) 
							pal(1,12+c,0) 
						end
					end
					if this.loop_spr > 540 then
						this.loop_spr=0
					pal()
					end
				end
				sspr(this.spr_x,this.spr_y,this.hitbox.w,this.hitbox.h,this.x+i,this.y)
		end
	end
}
add(types,world_door)
function nomorefizzle() return level.rounds[#level.rounds].tot_fizzles == level.rounds[#level.rounds].fizzles end
exit_door = {
	init=function(this)
		this.flip=false
		this.levitate=0
		this.spr_x=0
		this.spr_y=17
		this.hitbox = { x=0,y=0,w=8,h=15 }
		this.open = false
		message = "an exit portal has appeared !"
	end,
	update=function(this)
		if level.rounds[#level.rounds].item_p == 100 then
			if this.open == false then
			sfx(57)
			this.open = true
			message = "the exit is now open !"
			end
		end
		local hit=this.collide(mozle,0,0)
			if hit~=nil and this.open then
				time_stop = true
				if #level.rounds == level.max_round then
					is_dead=true
					progress.time +=10
					fadeto(score_screen,true)
					del_object(this)
				else
					init_obj(vanish,this.x,this.y)
					del_object(this)
					is_dead=true
					message = "alriiiight"
					state.upd = upd_end_round
				end
			end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			sspr(this.spr_x,this.spr_y,this.hitbox.w,this.hitbox.h,this.x+i,this.y)
			printc('exit',this.x+4+i,this.y-6,7,0,0)
		end
	end
}
add(types,exit_door)

house = {
	tile=64,
	init=function(this)
		this.spr_x=0
		this.spr_y=32
		this.hitbox = { x=0,y=0,w=31,h=32 }
	end,
	update=function(this)
		if ticks%60 > 50 then 
		init_obj(smoke,this.x,this.y)
		end
		local hit=this.collide(mozle,0,0)
		if hit~=nil and btn(2) then
			 combine_screen()
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			sspr(this.spr_x,this.spr_y,this.hitbox.w,this.hitbox.h,this.x+i+4,this.y+5)
		end
	end
}
add(types,house)

spawn_fizzle = {
	tile= 16,
	init=function(this)
		this.wave_timer=flr(rnd(60))
	end,
	update=function(this)
		this.wave_timer+=1
		this.wave_timer%=200
		if this.wave_timer == 100 
		and level.fizzles < 15 
		then
			if not nomorefizzle() then
			init_obj(vanish,this.x,this.y)
			init_obj(fizzle,this.x,this.y)
			level.fizzles +=1
			else
				if level.rounds[#level.rounds].item_p < 99 then
					level.rounds[#level.rounds].tot_fizzles+=flr(15+rnd(15))
				end
			end
		end
	end,
	draw=function(this)
	end  
}
add(types,spawn_fizzle)

spawn_mozle = {
	tile=1,
	init=function(this)
		this.spr=41
		this.target= {x=this.x,y=this.y,dx=0}
		cam = init_camera(this.target)
		this.y=0
		this.spd.y=0
		this.state=2
		this.delay=0
		this.solids=false
	end,
	update=function(this)
				-- jumping up
				if this.state==0 then
					if this.y < this.target.y+16 then
						this.state=1
						this.delay=3
					end
				-- falling
				elseif this.state==1 then
					this.spd.y+=0.5
					if this.spd.y>0 and this.delay>0 then
						this.spd.y=0
						this.delay-=1
					end
					if this.spd.y>0 and this.y > this.target.y then
						this.y=this.target.y
						this.spd = {x=0,y=0}
						this.state=2
						this.delay=5
					end
				-- landing
				elseif this.state==2 then
					cam=init_camera(init_obj(mozle,this.x,this.y))
					del_object(this)
				end
	end,
	draw=function(this)
		spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
	end
}
add(types,spawn_mozle)

smoke={
	init=function(this)
		this.spr=90
		this.spd.y=-0.1
		this.spd.x=0.3+rnd(0.2)
		this.x+=-1+rnd(2)
		this.y+=-1+rnd(2)
		this.flip.x=flr(rnd(1.9))
		this.flip.y=flr(rnd(1.9))
		this.solids=false
	end,
	update=function(this)
		this.spr+=0.2
		if this.spr>=92 then
			del_object(this)
		end
	end
}

function zspr(n,w,h,dx,dy,dz,fx,fy)
	sspr(8*(n%16),8*flr(n/16),8*w,8*h,dx,dy,8*w*dz,8*h*dz,fx,fy)
end
vanish={
	init=function(this)
		this.spr=42
		this.y-=4
		this.t=0
	end,
	update=function(this)
		this.t+=1
		if this.t > 40 then
		this.spr+=0.2
		end
		if this.spr>=44 then
			del_object(this)
		end
	end,
	draw=function(this)
		zspr(flr(this.spr),1,1,this.x,this.y,1.3)
	end
}
mozle=
{   
	init=function(self)
	is_dead = false
	self.max_dx=3--max x speed
	self.max_dy=2.5--max y speed
	self.jump_speed=-8--jump veloclity
	self.acc=0.05--acceleration
	self.dcc=0.8--decceleration
	self.air_dcc=1--air decceleration
	self.grav=1
	self.hitbox = { x=0,y=0,w=12,h=16 }
	self.jump_button=
	{
		is_pressed=false,--pressed this frame
		is_down=false,--currently down
		ticks_down=0,--how long down
	}
	self.jump_hold_time=0--how long jump is held
	self.min_jump_press=5--min time jump can be held
	self.min_jump_press=5--min time jump can be held
	self.max_jump_press=15--max time jump can be held
	self.jump_btn_released=false--can we jump again?
	self.grounded=false
	self.was_on_ground=false
	self.clippingdown=false
	self.airtime=0--time since grounded

	--animation definitions.
	--use with set_anim()
	self.anims=
	{
		["stand"]=
		{
			ticks=1,--how long is each frame shown.
			frames={54},--what frames are shown.
		},
		["walk"]=
		{
			ticks=5,
			frames={58,60,62,60},
		},
		["jumpdown"]=
		{
			ticks=1,
			frames={52},
		},
		["jumpup"]=
		{
			ticks=1,
			frames={88},
		},
		["slide"]=
		{
			ticks=1,
			frames={56},
		},
		["death"]=
		{
			ticks=15,
			frames={1},
		},
	}

	self.curanim="walk"--currently playing animation
	self.curframe=1--curent frame of animation.
	self.animtick=0--ticks until next frame should show.
	self.death_duration=120

	self.set_anim=function(self,anim)
		if(anim==self.curanim)return--early out.
		local a=self.anims[anim]
		self.animtick=a.ticks--ticks count down.
		self.curanim=anim
		self.curframe=1
	end
 end,
	update=function(self)
	 if not is_dead then

		--track button presses
		local bl=btn(0) --left
		local br=btn(1) --right
		local bd=btn(3) --down
		--move left/right
		if bl==true then
			self.spd.x-=self.acc
			br=false--handle double press
		elseif br==true then
			self.spd.x+=self.acc
		else
			if self.grounded then
				self.spd.x*=self.dcc
			else
			 self.spd.x*=self.air_dcc
			end
		end
		if br then
		 self.flip.x=false
	 elseif bl then
		 self.flip.x=true
	 end
		--limit walk speed
		self.spd.x=mid(-self.max_dx,self.spd.x,self.max_dx)
		--hit slopes
		move_slope(self)
		--jump buttons
	 
		 self.jump_button.is_pressed=false
		 if btn(5) then
			if not self.jump_button.is_down then
				self.jump_button.is_pressed=true
			end
			self.jump_button.is_down=true
			self.jump_button.ticks_down+=1
			else
			self.jump_button.is_down=false
			self.jump_button.is_pressed=false
			self.jump_button.ticks_down=0
			
		 end
		 
		 if self.jump_button.is_down then
			local new_jump_btn=self.jump_button.ticks_down<10
			if self.jump_hold_time>0 or (self.airtime<5 and new_jump_btn) and  self.grounded then
				if(self.jump_hold_time==0)sfx(61)
				self.jump_hold_time+=1
				if self.jump_hold_time<self.max_jump_press  then
					self.spd.y=self.jump_speed
				end
			end
		else
			self.jump_hold_time=0
		end
		
		self.spd.y+=self.grav
		self.spd.y=mid(-self.max_dy,self.spd.y,self.max_dy)
		if  not collide_floor(self) and not move_slope(self) then
			self.grounded=false
			self.airtime+=1
			if self.spd.y < 0 then
				self:set_anim("jumpup")
			else
				self:set_anim("jumpdown")
			end
		end
		if self.grounded and not self.was_on_ground then
			init_obj(smoke,self.x-6,self.y+4)
		end

		if self.grounded then
		 self.spd.y=0
		 self.airtime=0

			if br then
				if self.spd.x<0 then
					self.acc=0.15
					--pressing right but still moving left.
					self:set_anim("slide")
					init_obj(smoke,self.x-4,self.y+4)

				else
					self.acc=0.05
					self:set_anim("walk")
				end
			elseif bl then
				if self.spd.x>0 then
					--pressing left but still moving right.
					self.acc=0.15
					self:set_anim("slide")
					init_obj(smoke,self.x-4,self.y+4)

				else
					self.acc=0.05
					self:set_anim("walk")
				end
			else
				self:set_anim("stand")
			end
		end

		--fall through superpower
		--check if allowed to fall through (2 tiles below)
		spr_id=mget(level.x*flr8(level.w)+flr8(self.x),level.y*16+flr8(self.y+16))
		if bd==true and btn(4)==true and fget(spr_id,7) and fget(spr_id,6) then
			self.clippingdown=true
		end
		if self.clippingdown and self.airtime>4 then
			self.clippingdown=false
		end
		
		--time runs out
		if progress.time <= 0 then
		 time_stop = true
		 progress.time +=1
		 self:set_anim("death")
		 message="ouch !"
		 progress.lives-=1
		 is_dead=true
		
		 if progress.lives < 0 then 
			endgame=true 
		 else
			state.upd=upd_life_lost
		end
		end
	 end
		if is_dead then
		 self.death_duration-=1
		 del_object(self)
		end
		--flip

	 --anim tick
	 self.animtick-=1
	 if self.animtick<=0 then
		 self.curframe+=1
		 local a=self.anims[self.curanim]
		 self.animtick=a.ticks--reset timer
		 if self.curframe>#a.frames then
			 self.curframe=1--loop
		 end
	 end
	 self.was_on_ground = self.grounded
	 register_pos(self)
	end,

	--draw the player
	draw=function(self)
		local a=self.anims[self.curanim]
		local frame=a.frames[self.curframe]
		local hairpos = -3
		if self.flip.x then 
			hairpos = 2
		end

		if  (self.spd.x > 0.2 or self.spd.x < -0.2)then
		circfill(self.x+hairpos-self.spd.x,self.y-5-self.spd.y+coswave(2,0,100-(abs(self.spd.x)*10)),1.5,8)
		circfill(self.x-hairpos-self.spd.x,self.y-5-self.spd.y+coswave(2,0,100-(abs(self.spd.x)*10)),1.5,8)
		end
			spr(frame,
			self.x-(self.hitbox.w/2),
			self.y-(self.hitbox.h/2),
			self.hitbox.w/8,self.hitbox.h/8,
			self.flip.x,
			false)
	end,	
}
add(types,mozle)

points_item = {
	init=function(this)
		this.spr=20
		this.angle=0
		this.lifespan = 240
	end,
	update=function(this)
		this.lifespan-=1
		this.y-=0.2
		this.x-=sin(this.angle)*0.5
		this.angle+=0.009
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			sfx(54)
			level.score += 500
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
		if this.lifespan == 0 then
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			spr(this.spr,this.x+i,this.y)
			circ(this.x+4+i,this.y+4,6,7)
		end
	end
}
add(types,points_item)

time_item = {
	init=function(this)
		this.spr=22
		this.angle=0
		this.lifespan = 240
	end,
	update=function(this)
		this.lifespan-=1
		this.y-=0.2
		this.x-=sin(this.angle)*0.5
		this.angle+=0.009
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			sfx(55)
			level.score +=50
			progress.time +=10
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
		if this.lifespan == 0 then
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			spr(this.spr,this.x+i,this.y)
			circ(this.x+4+i,this.y+4,6,7)
		end
	end
}
add(types,time_item)

emergency_item = {
	init=function(this)
		this.spr=23
		this.angle=0
		this.lifespan = 240
	end,
	update=function(this)
		this.lifespan-=1
		this.y-=0.2
		this.x-=sin(this.angle)*0.5
		this.angle+=0.009
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			progress.time +=30
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
		if this.lifespan == 0 then
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			spr(this.spr,this.x+i,this.y)
			if ticks%4 > 2 then circfill(this.x+i+3,this.y+4,6,7) end
		end
	end
}
add(types,emergency_item)

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

collectible = {
	init=function(this)
		this.item = level.rounds[#level.rounds].item
		this.spr=level.rounds[#level.rounds].item.spr
		this.angle=0
		this.lifespan = 240
	end,
	update=function(this)
		this.lifespan-=1
		this.y-=0.2
		this.x-=sin(this.angle)*0.5
		this.angle+=0.009
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			sfx(56)
			if level.rounds[#level.rounds].item_p ~=100 then
				level.rounds[#level.rounds].item_p+=10
			end
			if level.rounds[#level.rounds].item_p == 100 then
				add(progress.items,shallowcopy(level.rounds[#level.rounds].item))
				init_obj(collected,this.x,this.y )
			end
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
		if this.lifespan == 0 then
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			spr(this.spr,this.x+i,this.y)
			circ(this.x+4+i,this.y+4,6,7)
		end
	end
}
add(types,collectible)



collected = {
	update=function(this)
 		local p=positions[20]
 		this.x=p.x
		this.y=p.y-4+coswave(1,0,300)
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			if ticks%4 > 2 then circfill(this.x+i+3,this.y+4,6,7) end
			spr(level.rounds[#level.rounds].item.spr, this.x+i,this.y)	
		end	
	end
}
add(types,collected)



fizzle = {
	tile=17,
	init=function(this)
		this.max_dx=3
        this.max_dy=3
        this.acc=0.05
        this.dcc=0.8
        this.air_dcc=1
        this.grav=0.02
		this.grounded=false
		this.airtime=0
		this.clippingdown=false
		this.move_timer=0
		this.lifespan=0
	end,
	update=function(this)
		this.move_timer+=1
		this.move_timer%=100
		this.ai = flr(rnd(3)) + 1
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			sfx(60)
		if #spell_progress < #letters  then
			init_obj(letter,this.x,this.y-16)
		else

			if level.rounds[#level.rounds].item_p < 100 then
				init_obj(collectible,this.x,this.y-16)
			elseif rnd(1)<0.9 then
				init_obj(points_item,this.x,this.y-16)
			elseif rnd(1)<0.3 and progress.time < 15 then
				init_obj(emergency_item,this.x,this.y-16)
			else
				init_obj(time_item,this.x,this.y-16)
			end
			
		end
		if level.rounds[#level.rounds].fizzles < level.rounds[#level.rounds].tot_fizzles then
			level.rounds[#level.rounds].fizzles +=1
		end
			level.fizzles-=1
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
		this.spd.x=mid(-this.max_dx,this.spd.x,this.max_dx)
		move_slope(this)
		this.spd.y+=this.grav
		this.spd.y=mid(-this.max_dy,this.spd.y,this.max_dy)
		if  not collide_floor(this) and not move_slope(this,true) then
			this.grounded=false
			this.airtime+=1
		end
		if this.grounded then
			this.spd.y=0
			this.airtime=0
		end
		if this.grounded then
			this.spd.x*=this.dcc
		else
			this.spd.x*=this.air_dcc
		end
		if this.move_timer == 0 then
			this.lifespan+=1
			if this.ai==1 then
				this.spd.x+=2
			elseif this.ai ==2 then
				this.spd.x-=2
			elseif this.ai==3 then
				--set anim idle
			end
		end
		if this.lifespan == 5 then
			level.fizzles-=1
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			spr(this.spr,
			this.x+i-(this.hitbox.w/2),
			this.y-(this.hitbox.h/2),
			this.hitbox.w/8,this.hitbox.h/8,
			this.flip.x,
			false)	
		end
	end
}

letter = {
	init=function(this)
		this.angle = 0
		this.let = rnd_let()
		this.lifespan = 240
	end,
	update=function(this)
		this.lifespan -= 1
		this.y-=0.2
		this.x-=sin(this.angle)*0.5
		this.angle+=0.009
		this.x%=level.w
		local hit=this.collide(mozle,0,0)
		if hit~=nil then
			sfx(59)
			--collect letter
			add_let(this.let)
			level.score +=100
			init_obj(vanish,this.x,this.y)
			del_object(this)
		end

		if this.lifespan == 0 then
			del_object(this)
		end 
	end,
	draw=function(this)
		for i=-level.w,level.w,level.w do
			printc(glet(level.spell,this.let), this.x+i, this.y, 7,0,0)	
			circ(this.x-1+i,this.y,5,7)
			
		end
	end,
}
add(types,letter)

--particles

clouds={}
for i=0,3 do
	add(clouds,{
		x=rnd(32)+65,
		y=rnd(16)+90
	})
end

stars = {}
for i=0,8 do
	add(stars,{
		x=rnd(128),
		y=rnd(128-20),
		c=7
	})
end


--physics & collisions--------------------------------
--gravity-y-y-y-y-------------------------------------
function pointonslope(x,y)
	spriteid=mget(level.x*flr8(level.w)+ flr8(x), level.y * 16 + flr8(y))
	if not fget(spriteid,1) then
	 --tile isn't a slope
	 return false
	end
	--define slope of tile
	x1=flr8(x)*8
	x2=x1+8
	y1=flr8(y)*8+8
	y2=y1-8
	if fget(spriteid,2) then
	 --halfstep up
	 y2=y1-4
	end
	if fget(spriteid,3) then
	 --halfstep up 2
	 y1-=4
	 y2-=1
	end
	if fget(spriteid,4) then
	 --fullstep up
	 y2-=1
	end
	if fget(spriteid,5) then
	 --fullstep down
	 y1=y2
	 y2+=8
	 y1-=1
	end
	if fget(spriteid,6) then
	 --halfstep down 2
	 y1=y2
	 y2+=4
	 y1-=1
	end
	if fget(spriteid,7) then
	 --halfstep down
	 y2=y1
	 y1-=4
	end
	--now check if x,y is below
	--the line between p1 and p2
	t=(x2-x)/8
	height=flr(lerp(y2,y1,t))
	if (height) return height
	return false
end

function move_slope(self,is_fizzle)
	local isfizzle=is_fizzle or false
	local center_offset = 4
	local bottom_offset= self.hitbox.h/2-1
	local right_offset=self.hitbox.w/4-1
	local left_offset=self.hitbox.w/4-1
	moving=false
	if self.spd.y>-1.15 and not self.clippingdown then
			if  pointonslope(self.x,self.y+bottom_offset) or 
				pointonslope(self.x+right_offset,self.y+center_offset) or 
				pointonslope(self.x-left_offset,self.y+center_offset) then
					self.spd.y=0
					self.y=ceil(height)-self.hitbox.h/2+1
					self.grounded=true
					moving=true
			end
		end
	return moving
end


function collide_floor(self)
	if self.spd.y<0 or self.clippingdown then
		return false
	end
	local landed=false
	for i=-(self.hitbox.w/3),(self.hitbox.w/3),2 do
		local tile=mget(level.x*flr8(level.w)+((self.x+i)/8),level.y*16+(self.y+(self.hitbox.h/2))/8)
		local ty = flr(self.y+4)%8
		if fget(tile,0)  or (fget(tile,0) and self.spd.y>=0 and ty<=1)  then	
			self.spd.y=0	
			self.y=(flr((self.y+(self.hitbox.h/2))/8)*8)-(self.hitbox.h/2)	
			self.airtime=0
			self.grounded=true
			landed=true
		end
	end
	return landed
end

function new_round(difficulty)
	level = destination
	if not difficulty then
		mode = 'easy' else mode = difficulty
	end
	local spells = spellbook[mode]
	local rand= flr(rnd(#spells-1)+1)
	level.spell = spells[rand]
	level.fizzle = 0
	letters={}
	spell_progress = {}
	for n=1,#level.spell do
		letters[n]={let=sub(level.spell,n,n),act=false}
	end
	add(level.rounds, {fizzles = 0, tot_fizzles = flr(rnd(#level.spell*2)+#level.spell*2)+10, item = item_list[flr(rnd(#item_list-1)+1)], item_p = 0})
end

function title_screen()
    state.upd = upd_title_screen
	state.drw = drw_title_screen
	dhovered = 0
end

function ingame()
	load_lvl(level.x,level.y,level.w)

	if level.name ~= "hub_world" then
		time_stop = false
		if #spell_progress ~=  #level.spell then
		message = 'collect '..#level.spell..' letters !'
		else
			init_obj(exit_door,0,36)
		end
		if level.rounds[#level.rounds].item_p == 100 then 
			init_obj(collected,64,64)
		end
	end
	state.upd = upd_ingame
	state.drw = drw_ingame

end

function level_screen()	 
	new_round(difficulty.name)
	state.upd = upd_level_screen
	state.drw = drw_level_screen
end

function combine_screen()
	hovered = 0
	selected = 0
	state.upd = upd_combine_screen
	state.drw = drw_combine_screen
end

function upd_combine_screen()
	level = hub_world
	local tot_items=progress.items
	if #tot_items > 0 then
			for i=1,#tot_items,1 do
				if (hovered == i) then tot_items[i].hovered = true  else tot_items[i].hovered = false end
			end
			if btnp(4) then 
				if not tot_items[hovered].selected and selected<2 then
					tot_items[hovered].selected=true
					selected +=1 
				else
					tot_items[hovered].selected=false
					selected -=1 
		
				end
				tot_items[hovered].hovered=false
			end
	end
	if(hovered < 1) then hovered = 1 elseif(hovered > #tot_items) then hovered = #tot_items end
	if btnp(2) then sfx(58) hovered -=1 end
	if btnp(3) then sfx(58) hovered +=1 end
	if btn(5) then 
		if selected == 2 then
			resolve_combine(tot_items) 
		else
			fadeto(ingame,true)
		end
	end	
end

function drw_ui(scr_title,padd)
	rect(12,12,116,116,6)
	rectfill(13,14,115,116,5)
	rectfill(13,13,115,115,13)
	rectfill(
		text_center(scr_title,1.9)-padd,
		24-padd+1+coswave(1.2),
		129-text_center(scr_title,1.9)+padd,
		28+padd+1+coswave(1.2)
		,2)
	rectfill(text_center(scr_title,1.9)-padd,24-padd+coswave(1.2),129-text_center(scr_title,1.9)+padd,28+padd+coswave(1.2)	,14)
	print(scr_title,text_center(scr_title,1.9),24+	coswave(1.2)	,7)
end

function drw_combine_screen()
	drw_bg(bg_colors,bg_patterns)
	drw_ui("fusee:combine",3)

	local msg = [[here, you can combine
	essence you found !]]
	local tot_items=progress.items
	if #tot_items<1 then
		local msg2 = [[come back when you've
		   found some !]]
		print(msg2,text_center(msg2,1.1),64	,7)
		if ticks%60 > 30 then print("press X to continue",text_center("press X to continue",2),120,7) end
	end
	for i=1,#tot_items,1 do
		if tot_items[i].hovered then
			if ticks%60 > 30 then print(tot_items[i].name,text_center(tot_items[i].name,1.9),40+(i*8)	,8)end

		elseif tot_items[i].selected then print(tot_items[i].name,text_center(tot_items[i].name,1.9),40+(i*8)	,9)
		else
			print(tot_items[i].name,text_center(tot_items[i].name,1.9),40+(i*8)	,7)
		end 
	end
	if selected == 2 then
		local msg3= 'ready to combine !'
		print(msg3,text_center(msg3,1),110	,7)

	end
	print(msg,text_center(msg,1),36	,7)
end

function score_screen()
	 
	message=''
	score = {
		name = level.name,
		points = level.score,
		fizzles = level.fizzles,
		remaining = 0
	}
	foreach(level.rounds,function(round)
		score.remaining += round.fizzles 
	end)
	add(progress.levels,level)
	state.upd = upd_score_screen
	state.drw = drw_score_screen
	 
end

function upd_ingame()
	if cam then cam:update() end
	foreach(objects,function(obj)
		obj.move(obj.spd.x,obj.spd.y)
		if obj.type.update~=nil then
			obj.type.update(obj) 
		end
	end)
	if endgame==true then gameover() end
end

function gameover()
	 
endgame=false
	message="game over !"
	state.upd = upd_gameover
	state.drw = drw_gameover
end

function upd_gameover()
end

function drw_gameover()
end

function upd_score_screen()
	level = hub_world
	if btn(5) or btn(4) then
		fadeto(ingame,true)
	end	
end

function drw_score_screen()
	drw_bg(bg_colors,bg_patterns)
	drw_ui(score.name.." results",3)

	
	print("points : "..score.points,16,35,7)
	print("fizzles : "..score.remaining,16,45,7)
	print("fizzles left : "..score.fizzles,16,55,7)
	if ticks%60 > 30 then print("press — to continue",text_center("press X to continue",2),120,7) end

end

function upd_level_screen()
	if btn(5) or btn(4) then
		fadeto(ingame,true)
	end	
end

function upd_end_round()
	foreach(objects,function(obj)
		if obj.type.update~=nil then
			obj.type.update(obj) 
		end
		if obj.type==fizzle or obj.type == collectible or obj.type == collected then
			init_obj(vanish,obj.x,obj.y)
			del_object(obj)
		end	
	end)
	-- 
	if btnp(5) or btnp(4) then
		new_round(difficulty.name)
		fadeto(ingame,true)
	end	
end

function upd_life_lost()
	if btnp(5) or btnp(4) then
		progress.time+=50
		fadeto(ingame,true)
	end	
end

function drw_level_screen()
	drw_bg(bg_colors,bg_patterns)
	--drw_warping animation loading --
    printw("entering "..level.name,text_center("entering "..level.name,2),96,6,1.5,200,true)
end
function drw_mg()
	rectfill(0,110,128,128,7)
	foreach(stars, function(c)
			pset(c.x,c.y,c.c)
	end)
	foreach(clouds, function(c)
		for i=0,128,32 do
			init_x = flr(i-(cam:cam_pos()/2)+c.x+ticks/10 )%160
			sspr(104,8,16,16,init_x-8,c.y,8,8,true)
			sspr(104,8,16,16,init_x-16,c.y,16,16)
		end
	end)
		-- parallax scrolling
		for i=0, 128, 32 do
			local x = flr(i-(cam:cam_pos()/2)+ticks/5 )%160
			sspr(104,8,16,16,x-4,102+coswave(1,0,300)+(i/60),8,8,true)
			sspr(104,8,16,16,x-16,100+coswave(1,0,300)+(i/60))
			sspr(104,8,16,16,x-32,100+coswave(1,0,300)+(i/60),16,16,true)
			sspr(104,8,16,16,x-8,98+coswave(1,0,300)+(i/60),8,8,false)
	
		end
	if cam then camera(cam:cam_pos()) end
	circfill(cam:cam_pos()+45,30,10,5)
	circfill(cam:cam_pos()+45,31,9,7)
	circfill(cam:cam_pos()+40,24,1,6)
	circfill(cam:cam_pos()+48,29,1,6)
	circfill(cam:cam_pos()+41,34,2,6)
	circfill(cam:cam_pos()+50,36,1,6)
end

function drw_ingame()
	if season == "snow" or level.is_snow then
		for i=0,16 do pal(i,spal[i],0) end
	elseif season == "fall" or level.is_fall then
		for i=0,16 do pal(i,fpal[i],0) end 
	elseif season =="lava" or level.is_lava then
		bg_colors=parse"10,6,9,14,9,14,9,14,14,2,2,2,2,2"
		for i=0,16 do pal(i,lpal[i],0) end 
	else
		bg_colors=parse"15,6,2,1,2,1,2,1,1,0,0,0,0,0"
	end
	drw_bg(bg_colors,bg_patterns)
	drw_mg()

	foreach(objects, function(o)
		if o.type==house then
			drw_object(o)
		end
	end)

	--"infinite levels"
	for i=-level.w,level.w,level.w do
		map(level.x*16*3,level.y*16,i,0,flr8(level.w),8*2,4) --flag 2 bg
		map(level.x*16*3,level.y*16,i,0,flr8(level.w),8*2,1) --flag 0 solids
		map(level.x*16*3,level.y*16,i,0,flr8(level.w),8*2,2) --flag 1 slopes
	end
	foreach(objects, function(o)
		if o.type==collected then
			drw_object(o)
		end
	end)
	foreach(objects, function(o)
		if o.type==mozle then
			drw_object(o)
		end
	end)
	foreach(objects, function(o)
		if o.type~=house or o.type~=collected or o.type~=mozle then
			drw_object(o)
		end
	end)
		   drw_hud()

end

function drw_hud()
	camera(0,0)
	hud()
end

function hud()
	fillp(Ž\1)
	rectfill(0,0,128,14,0x10)
	rectfill(0,112,128,128,0x10)
	fillp()
	if level.spell then
		px=text_center(level.spell,4) 
		for k=1,#level.spell do
			l=letters[k]
			cl=13
			if l.act then 
				cl=ticks%60==k and 7 or 14
			end
			if #spell_progress == #level.spell then
				cl=8+(ticks/10+k)%8
			end
			print_big(l.let,px,3,2,2)

			print_big(l.let,px,2,cl,2)

			-- print(l.let,px,1,cl )
			px+=8
		end
	end
	if #level.rounds > 0 and #spell_progress == #level.spell and level.rounds[#level.rounds].item_p > 99 then
		spr(17,4,0)
	    printo(tostr(level.rounds[#level.rounds].tot_fizzles - level.rounds[#level.rounds].fizzles), 5, 9, 2,13) 
		print(tostr(level.rounds[#level.rounds].tot_fizzles - level.rounds[#level.rounds].fizzles), 5, 8, 7) 
	end
	if #level.rounds > 0 then
		rectfill(75,120,125,125,13)
		printo(level.rounds[#level.rounds].item.name,95,115,2,13)
		print(level.rounds[#level.rounds].item.name,95,114,7)

		if level.rounds[#level.rounds].item_p > 9 then
			rectfill(75,120,75+(level.rounds[#level.rounds].item_p/2),125,8)
			circfill(73+(level.rounds[#level.rounds].item_p/2)+coswave(2,1/16,50),122,2,2)
			circfill(73+(level.rounds[#level.rounds].item_p/2)+coswave(2,1/1.8,50),124,1,8)
		end	
		sspr(64,56,53,8,75,119)
		spr(level.rounds[#level.rounds].item.spr,83,129)	

	end
	if level.name =="hub_world" then
		printo('moz-'..fsc(total_score()),3,118,2,13)
		print('moz-'..fsc(total_score()),3,117,7)
	else
		printo('moz-'..fsc(level.score),3,118,2,13)
		print('moz-'..fsc(level.score),3,117,7)
	end
	printo('time', 107, 2, 2,13)
	print('time', 107, 1, 9)
	if fsec(progress.time) < 10 then
		printo(fmin(progress.time).. ':0'..fsec(progress.time), 107, 9, 2,13) 
		if progress.time < 10 then
			print(fmin(progress.time).. ':0'..fsec(progress.time), 107, 8, 8) 
		else			
			print(fmin(progress.time).. ':0'..fsec(progress.time), 107, 8, 7) 
		end
	else
		printo(fmin(progress.time).. ':'..fsec(progress.time), 107, 9, 2,13) 
		print(fmin(progress.time).. ':'..fsec(progress.time), 107, 8, 7) 
	end
	
	--lives
	spr(19,55,116)
	print('x'..progress.lives,64,118,7)
end

function drw_bg(bg_cols,bg_ptrns)
	local bg_y=128-16
	for i=0,#bg_cols-2 do
		color(bg_cols[i+1]*16+bg_cols[i+2])
		for j=0,3 do
		fillp(bg_ptrns[j+1])
		rectfill(0,bg_y,127,bg_y-1)
		if bg_y>16 then
		bg_y-=2
		end
		end
	end
	fillp(0b0)
end
function upd_chose_difficulty()
		local tot_items=difficulty_list
		for i=1,3,1 do
			if (dhovered == i) then 
				tot_items[i].hovered = true 
				difficulty = tot_items[i]
			 else tot_items[i].hovered = false end

		end
		if(dhovered < 1) then dhovered = 1 end
		if(dhovered > 3) then dhovered = 3 end
		if btnp(2) then sfx(58) dhovered -=1 end
		if btnp(3) then sfx(58) dhovered +=1 end
		if btnp(4) then  fadeto(ingame,true) end	
		
end
function drw_chose_difficulty()
		draw_splash_screen()	
		printc("chose your difficulty",64,96,7,0,2)
		for i=1,3,1 do
			if difficulty_list[i].hovered then
				spr(18,text_center(difficulty_list[i].name,2)-8+coswave(4,1/8),94+(i*8))
				spr(18,text_center(difficulty_list[i].name,2)+(#difficulty_list[i].name*4)+coswave(4,5/8),94+(i*8),1,1,true,false)
			end
				printo(difficulty_list[i].name,text_center(difficulty_list[i].name,2),96+(i*8),7)				 
		end
end
function upd_title_screen()
	if btnp(4) or btnp(5) then
		state.upd=upd_chose_difficulty
		state.drw=drw_chose_difficulty
	end
end

function drw_title_screen()
	draw_splash_screen()	
	printc("press —/Ž to start",64,98,7,0,2)
	printc("designed by tarro",64,112,7,0,0)
end

--p8 functions
--------------------------------
function _init()
	ticks=0
	init_items()
	init_levels()
	init_spellbook()
	init_gfx()
	music(0)
	title_screen()
end

function _update60()
	ticks+=1
	ticks%=32000
	if time_stop==false then
		progress.time -= 1/60
	end
	state.upd()
	upd_message()
end

function _draw()
	cls()
	state.drw()
	if #message > 0 then
		printo(message,text_center(message,2),22,7)
	end
	if fade_n then
		fade_n+=1
		n=fade_rev and fade_n or 15-fade_n
		for i=0,15 do
		 pal(i,sget(120+i,60+flr(n/4)),1) 
		end
		if fade_n==15 then
		 fade_nxt()
		 fade_n=nil
		 if fade_rev then
		  fadeto(pal,false)
		 end
		end 
	end
end

__gfx__
00000000bbbbbbbb333033b3000000000000bb33000000b33b000000333b00000000000055544444444ddd445554444444ddddd4454554454544544544554444
00000000b8bbbb8b33b333b300000000033b333e0000003113b000001b33300000000000454444334ddd5ddd45444544dd51015d5544544444dd45545544dd44
00700700b88bb88b13b31b31000000303b33b311000033b22333b000333b33b00000000044450303ddd5155d44444d5155100015541d4445414dd4454144d10d
00077000b888888b2313211200000b3333bb3134000b3b1441b3b00011313b33b00000003445000415510115444151d410000001441dd454404d1044441b1004
00077000b88bb88b412144250000333b3333123500b3b145521330005213333333bb000035000544011001015545d114000000004411445454d514d454db0014
00700700b88bb88b54444545000334331331245403331254454be3b0454211311133b0004b00544400100000444dd44400000000444444444410ddd454dbb15d
00000000b88bb88b44544445333b3331421545450b124545545213335454524243b33300434444540000000044444454000000005544445555d54d45555db4d5
00000000bbbbbbbb544454443b331131545455553154545555452113555545454133133344444555000000004444455500000000544445544444455444544454
bbbbbbbb003b00b00000000008800880009aaa000000000000a88a00001111000000000000007600a0000070d44144445d444424000000000000000054455444
bb88888b003bb03b760000008888888809aa7aa0005dd5000a9999a0013bb310000000000a07776000000777444444d155d44452000000000000000044454444
bb88888b0003bc7c776000008278772809a9a7a005677650a977779a13baab31000077a0007777760000007024545d5115d4444500000000dddd0000444d4445
bb88bbbb33007171777600000888888009a9a7a00d7777d0977d77791ba77ab100000000000777600000000052444550005dd4440000000d6777d00044d55444
bb8888bb37307777777d00008119911809a9a7a00d7777d09777dd791ba77ab100000000076076000000000045455510001554d4000000067777760054dd4444
bb88bbbb037b366077d00000817ff17809a9a7a0056776509677776913baab31077a0000777600a0000000004d551010001055140000d0677777770054444544
bb88bbbb003367767d000000827ff27809aa9aa0005dd50009677690013bb31000000000076a000000000000d55110000000115d000d6d6777777d6044455454
bbbbbbbb00007070000000000ffffff0009aaa0000000000009999000011110000000000000000007000000a5110100000001015066676776777d67044554445
000000000070000008880080000cccc000666666007aaaab0000000000300000006666000001100011101110000000000000000000677600766d677644544444
0b344400007770030089800000cccddc6667776007aaaab000bb3e00003000000677776000122100777177710000000000000000677777767777777744d54444
035775403007773b008aa8000cccd00c0dd555607aaab0000b3e313003b00000077aa7700128821071717171000000000000000077777f7777777777444d4444
3577c75bb3777703089aa980dccccd000777760007aaab00311333113bbb000007a77a701288782177717771016166100000b0007777fff777777fff45444445
457c73530b36663b89aaa980ccccc7d000ddddd0007aaab0113111333bb3bb0007a77a701888888111711110167777611666666177777f777777ff664d44455d
45c7cc3300b777b0089aaa98ccccc7d0006666000007ab001414444103bb33b3077aa7701288882177717771016616100000b00077f77777777ff00044445dd4
457ccc54007c7c708089a9800ccc7d000ddd0000007ab00004444440003bbb30067777600122221011101110000000000000000067777776f70000004445d444
45cccc54000171000008880000ccd0000006000007ab0000004442000000000000666600001111000000000000000000000000000067760060000000444d4444
45cccc54003b00b0003b00b003b00030000880000000000000880000000000000088000000000000008800000000000000000000000000000008800000000000
35ccc154003bb03b003bb03b003b03bb008888000888000008888000888000000888800088800000088880008880000000088000000000000088880008880000
33cc1c533003bc7c3003bc7c0003bc7c088888888888800088888888888800008888888888880000888888888888000000888800088800000888888888888000
b531c154330071713300717133007171088827877288800088827877288800008882787728880000888278772888000008888888888880000888278772888000
451c1c53373077773730777733007777008288888828000008288888828000000828888882800000082888888280000008882787728880000082888888280000
35111153037b7660037b766003307660070811991188000000811991188000000081199118800000008119911880000000828888882800000008119911880000
04511530066777700667777006677770cc0817ff1780000000817ff17800000000872ff27800000000817ff1780000000008119911880000000817ff17800000
0043340076000067700000070670770000c827ff2780000000827ff27800000000872ff27800000000827ff278000000000817ff17800000000827ff27800000
0000000000003b777770000000000000000cffffffc00000000ffffff0000000000ffffff0000000c00ffffff0000000000827ff278000000000ffffff000000
000006700037b31111177700000000000000ccccc00000000000ccc0000000000ccccc0000000000cc0cccc0000000000cc0ffffff0000000000cccc00000000
000066770076317ffff166700000bb00000cccccccc00000000cccc0000000007cccccc700000000cc7ccc0000000000700ccccc00000000070cccc000000000
0000d66770763f67667766700bbb3b0000cc111511c0000000cccccc00000000ccccc000000000000ccccc70000000000cccccc0c7000000007ccc5770000000
00000d66717616677676162bbbb3b3b0000c111151000000007ccccc7000000000cccc000000000000c55500000000000ccccccc0000000000ccccccc0000000
000000d661673776776617333b33b3b000000040500000000ccccccccc000000004005c000000000005c444000000000000cccccc000000000c5099000000000
0000b10d61671dd7667733333bbb37b1000000405000000000005050000000000004050000000000050949000000000000900005000000000450994900000000
000cb1cd6667617dddd1633333bbddb3000000009900000000044099000000000000099000000000099900000000000000990004400000000044444900000000
000cb17c6d676211111267dd133ffdb100cccccc0066660000000000000000000008888888800000000000000000000070000000bbbbbbbbbbbbbbbbbbbbbbbb
00c117766d676222222267ddd111c3b10c6677cd0fc7ccf00000000000000000008827877288000000770000077007000700000700000000000000000000000b
0cb177766dc722211122272dddd1c3b0cccccc7d077ccc700007000000000000008288888828000000777070077700000000000000000000000000000000000b
c7b77775cd76221111122672dd1c1330c6677c6da7cc9c7a0077700000000000000811991188000007777770077000000000000000000000000000000000000b
cb1777776d62221111122267dd1c1360c6777c6d07c98c707a7aa87700000000000827ff2780000007777670000070000000000000000000000000000000000b
5b1ccc77cd6221111111226dddc11d60c7776c6d0fc11cf08a8aa89800000000000827ff2780000007776770000007700000000000000000000000000000000b
bbcccc7cd76221111111226726c11660c7766cd0006dd60089897897000000000008ffffff80000007077700000707700700007000000000000000000000000b
b15ccc7dc76221111111226756d1d600cddddd0000d22d00898977780000000000000cccc000000000000000700000000000000000000000000000000000000b
b00ccc7cd76221111111226756d1d600000000666600000000000000002224000000ccccc0000000b0000000000000000000000000000000000000000000000b
1b0ccc7dc36221111111226756d1d60000000677776000000009990000222400000ccccccc000000b0000000000000000000000000000000000000000000000b
1b0ccc7cd33221111111226752ddd200000067717176000000994440002ff9000001cccccc000000b0000000000000000000000000000000000000000000000b
1b05cdcdc36db33311112d67552dd200000067779999000009444544002224000007cccccc700000b0000000000000000000000000000000000000000000000b
01b055d566633633666666666552000004006777777600004455544500222400000ccc1ccc000000b0000000000000000000000000000000000000000000000b
01b0005066336255555266266050000044000eee88e000000445555100222400000c15191c000000b0000000000000000000000000000000000000000000000b
01b000566db3d6777776dd7d6650000004000de88edee0e800555110001115000000c4c9c0000000b0000000000000000000000000000000000000000000000b
01b00066db31d6766673337d665000000040667777688e8800000000001115000000040000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
01b0066ddb31d27555b2d355d66000000004677777776880000ffffffffffff20aaa99999999999aaa9999999999999999999999999999999a000000113333b7
000066ddb351d6777773d135dd66000000064777777460000004444444444442a9a00000000077777070000000000000000000000000000000a00000011111c7
00066ddbb551d6766673d135d0d660000006777777764440222fffffffff22229a9a0000000777770700000000000000000000000000000000900000022282ef
0066dd01bd5125755575215d000d6600000776777777704420044444444424429a99a0000077777070000000000000000000000000000000009000000133d567
006dd0001bbb36777776d10d0000d6000006777777776040ffffffffffff22229a99a000077777070000000000000000000000000000000000900000001151d6
66dd000001113bb3557221d00000dd660000d677776d000022222222222222229a9a00007777707000000000000000000000000000000000009000000000105d
ddd000000301bb766676d10000000ddd00006d6666d600002000000000002002a9a22227777727222222222222222222222222222222222222a0000000000015
dd0000003bb3b2766672d100000000dd0006777dd777600020000000000020020aaa9999aaa99999999999999999999999999999999999999a00000000000001
0000000000000000000000000000000000000000000000000000ffffffffffff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000ffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ff0000000010000000003040202020202070800000000000000100000000000000000000000000000100000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c1e0f1f0f1f1f1f0b10000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ff0000000000000000000000c0c0c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
202020202020202020202020207080ffff00ffffff30402020202020202020202020202020202020202020202020202000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f1f1f0f1f1f1f1f1f1f1f1f0f1f1b1000000000000c1f1f1f1f1f1f1f0f1f1f1f1f1f1f1f1f1f1f1f1f1f0f1f1f1f1f100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0c0a0a0a0c0c0c1b1a0c0a0a0a00000304020708000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000030402090b0d0f2f270800000000100000000000000000000000000000001000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000502020202020202020202090f2f2f2f2f2f290f2f26000000000000000000030402020207080000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020b09090b0d090b0f2f2d0b1a0c1b1a0c0c0a0c0c1e0f2708000000050202020b0d0f2f2f2b0b0708000003040202000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c1d0b0b1a0a0a0c000000000000000000000c0a0c0c1202020b0b1c0c1f2b0f2d090b0f2b0202020b1a0a0a000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a0a000000000000000000000000000000000000000a0a0a0a0000000a0c1f2f2b0f2b0f2c0a0c00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000c0a0a0a0c0c00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000001000000000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000030407080000000000000000000000000000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
0000ff00000000000000000000ff3040207080000000000000000000000000304020202020b0d020202070800000000000000000000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
0000000000000000000030402020f1b0f1f19020708000000000000000000000a0a0c0a0c0a0a0c0c0a0c0000000000000000000000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
0000000000000000005040f1b0f0c0a0a0d0f1f1d0e0206000000000000000000000000100000000000000000000000000000000000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
708000000000103040b1c1e090a0000000c0c1e0c0c1e0f160000000000000000000000000000000000000000000304000000000000000ff0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
2020202020202020207080c0c0ffff01ffffffb13040202020202020202020202020202020202020202020202020202000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
c0c0c0c0f1f1f1f1f1f1b060000000000000ff50f0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f100000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000c0c0c0c0c0f1f1f170800000003040f1f1f1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
000000000000000000c0c0f1f1f1202020f1f1f1f1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
0000000000000000000000a0a0a0a0a0a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2
__gff__
000081060a122242820404040404c4c4000000000000000000000004000000c4000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000004040404000000000000000000000000040404040000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000000000000000000000000000ff20ff00ff5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f0000000000000000000000000000
00000000000000ff200000000000000000000000000000000029007d0000ffff67000000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200000000000ffff000000000000000000000000002000007d7d000000767767ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ff00000000ff00000000000000030202070800000000ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000ff0000000000ffffff40000000000000ff00000000051f0f0e0b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000003040600000507080000000000ff00000000000000000502021f0b1f0d1bff0000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003041f1f0e07041f0f1f06000000000100000000050207040b0f200b1f2f1fffff00000502070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0c0a0a0c0a1f1f0d0d0a0c0000000003080003041f0f1f1f1f0b0d0d0b0d09ffff03041f1f1f1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff0000000a0c0c0a0000000003040202021f0e0d0a0a0a0c0b0b0b0d0c0cffff0a1f1f1f1fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000ffff00000000ff00000000001f0f0e0b1f090b0a0000050202020202020708ff1c0a0a0a0aff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005060000000000000000000a0a0a0c0a0a0a0000001f1f1f0f1f1f0e0f1bff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050d0d070402020202070800000000000000000000000c0a0a0c0a0c0a0affff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050d090d0d0d0d0b0b0d0d0d020202060003040207080000000000000000ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020d0b0a0a0a0a0a0a0a0a0a0d0b0b090b020d0d0d0d0d020202020202020202020708000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0a0000000000000000000a0a0a0a0a0a0a0a0a0a0a0d0d090d0d0d0d0d0d0a0a09070800050900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0000000000000000000000000000000000000000000a0a0a0a0a0a0a0a0c00000a090902090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
323232323232000000000000000000000000000000000000ffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323f3f0000000000000000000000000000000000000000ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32323200003232000000000000000000000000000000000000000000ffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
323232000032000000002424000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000032320000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000032000000050202070800000000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000100000003041f1f1f1f1f02020206000000000000670000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003040d1f1f0a0a0a0a1f1f1f1f070800000000670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020202021f1f091f0a001000000a0a0a0a0e0f02020206670000000000050202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f0a0a0a0000000000000000000a0a0a0a1c0b0708000000000a1f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0c00100000000000000304020207080000001c0b0b02070800000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ff0000ffff00051f2f0d0e090d060000000c1c1f091b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020708000000000000ff03040d0f020202020f0d07080000000c0a0000030402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0b0202020202020202021f1b0c0a0c0c0a0a1c0b02020202020202020d1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0c0affffffffffffffff0a0c0a0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c0430e60018600376110c0430000000000000000c0430000000000376110c0430000000000000000c0430000000000376110c0430000000000000000c0430000000000376110c043000000000000000
011000200014000030001730000000140000300017300000001400000000173000000014000040051730704002140020000217302000021200200002173020000514005030051730500007130000400514000000
011000200c1500c1500c1500c100131501314013130131100e1500e1100e1000e10013150131000f1500f1000a1500a1400a1400a1400a1400a1400a1400a1400a1400a1400a1400a1400a1400a1101810018100
01100020185241851018510185101851018510185101851018510185101851018510185101851018510185150c5240c5100c5100c5100c5100c5100c5100c5151652416510165101651016510165101651016515
011000200c1730c1000c07330613000000c1730c1000c17300000000000c073306130c1730c100000000c0730c0030c07300000306130c1730c1000c1730c100000000c07300000306100c072000000c07230600
011000201315013110131001315116150161100f1000f1000c1500c1100c1000c15113150131101310013100141501411014100141510c1500c1100c1000c1001814018110181001814116130161301812018110
010c0020070733c6003c2550000307003000033c6153c615070733c6003c255000033c6153c6150707300003070733c6003c25500000000003c6003c6153c615070733c6003c255000003c6153c6150707300000
011000000057330600005030057318645005030057300503005730050300503005731864500503005730050300573005030050300573186450050300573005030050300573005730050318645005730057300503
01100000115671105011032110101c100000002450024000240002400000000000000f5570f0400f0300f0102050020000145501401000000000001655716040160301601000000000001b5571b0401603000010
011000000f1500f14016150161401613016110000000000011150111401113011110000000000000000000000f1500f1400f1300f110000000000000000000001215012140121301211000000000000000000000
010f00001c7551f7522375528752237551f7521c7551f752237551c75228740287302871000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c1550c11518105051001115511115131551311513155131150e1050e1050e1550e1151515515155151551511513105131051315513115131551315513155131150e1050e1050e1550e1150010000100
011000000215002140021500114001130011100000000000021500214002130011100000000000000000000001150051400513005110000000000000000000000515005140051300511000000000000000000000
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
000200001e3501e3501e3502935029350293500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001433014330143301c3301c3301c3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001ee5720e5724e5727e572ae5719e571ee5722e5727e5725e5728e572be5739057390172fe172fe072fe072fe072fe073ae0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e07
000200002755029550305500050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400000fe1714e3717e4714e471be4720e471ae471ee4727e4724e5727e572ce572de572de5733e5733e5736e5736e3736e2730e0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e0700e07
0002000029a1029a1026a202ba302ba3030a4030a5030a6013050150501805030050181001b1001d1001f1001d100221000d1000d1000d1000c1000d1000f100121001410016100181001b1001d100211000d100
00060000180111b011220112805131051360510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000c0541f054000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f044230442d3003440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02 42 43 44
01 02 42 43 44
01 05 02 03 44
01 05 02 06 04
00 05 02 03 04
00 08 09 00 00
00 08 09 0a 02
02 08 04 02 03
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
