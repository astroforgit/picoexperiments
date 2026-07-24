pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- ice-man for pico-8
-- by tamao okamoto(@tama_on)
-- from 2017.8.12 to 2018.4.3
-- http://www.pico2tech.com/

--[[
€€ €€€    €€ €€ €€€€€€€€
€€ €€€€   €€ €€    €€
€€ €€ €€  €€ €€    €€
€€ €€  €€ €€ €€    €€
€€ €€   €€€€ €€    €€
]]

function _init()
	cls ()
	-- all variable reset
	spl_init ()
	opn_init ()
	slt_init ()
	gam_init ()
	to_opn ()
end

--[[
€€€€€€€ €€€€€€  €€ €€€€€€   €€€€€  €€
€€      €€   €€ €€ €€   €€ €€   €€ €€
€€€€€€€ €€€€€€  €€ €€€€€€  €€€€€€€ €€
     €€ €€      €€ €€   €€ €€   €€ €€
€€€€€€€ €€      €€ €€   €€ €€   €€ €€€€€€€
]]

function spl_init()
	spl = {}
	spl.data = {
		{0, 0}, {1, 0}, {2, 0}, {3, 0},		{4, 0}, {5, 0}, {6, 0}, {7, 0},
		{7, 1}, {7, 2}, {7, 3}, {7, 4},		{7, 5}, {7, 6}, {7, 7}, {6, 7},
		{5, 7}, {4, 7}, {3, 7}, {2, 7},		{1, 7}, {0, 7}, {0, 6}, {0, 5},
		{0, 4}, {0, 3}, {0, 2}, {0, 1},		{1, 1}, {2, 1}, {3, 1}, {4, 1},
		{5, 1}, {6, 1}, {6, 2}, {6, 3},		{6, 4}, {6, 5}, {6, 6}, {5, 6},
		{4, 6}, {3, 6}, {2, 6}, {1, 6},		{1, 5}, {1, 4}, {1, 3}, {1, 2},
		{2, 2}, {3, 2}, {4, 2}, {5, 2},		{5, 3}, {5, 4}, {5, 5}, {4, 5},
		{3, 5}, {2, 5}, {2, 4}, {2, 3},		{3, 3}, {4, 3}, {4, 4}, {3, 4},
	}
	spl.transition_scene = nil
	spl.out_counter = 64
	spl.in_counter = 1
	spl.offset_x = 0
	spl.offset_y = 0
	spl.during = false
	spl.counter = 0
end

function spl_counter_reset ()
	spl.out_counter = 64
	spl.in_counter = 1
end

function spl_in_upd ()
end

function spl_in_drw ()
	spr (43, spl.data[spl.in_counter][1]*16 + spl.offset_x, spl.data[spl.in_counter][2]*16 + spl.offset_y, 1, 2)
	spr (42, spl.data[spl.in_counter][1]*16 + 8 + spl.offset_x, spl.data[spl.in_counter][2]*16 + spl.offset_y, 1, 2)

	spl.in_counter = spl.in_counter + 1

	if spl.in_counter > 64
		then
			spl.during = false
			spl.transition_scene ()
		else
			spl.during = true
	end
end

function spl_out_upd ()
end

function spl_out_drw ()
	if spl.out_counter > 0 then
		for i=1,spl.out_counter do
			spr (43, spl.data[i][1]*16 + spl.offset_x, spl.data[i][2]*16 + spl.offset_y, 1, 2)
			spr (42, spl.data[i][1]*16 + 8 + spl.offset_x, spl.data[i][2]*16 + spl.offset_y, 1, 2)
		end
		spl.out_counter = spl.out_counter - 1
	end
	if spl.out_counter < 1
		then spl.during = false
		else spl.during = true
	end
end

--[[
 €€€€€€  €€€€€€  €€€€€€€ €€€    €€ €€ €€€    €€  €€€€€€      €€€€€€€  €€€€€€ €€€€€€€ €€€    €€ €€€€€€€
€€    €€ €€   €€ €€      €€€€   €€ €€ €€€€   €€ €€           €€      €€      €€      €€€€   €€ €€
€€    €€ €€€€€€  €€€€€   €€ €€  €€ €€ €€ €€  €€ €€   €€€     €€€€€€€ €€      €€€€€   €€ €€  €€ €€€€€
€€    €€ €€      €€      €€  €€ €€ €€ €€  €€ €€ €€    €€          €€ €€      €€      €€  €€ €€ €€
 €€€€€€  €€      €€€€€€€ €€   €€€€ €€ €€   €€€€  €€€€€€      €€€€€€€  €€€€€€ €€€€€€€ €€   €€€€ €€€€€€€
]]

function to_opn ()
--	spl_init ()
	opn_init ()
	spl_counter_reset ()
	camera (0, 0)
	spl.offset_x = 0
	spl.offset_y = 0
	_update = opn_upd
	_draw = opn_drw
	part = "opn_logo"
end

function opn_init()
	opn = {}

	logo = {}
	opn.logo = logo
	opn.logo.counter = 0
	opn.logo.line_no = 1
	opn.logo.line_y = -4

	shine = {}
	opn.shine = shine
	opn.shine.tic = -1
	opn.shine.frame = 0
	opn.shine.step = 2

	opn.shine.sp = {80,82,84,86,80,		82,84,86,80,82,
									84,86,80,82,84,		86,80,82,84,86,
									80,82,84,86,80,		82,84,86,80,82,
									84,86,80,82,84,		86,80,82,84,86,
									80,82,84,86,80,		82,84,86,64,64,
									66,66,68,68,70,		70,96,96,100,100,
									128,128,100,100,	96,96,70,70,68,68,
									66,66,64,64,0,		0}

	opn.shine.sp_x = {56,56,56,56,56,		56,56,56,56,56,
										56,56,56,56,56,		56,56,56,56,56,
										56,56,56,56,56,		56,56,56,56,56,
										56,56,56,56,56,		56,56,56,56,56,
										56,56,56,56,56,		56,56,56,56,56,
										56,56,56,56,56,		56,48,48,48,48,
										40,40,48,48,48,		48,56,56,56,56,
										56,56,56,56,56,		56}

	opn.shine.sp_y = {-16,-16,-15,-15,-14,	-14,-13,-13,-11,-11,
										-10,-10,-9,-9,-8,			-8,-7,-7,-6,-6,
										-5,-5,-4,-4,-3,				-3,-2,-2,-1,-1,
										0,0,1,1,2,						2,3,3,4,4,
										5,5,6,6,7,						7,8,8,8,8,
										8,8,8,8,8,						8,0,0,0,0,
										-8,-8,0,0,0,					0,8,8,8,8,
										8,8,8,8,8,						8}

	opn.shine.sp_w = {2,2,2,2,2,	2,2,2,2,2,
										2,2,2,2,2,	2,2,2,2,2,
										2,2,2,2,2,	2,2,2,2,2,
										2,2,2,2,2,	2,2,2,2,2,
										2,2,2,2,2,	2,2,2,2,2,
										2,2,2,2,2,	2,4,4,4,4,
										6,6,4,4,4,	4,2,2,2,2,
										2,2,2,2,1,	1}

	opn.shine.sp_h = {1,1,1,1,1,	1,1,1,1,1,
										1,1,1,1,1,	1,1,1,1,1,
										1,1,1,1,1,	1,1,1,1,1,
										1,1,1,1,1,	1,1,1,1,1,
										1,1,1,1,1,	1,1,1,1,1,
										1,1,1,1,1,	1,2,2,2,2,
										3,3,2,2,2,	2,1,1,1,1,
										1,1,1,1,1,	1}

	opn.shine.sp_flip = {false,false,false,false,false,		false,false,false,false,false,
											 false,false,false,false,false,		false,false,false,false,false,
											 false,false,false,false,false,		false,false,false,false,false,
											 false,false,false,false,false,		false,false,false,false,false,
											 false,false,false,false,false,		false,false,false,false,false,
											 false,false,false,false,false,		false,false,false,false,false,
											 false,false,true,true,true,			true,true,true,true,true,
											 true,true,true,true,true,				true}

	cregit = {}
	opn.cregit = cregit
	opn.cregit.counter = 0
	opn.cregit.color = 7
	opn.cregit.backy_ptn = 34

end

function opn_upd ()
	if ((btn(4)) or (btn(5))) then
		if spl.during == false then
			spl.transition_scene = to_slt
			_update = spl_in_upd
			_draw = spl_in_drw
		end
	end

	if part == "opn_logo"		then opn_logo_upd () end
	if part == "opn_shine"	then opn_shine_upd () end
	if part == "opn_credit"	then opn_credit_upd () end
end

function opn_drw ()
	if part == "opn_logo"		then opn_logo_drw () end
	if part == "opn_shine"	then opn_shine_drw () end
	if part == "opn_credit"	then opn_credit_drw () end
end

function opn_logo_upd ()
	if ((opn.logo.counter >= 0)		and (opn.logo.counter < 15)) then end

	if ((opn.logo.counter >= 15) 	and (opn.logo.counter < 100)) then spl_out_upd () end

	if (opn.logo.counter >= 100) then
		if opn.logo.line_no > 5
			then part = "opn_shine"
			elseif opn.logo.line_y > (48 - opn.logo.line_no * 4)
				then	opn.logo.line_no = opn.logo.line_no + 1
							opn.logo.line_y = -4
							sfx (0)
		end
		opn.logo.line_y = opn.logo.line_y + 4
	end

	opn.logo.counter = opn.logo.counter + 1
end

function opn_logo_drw ()
	cls ()
	if ((opn.logo.counter >= 0)		and (opn.logo.counter < 15)) then
		for i = 1, 64 do
			spr (43, spl.data[i][1]*16, spl.data[i][2]*16, 1, 2)
			spr (42, spl.data[i][1]*16 + 8, spl.data[i][2]*16, 1, 2)
		end
	end
	if ((opn.logo.counter >= 15)	and (opn.logo.counter < 100)) then spl_out_drw () end
	if (opn.logo.counter >= 100)	then
		sspr (8, 5 - opn.logo.line_no, 29, 1, 6, opn.logo.line_y, 116, 4)
		sspr (8, 6 - opn.logo.line_no, 29, opn.logo.line_no, 6, 56 - opn.logo.line_no * 4, 116, opn.logo.line_no * 4)
	end
end

function opn_shine_upd ()
	opn.shine.tic = (opn.shine.tic+1)%opn.shine.step
	if (opn.shine.tic == 0) then opn.shine.frame=opn.shine.frame%#opn.shine.sp+1 end
	if (opn.shine.frame == 76) then part = "opn_credit" end
end

function opn_shine_drw ()
	cls ()
	sspr (8, 0, 29, 5, 6, 32, 116, 20)--logo draw
	if (opn.shine.frame > 60) then sspr(16, 16, 16, 16, 56, 8) end --backy draw
	spr (opn.shine.sp[opn.shine.frame], opn.shine.sp_x[opn.shine.frame], opn.shine.sp_y[opn.shine.frame], opn.shine.sp_w[opn.shine.frame], opn.shine.sp_h[opn.shine.frame], opn.shine.sp_flip[opn.shine.frame])--shine draw upper
	spr (opn.shine.sp[opn.shine.frame], opn.shine.sp_x[opn.shine.frame], opn.shine.sp_y[opn.shine.frame] + opn.shine.sp_h[opn.shine.frame] * 8, opn.shine.sp_w[opn.shine.frame], opn.shine.sp_h[opn.shine.frame], not(opn.shine.sp_flip[opn.shine.frame]),true)--shine draw lower


end

function opn_credit_upd ()
	opn.cregit.counter = opn.cregit.counter + 1
	if opn.cregit.counter >= 1200 then opn.cregit.counter = 200 end
end

function opn_credit_drw ()
	if opn.cregit.counter == 30 then print ("to pico-8 by", 40, 80, 10) end
	if opn.cregit.counter == 60 then print ("tama-on (tamao okamoto)", 18, 88, 10) end
	if opn.cregit.counter == 90 then print ("original by",42 ,100, 9) end
	if opn.cregit.counter == 120 then print ("adress (msx fan)", 32, 108, 9) end
	if opn.cregit.counter == 150 then print ("2018 pico pico technology", 14, 120, 8) end
	if opn.cregit.counter >= 180 then
		if ((opn.cregit.counter % 20) == 0) then
			if opn.cregit.color == 0
				then opn.cregit.color = 7
				else opn.cregit.color = 0
			end
		end
		if ((opn.cregit.counter % 10) == 0) then
			if opn.cregit.backy_ptn == 32
				then opn.cregit.backy_ptn = 34
				else opn.cregit.backy_ptn = 32
			end
		end
		rectfill (56, 8, 72, 24, 0)
		spr (opn.cregit.backy_ptn, 56, 8, 2, 2)
		print ("push button", 42, 64, opn.cregit.color)
	end
end

--[[
€€€€€€€ €€€€€€€ €€      €€€€€€€  €€€€€€ €€€€€€€€     €€€€€€€  €€€€€€ €€€€€€€ €€€    €€ €€€€€€€
€€      €€      €€      €€      €€         €€        €€      €€      €€      €€€€   €€ €€
€€€€€€€ €€€€€   €€      €€€€€   €€         €€        €€€€€€€ €€      €€€€€   €€ €€  €€ €€€€€
     €€ €€      €€      €€      €€         €€             €€ €€      €€      €€  €€ €€ €€
€€€€€€€ €€€€€€€ €€€€€€€ €€€€€€€  €€€€€€    €€        €€€€€€€  €€€€€€ €€€€€€€ €€   €€€€ €€€€€€€
]]

function to_slt ()
	spl_counter_reset ()
	camera (0, 0)
	slt.counter = 0
	spl.offset_x = 0
	spl.offset_y = 0
	slt.hand_pattern = 200
	_update = slt_upd
	_draw = slt_drw
end

function slt_init ()
	slt = {}
	slt.counter = 0
	slt.hand_point_x = 17
	slt.hand_point_y = 14
	slt.hand_pattern = 200
	slt.selected_no = 1
	slt.caution_counter = 0
	slt.clear_table = {false, false, false, false, false, false, false, false, false}

	slt.stage_data = {
		-- stage 1 15*10
		1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,
		3,0,0,0,3,2,0,0,3,2,3,3,0,0,0,
		0,0,2,0,0,0,0,0,0,2,0,0,0,3,1,
		2,0,0,0,0,0,0,0,3,3,3,3,3,3,3,
		3,3,3,3,3,0,0,2,3,0,0,0,0,0,0,
		0,0,0,0,0,3,3,2,3,2,0,0,0,0,1,
		0,0,0,0,2,0,0,2,0,2,0,0,0,0,0,
		1,0,3,3,2,0,0,0,0,2,0,0,0,0,0,
		0,0,0,0,2,3,3,3,3,2,0,0,0,0,0,
		0,3,3,3,2,0,0,0,0,2,0,0,0,0,0,

		-- stage 2 15*10
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		2,0,0,0,0,2,0,0,2,0,0,0,1,0,0,
		2,0,0,0,3,3,0,3,3,1,0,0,0,0,2,
		2,3,0,0,1,0,0,0,3,0,0,2,0,0,0,
		2,0,0,1,3,3,3,0,3,0,3,3,3,0,2,
		2,0,0,3,0,0,3,0,3,1,3,1,0,0,2,
		2,0,0,0,0,1,3,0,3,0,0,3,1,0,2,
		2,3,0,2,3,3,0,0,3,0,0,0,3,0,2,
		2,3,0,2,0,0,0,3,3,0,0,0,0,0,2,
		2,0,0,0,0,0,0,0,0,0,3,0,0,0,2,

		-- stage 3 15*10
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,3,3,3,3,3,2,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,2,0,0,0,0,0,0,1,
		1,0,3,3,3,3,3,2,0,0,0,0,0,0,0,
		3,0,0,0,0,0,0,2,0,0,0,2,3,3,3,
		0,0,0,0,2,3,3,3,0,0,0,0,0,0,0,
		1,0,0,3,2,0,0,0,0,3,3,3,3,1,0,
		0,0,0,0,2,0,0,0,0,0,0,0,0,0,1,
		0,0,0,0,2,0,0,0,3,3,3,3,3,0,0,
		0,0,0,0,2,0,0,0,0,0,0,0,0,3,0,

		-- stage 4 15*10
		0,0,0,0,0,0,0,3,0,0,0,1,0,0,0,
		0,0,0,0,3,3,2,3,2,0,0,0,0,1,0,
		0,0,0,0,0,0,2,3,2,3,3,0,3,3,0,
		1,0,0,0,2,0,0,0,2,0,3,0,0,0,0,
		2,0,0,0,0,3,3,3,2,0,0,0,0,1,0,
		2,0,3,0,0,0,0,0,2,3,3,0,3,3,0,
		2,1,0,3,3,3,3,3,2,0,3,0,0,0,0,
		2,0,0,0,0,0,1,3,2,0,0,0,0,1,0,
		3,0,0,2,0,0,3,3,2,3,3,0,3,3,0,
		1,0,3,0,0,2,0,0,2,0,0,0,0,0,0,

		-- stage 5 15*10
		0,0,0,0,2,0,0,0,0,0,0,0,0,0,1,
		2,3,3,3,0,0,0,0,0,0,0,0,0,0,0,
		2,0,0,0,2,0,0,0,0,0,3,3,3,3,2,
		0,0,2,0,0,0,3,2,0,0,0,0,0,0,2,
		0,0,0,3,3,3,3,2,0,0,0,0,2,0,0,
		0,0,2,0,0,0,0,2,1,1,1,3,2,3,1,
		0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,
		0,0,2,0,0,0,3,3,0,0,2,0,0,0,2,
		2,3,3,0,3,2,0,0,0,0,0,0,2,0,0,
		2,0,0,0,3,2,0,0,0,0,0,0,2,0,0,

		-- stage 6 15*10
		0,0,0,0,0,0,0,3,0,0,0,0,0,1,0,
		2,3,3,0,0,1,0,0,2,0,0,0,3,3,0,
		2,0,0,0,3,3,0,3,2,3,3,0,0,0,0,
		2,3,3,0,0,1,0,0,2,0,0,0,3,3,2,
		2,0,0,0,3,3,0,3,0,3,3,0,0,0,2,
		2,3,3,0,0,1,0,0,0,0,0,0,3,3,2,
		2,0,0,0,3,3,0,3,2,3,3,0,0,0,2,
		2,3,3,0,0,1,0,0,2,0,0,0,3,3,0,
		2,0,2,0,3,3,0,3,2,3,3,0,0,0,0,
		0,0,2,0,0,0,0,0,2,0,0,0,0,0,0,

		-- stage 7 15*10
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
		1,3,2,0,3,3,3,1,0,0,3,2,3,3,3,
		0,0,2,0,3,0,0,0,0,0,3,2,0,0,1,
		2,3,3,0,0,0,0,0,0,0,0,0,2,3,3,
		2,3,0,0,0,0,1,0,0,0,0,3,2,0,1,
		2,0,0,0,2,3,3,0,0,0,0,0,0,2,3,
		2,0,0,0,0,0,0,0,0,0,0,0,3,2,0,
		3,3,3,3,0,2,0,0,3,0,0,0,3,0,2,
		0,0,0,0,0,2,0,0,3,0,0,0,0,0,2,
		0,0,0,2,0,0,0,0,3,0,0,0,0,0,2,

		-- stage 8 15*10
		1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		2,0,0,2,3,0,2,3,0,0,0,0,0,0,0,
		2,0,0,0,3,0,2,3,0,0,0,0,0,0,0,
		3,3,3,3,3,0,2,3,0,0,0,0,0,0,0,
		1,0,0,0,0,0,2,3,2,0,0,0,0,0,0,
		2,0,0,3,3,3,2,3,2,0,0,0,0,0,1,
		0,0,0,0,0,0,2,3,2,0,0,0,0,0,0,
		0,0,2,0,0,0,2,3,2,3,0,0,0,0,0,
		0,0,1,0,0,3,2,3,2,0,0,0,0,0,0,
		0,0,3,3,0,0,2,3,2,0,3,0,0,0,0,

		-- stage 9 15*10
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		1,0,0,0,2,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,2,0,0,0,0,1,0,0,1,2,0,
		2,3,3,3,2,0,0,0,0,3,0,0,3,2,0,
		2,0,0,0,3,0,0,0,0,2,0,0,0,2,0,
		2,0,0,0,0,0,0,0,0,2,0,0,0,2,0,
		2,3,0,0,0,0,0,0,3,2,3,2,3,2,0,
		2,0,0,0,0,0,0,0,0,2,3,1,3,2,0,
		2,0,0,0,0,0,0,0,0,2,3,3,3,2,0,
		2,0,0,0,0,0,0,0,2,2,2,2,2,2,2,

		-- ending stage 15*10
		1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,
		2,1,1,1,1,1,3,2,1,1,1,1,1,1,1,
		2,2,1,1,1,1,1,3,1,2,1,1,1,1,1,
		1,1,3,1,1,1,2,3,2,1,0,3,3,1,1,
		3,1,1,1,2,1,1,3,2,3,1,1,1,1,1,
		1,1,1,1,1,1,2,3,2,3,0,1,2,1,1,
		1,3,3,3,1,1,2,3,2,3,0,3,1,1,2,
		1,1,1,1,2,3,3,3,2,1,3,1,1,1,1,
		1,1,1,2,3,1,1,1,2,1,3,2,1,1,1,
		2,1,1,1,1,1,3,1,1,2,1,1,1,1,1,
	}

end

function slt_upd ()
	if ((slt.counter >= 0) and (slt.counter < 15)) then end

	if ((slt.counter >= 15) and (slt.counter < 100)) then spl_out_upd () end

	if (slt.counter >= 160) then end
	slt.counter = slt.counter + 1
	if slt.counter > 1000 then slt.counter = 1000 end
end

function slt_drw ()
	cls ()
	stage_data_index = 1
	for sy = 8, 72, 32 do
		for sx = 8, 88, 40 do
			sspr (48, 64, 32, 24, sx, sy)
			stage_no = (sx - 8) / 40 + 1 + (sy - 8) / 32 * 3
			for cy = 1, 10, 1 do
				for cx = 1, 15, 1 do
					if slt.stage_data[stage_data_index] == 0 then
						if slt.clear_table[stage_no] == true
							then col = 0
							else col = 1
						end
					end
					if slt.stage_data[stage_data_index] == 1 then
						if slt.clear_table[stage_no] == true
						 	then col = 0
							else col = 10
						end
					end
					if slt.stage_data[stage_data_index] == 2 then
						if slt.clear_table[stage_no] == true
							then col = 1
							else col = 12
						end
	 				end
					if slt.stage_data[stage_data_index] == 3 then
						if slt.clear_table[stage_no] == true
							then col = 5
							else col = 13
						end
					end
					if slt.stage_data[stage_data_index] == 4 then col = 1 end
					px1 = sx + 1 + (cx - 1) * 2
					py1 = sy + 2 + (cy - 1) * 2
					rectfill (px1, py1, px1 + 1, py1 + 1, col)
					stage_data_index = stage_data_index + 1
				end
			end
		end
	end

	if ((slt.counter >= 0) and (slt.counter < 15)) then
		for i = 1, 64 do
			spr (43, spl.data[i][1]*16, spl.data[i][2]*16, 1, 2)
			spr (42, spl.data[i][1]*16 + 8, spl.data[i][2]*16, 1, 2)
		end
	end
	if ((slt.counter >= 15)	and (slt.counter < 100)) then spl_out_drw () end
	if (slt.counter >= 100)	then print ("stage selection", 34, 1, 7) end
	if (slt.counter >= 130)	then print ("select and press the button", 10, 104, 7) end
	if (slt.counter >= 160) then
		slt.selected_no = (slt.hand_point_x - 17) / 40 + 1 + (slt.hand_point_y - 14) / 32 * 3
		if (btnp(4) or btnp(5)) --selected stage
			then slt.hand_pattern = 204
				if (slt.clear_table[slt.selected_no]) == false
					then -- not stage clear
						if spl.during == false then
							spl.transition_scene = to_gam
							_update = spl_in_upd
							_draw = spl_in_drw
						end
					else -- yet stage clear
						sfx (0)
						print("already cleared", 32, 117, 8)
						slt.caution_counter = 0
						_update = slt_caution_upd
						_draw = slt_caution_drw
				end
			else --change stage
				if (btnp(0)) then
					if slt.hand_point_x >= 57 then slt.hand_point_x = slt.hand_point_x - 40 end
				end
				if (btnp(1)) then
					if slt.hand_point_x <= 57 then slt.hand_point_x = slt.hand_point_x + 40 end
				end
				if (btnp(2)) then
					if slt.hand_point_y >= 46 then slt.hand_point_y = slt.hand_point_y - 32 end
				end
				if (btnp(3)) then
					if slt.hand_point_y <= 46 then slt.hand_point_y = slt.hand_point_y + 32 end
				end
		end
		spr (slt.hand_pattern, slt.hand_point_x, slt.hand_point_y, 4, 4)
	end
end

function slt_caution_upd ()
	slt.caution_counter = slt.caution_counter + 1
	if slt.caution_counter == 30 then
		slt.hand_pattern = 200
		_update = slt_upd
		_draw = slt_drw
	end
end

function slt_caution_drw ()
end

--[[
 €€€€€€   €€€€€  €€€    €€€ €€€€€€€     €€€€€€€  €€€€€€ €€€€€€€ €€€    €€ €€€€€€€
€€       €€   €€ €€€€  €€€€ €€          €€      €€      €€      €€€€   €€ €€
€€   €€€ €€€€€€€ €€ €€€€ €€ €€€€€       €€€€€€€ €€      €€€€€   €€ €€  €€ €€€€€
€€    €€ €€   €€ €€  €€  €€ €€               €€ €€      €€      €€  €€ €€ €€
 €€€€€€  €€   €€ €€      €€ €€€€€€€     €€€€€€€  €€€€€€ €€€€€€€ €€   €€€€ €€€€€€€
]]

function to_gam ()
	spl_counter_reset ()
	camera (gam.backy_point.x - 56, gam.backy_point.y - 56)
	gam.counter = 0
	gam.shine_frame = 0
	gam.shine_tic = -1
	gam.shine_step = 2
	gam.backy_show = false
	spl.offset_x = gam.backy_point.x - 56
	spl.offset_y = gam.backy_point.y - 56
	gam.stage_clear_flag = false
	gam.backy_state = "s"
  gam.backy_pattern = 34
  gam.backy_flip_x = false
	_update = gam_upd
	_draw = gam_drw

	music (0)
end

function gam_init ()
	gam = {}


	gam.stage_data = {}
	gam.counter = 0
	gam.start_point = {{14, 7}, {2, 0}, {13, 0}, {9, 1}, {10, 9}, {14, 9}, {9, 9}, {7, 0}, {14, 0}, {13, 1}}
	gam.backy_point = {}
	gam.backy_point.x = 0
	gam.backy_point.y = 0
	gam.backy_old_point_x = 0
	gam.backy_old_point_y = 0
	gam.backy_state = "s"
	gam.backy_pattern = 34
	gam.backy_flip_x = false
	gam.backy_show = false
	gam.backy_stay_count = 0
	gam.shine_frame = 0
	gam.shine_tic = -1
	gam.shine_step = 2
	gam.shine_sp = {64,64,66,66,68,		68,70,70,96,96,
									100,100,128,128,100,	100,96,96,70,70,
									68,68,66,66,64,		64,0,0}

	gam.shine_x = {	0,0,0,0,0,				0,0,0,-8,-8,
									-8,-8,-16,-16,-8,	-8,-8,-8,0,0,
									0,0,0,0,0,				0,0,0}

 	gam.shine_y = {	0,0,0,0,0,				0,0,0,-8,-8,
									-8,-8,-16,-16,-8,	-8,-8,-8,0,0,
									0,0,0,0,0,				0,0,0}

	gam.shine_w = {	2,2,2,2,2,		2,2,2,4,4,
									4,4,6,6,4,		4,4,4,2,2,
									2,2,2,2,2,		2,1,1}

	gam.shine_h	= {	1,1,1,1,1,		1,1,1,2,2,
									2,2,3,3,2,		2,2,2,1,1,
									1,1,1,1,1,		1,1,1}

	gam.shine_flip = {false,false,false,false,false,		false,false,false,false,false,
										false,false,false,false,true,			true,true,true,true,true,
										true,true,true,true,true,					true,true,true}

	gam.point_char = 0
	gam.up_char = 0
	gam.down_char = 0
	gam.left_char = 0
	gam.right_char = 0

	gam.gold_count = 0

	gam.stage_clear_flag = false
	gam.stage_allclear_flag = false
	gam.ending_stage_clear_flag = false

	gam.stage_clear_count = 0

	gam.menu_backy_point_x = 0
	gam.menu_backy_point_y = 0
	gam.menu_backy_pattern = nil
	gam.menu_backy_flip_x = false
	gam.menu_backy_pattern_tic = -1
	gam.menu_select = 1 -- 1:return 2:retry 3:select stage

	gam.last_message_counter = 0
	gam.last_message_decision = 0 -- 1:excellent 2:nice 3:thank you
end

function gam_upd ()
	if gam.counter == 0 then -----
	 gam.backy_point.x = gam.start_point[slt.selected_no][1] * 16 + 56
	 gam.backy_point.y = gam.start_point[slt.selected_no][2] * 16 + 56

	stage_data_index = (slt.selected_no - 1) * 150
	gam.gold_count = 0
	for i=1,150 do
		gam.stage_data[i] = slt.stage_data[stage_data_index + i] -- stage data copy
	 	if gam.stage_data[i] == 1 then -- gold count
	 		gam.gold_count = gam.gold_count + 1
	 		end
		end

	end
	if (gam.counter >= 156) then gam_play_upd () end
	if (gam.counter == 160) then music (-1) end
	if (gam.counter == 190) then if gam.stage_allclear_flag then music (8) else music (4) end end
end

function gam_drw ()
	cls ()
	camera (gam.backy_point.x - 56, gam.backy_point.y - 56)
	spl.offset_x = gam.backy_point.x - 56
	spl.offset_y = gam.backy_point.y - 56
	gam_stage_drw ()

	--print ("counter =  "..gam.counter, gam.backy_point.x, gam.backy_point.y, 7)

	-- block fullscreen
	if ((gam.counter >= 0) and (gam.counter < 15)) then
		for i = 1, 64 do
			spr (43, spl.data[i][1]*16 + spl.offset_x, spl.data[i][2]*16 + spl.offset_y, 1, 2)
			spr (42, spl.data[i][1]*16 + 8 + spl.offset_x, spl.data[i][2]*16 + spl.offset_y, 1, 2)
		end
	end

	-- spiral out animation
	if ((gam.counter >= 15)	and (gam.counter < 100)) then spl_out_drw () end

	if ((gam.counter >= 100)	and (gam.counter < 156)) then
		gam.shine_tic = (gam.shine_tic + 1) % gam.shine_step
		if (gam.shine_tic == 0) then gam.shine_frame = gam.shine_frame + 1 end
		if gam.shine_frame >= 29 then gam.shine_frame = 28 end -- gam.shine_frame stop
		if gam.shine_frame >= 13 then gam.backy_show = true end --backy draw
		spr (gam.shine_sp[gam.shine_frame], gam.shine_x[gam.shine_frame] + gam.backy_point.x, gam.shine_y[gam.shine_frame] + gam.backy_point.y, gam.shine_w[gam.shine_frame], gam.shine_h[gam.shine_frame], gam.shine_flip[gam.shine_frame])--shine draw upper
		spr (gam.shine_sp[gam.shine_frame], gam.shine_x[gam.shine_frame] + gam.backy_point.x, gam.shine_y[gam.shine_frame] + gam.backy_point.y + gam.shine_h[gam.shine_frame] * 8, gam.shine_w[gam.shine_frame], gam.shine_h[gam.shine_frame], not(gam.shine_flip[gam.shine_frame]), true)--shine draw lower
	end

	if (gam.counter >= 156) then gam_play_drw () end
	point_x = spl.offset_x
	point_y = spl.offset_y
	spr (128, point_x + 0, point_y + 0, 2, 2)
	gam.counter = gam.counter + 1
	if gam.counter > 32000 then gam.counter = 32000 end

end

function gam_stage_drw ()
	for y = 1, 10 do -- backglound draw net pattern
		for x = 1, 15 do
			spr (40, (x - 1) * 16 + 56, (y - 1) * 16 + 56, 2, 2)
		end
	end

	game_stage_data_index = 1
	for cy = 1, 10 do
		for cx = 1, 15 do
			if gam.stage_data[game_stage_data_index] == 0 then spr (40, (cx - 1) * 16 + 56, (cy - 1) * 16 + 56, 2, 2) end	-- mesh pattern draw
			if gam.stage_data[game_stage_data_index] == 2 then spr (44, (cx - 1) * 16 + 56, (cy - 1) * 16 + 56, 2, 2) end -- ladder pattern draw
			game_stage_data_index = game_stage_data_index + 1
		end
	end
	game_stage_data_index = 1
	for cy = 1, 10 do
		for cx = 1, 15 do
			if gam.stage_data[game_stage_data_index] == 1 then spr (230, (cx - 1) * 16 + 56 + 2, (cy - 1) * 16 + 56 + 2, 2, 2) end -- gold shadow pattern draw
			game_stage_data_index = game_stage_data_index + 1
		end
	end

	-- backy shadow pattern draw
	if gam.backy_show == true then
		spr(gam.backy_pattern + 192, gam.backy_point.x + 2, gam.backy_point.y + 2, 2, 2, gam.backy_flip_x) -- backy draw
	end

	game_stage_data_index = 1
	for cy = 1, 10 do
		for cx = 1, 15 do
			if gam.stage_data[game_stage_data_index] == 1 then spr (46, (cx - 1) * 16 + 56, (cy - 1) * 16 + 56, 2, 2) end
			if gam.stage_data[game_stage_data_index] == 3 then spr (42, (cx - 1) * 16 + 56, (cy - 1) * 16 + 56, 2, 2) end
			if gam.stage_data[game_stage_data_index] == 4 then spr (38, (cx - 1) * 16 + 56, (cy - 1) * 16 + 56, 2, 2) end
			game_stage_data_index = game_stage_data_index + 1
		end
	end

	if gam.backy_show == true then
		spr(gam.backy_pattern, gam.backy_point.x, gam.backy_point.y, 2, 2, gam.backy_flip_x) -- backy draw
	end

	tic = 0
	for y = 0, 48, 8 do
		for x = 0, 336, 16 do
			spr (42 + tic * 16, x, y, 2, 1)
		end
		tic = 1 % tic
	end

	for y = 216, 264, 8 do
		for x = 0, 336, 16 do
			spr (42 + tic * 16, x, y, 2, 1)
		end
		tic = 1 % tic
	end

	for y = 56, 256, 16 do
		for x = 0, 48, 8 do
			spr (43 - tic, x, y, 1, 2)
			tic = 1 % tic
		end

		for x = 296, 344, 8 do
			spr (43 - tic, x, y, 1, 2)
			tic = 1 % tic
		end
	end


end

function gam_play_upd ()
	-- stage cleared check
	if gam.stage_clear_flag == false then
		-- backy stay time check
		if gam.backy_stay_count >= 90 then -- game menu mode
			gam.menu_select = 1 -- default return set
			-- backy direction check
			if ((gam.backy_pattern == 34) and (gam.backy_flip_x == false)) then gam.menu_backy_pattern = 11 end
			if ((gam.backy_pattern == 34) and (gam.backy_flip_x == true)) then gam.menu_backy_pattern = 11 end
			if (gam.backy_pattern == 36) then gam.menu_backy_pattern = 12 end
			gam.menu_backy_flip_x = gam.backy_flip_x
			-- backy point processing
			gam.menu_backy_point_x = ((gam.backy_point.x - 56) / 16) * 8 + 4 + (gam.backy_point.x - 56)
			gam.menu_backy_point_y = ((gam.backy_point.y - 56) / 16) * 8 + 8 + (gam.backy_point.y - 56)

			gam.backy_stay_count = 0
			_update = gam_menu_upd
			_draw = gam_menu_drw
		end
		-- backy old point save
		gam.backy_old_point_x = gam.backy_point.x
		gam.backy_old_point_y = gam.backy_point.y
		-- backy grid point check
		if ((gam.backy_point.x - 56) % 16 == 0) and ((gam.backy_point.y - 56) % 16 ==0)
		  	then gam_on_grid ()
				else gam_moving ()
		end
	end
end

function gam_on_grid ()
	-- point character data get
	gam.point_char = gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15]

	if (gam.backy_point.x - 56) <= 0
	 	then gam.left_char = 5
		else gam.left_char = gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 - 1]
	end

	if (gam.backy_point.x - 56) >= 224
		then gam.right_char = 5
		else gam.right_char = gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 + 1]
	end

	if (gam.backy_point.y - 56) <= 0
		then gam.up_char = 5
		else gam.up_char = gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 - 15]
	end

	if (gam.backy_point.y - 56) >= 144
		then gam.down_char = 5
		else gam.down_char = gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 + 15]
	end

	-- fall se stop check
	if gam.down_char >= 2 then sfx (-1,3) end

	-- gold get check
	if gam.point_char == 1 then
		gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15] = 0

		gam.gold_count = gam.gold_count - 1

		sfx (1, 2) -- gold get se

		-- stage clear and stage all clear check
		if gam.gold_count == 0 then
			music (-1) -- bgm stop
			sfx (63, 3) -- fall se stop
			gam.stage_clear_flag = true

			gam.shine_frame = 0
			gam.shine_tic = -1

			if gam.stage_allclear_flag == false
			 then
				 slt.clear_table[slt.selected_no] = true -- stage clear table update

	 				gam.stage_allclear_flag = true -- satge all clear check
	 				for i=1, #slt.clear_table do
	 					if slt.clear_table[i] == false then gam.stage_allclear_flag = false end
	 				end
			 else
				gam.ending_stage_clear_flag = true
			end
		end
		return -- don't move
	end
	-- fall check
	if ((gam.point_char != 2) and (gam.down_char <= 1))
		then 	if gam.backy_state != "f" then sfx (5,3) end
					gam_backy_move_fall ()
					gam.backy_state = "f" return
	end
	-- key sign check
	-- iceblock left put (sign = 4)
	if (btnp(4) and (gam.left_char == 0))
		then	gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 - 1] = 4 -- map char change
					gam.left_char = 4
					sfx (2, 1) -- iceblock put se
	end
	-- iceblock right put (sign = 5)
	if (btnp(5) and (gam.right_char == 0))
		then	gam.stage_data[(gam.backy_point.x - 56) / 16 + 1 + (gam.backy_point.y - 56) / 16 * 15 + 1] = 4 -- map char change
					gam.right_char = 4
					sfx (2, 1) -- iceblock put se
	end
	-- up check (sign = 2)
	if (btn(2) and (gam.point_char == 2) and (gam.up_char <= 2))
		then 	gam_backy_move_up ()

			 		gam.backy_state = "u" return
	end
	-- down check (sign = 3)
	if (btn(3) and (gam.down_char <= 2))
		then 	gam_backy_move_down ()
			 		gam.backy_state = "d" return
	end
	-- left check (sign = 0)
	if (btn(0) and (gam.left_char <= 2))
		then 	gam_backy_move_left ()
					gam.backy_state = "l" return
	end
	-- right  check (sign = 1)
	if (btn(1) and (gam.right_char <= 2))
		then 	gam_backy_move_right ()
			 		gam.backy_state = "r" return
	end
	-- don't move
	gam.backy_state = "s" -- stop
end

function gam_moving ()

	-- moving fall
	if gam.backy_state == "f" then
		gam_backy_move_fall ()
		return
	end

	-- moving up
	if gam.backy_state == "u" then
		if btn (3) -- press key is down
			then gam_backy_move_down () gam.backy_state = "d"
			else gam_backy_move_up () gam.backy_state = "u"
		end
		return
	end

	-- moving down
	if gam.backy_state == "d" then
		if btn (2)
			then gam_backy_move_up () gam.backy_state = "u"
			else gam_backy_move_down () gam.backy_state = "d"
		end
		return
	end

	-- moving left
	if gam.backy_state == "l" then
		if btn (1)
			then gam_backy_move_right () gam.backy_state = "r"
			else gam_backy_move_left () gam.backy_state = "l"
		end
		return
	end

	--moving right
	if gam.backy_state == "r" then
		if btn (0)
			then gam_backy_move_left () gam.backy_state = "l"
			else gam_backy_move_right () gam.backy_state = "r"
		end
		return
	end

end
function gam_backy_move_fall ()
	gam.backy_point.y = gam.backy_point.y + 4
	gam.backy_stay_count = 0 -- stay counter reset
end
function gam_backy_move_up ()
	gam.backy_point.y = gam.backy_point.y - 2
	gam.backy_stay_count = 0 -- stay counter reset
	if ((gam.backy_point.y - 56) % 16) <= 7
		then gam.backy_pattern = 36 gam.backy_flip_x = false sfx(3,1) -- move se
		else gam.backy_pattern = 36 gam.backy_flip_x = true sfx(4,1) -- move se
	end
end
function gam_backy_move_down ()
	gam.backy_point.y = gam.backy_point.y + 2
	gam.backy_stay_count = 0 -- stay counter reset
	if ((gam.backy_point.y - 56) % 16) <= 7
		then gam.backy_pattern = 36 gam.backy_flip_x = false sfx(3,1) -- move se
		else gam.backy_pattern = 36 gam.backy_flip_x = true sfx(4,1) -- move se
end
end
function gam_backy_move_left ()
	gam.backy_point.x = gam.backy_point.x - 2
	gam.backy_stay_count = 0 -- stay counter reset
	if ((gam.backy_point.x - 56) % 16) <= 7
		then gam.backy_pattern = 34 gam.backy_flip_x = false sfx(3,1) -- move se
		else gam.backy_pattern = 32 gam.backy_flip_x = false sfx(4,1) -- move se
	end
end
function gam_backy_move_right ()
	gam.backy_point.x = gam.backy_point.x + 2
	gam.backy_stay_count = 0 -- stay counter reset
	if ((gam.backy_point.x - 56) % 16) <= 7
		then gam.backy_pattern = 34 gam.backy_flip_x = true	sfx(3,1) -- move se
		else gam.backy_pattern = 32 gam.backy_flip_x = true sfx(4,1) -- move se
	end
end

function gam_play_drw ()

	if gam.stage_clear_flag
		then
			-- shine animation counter update
			if ((gam.stage_clear_count >= 45) and (gam.stage_clear_count < 101)) then
				gam.shine_tic = (gam.shine_tic + 1) % gam.shine_step
				if (gam.shine_tic == 0) then gam.shine_frame = gam.shine_frame + 1 end

				if gam.shine_frame >= 29 then gam.shine_frame = 28 end -- gam.shine_frame stop

				if gam.shine_frame >= 13 then gam.backy_show = false end --backy clear

				--shine draw
				spr (gam.shine_sp[gam.shine_frame], gam.shine_x[gam.shine_frame] + gam.backy_point.x, gam.shine_y[gam.shine_frame] + gam.backy_point.y, gam.shine_w[gam.shine_frame], gam.shine_h[gam.shine_frame], gam.shine_flip[gam.shine_frame])--shine draw upper
				spr (gam.shine_sp[gam.shine_frame], gam.shine_x[gam.shine_frame] + gam.backy_point.x, gam.shine_y[gam.shine_frame] + gam.backy_point.y + gam.shine_h[gam.shine_frame] * 8, gam.shine_w[gam.shine_frame], gam.shine_h[gam.shine_frame], not(gam.shine_flip[gam.shine_frame]), true)--shine draw lower
			end

			if ((gam.stage_clear_count >= 131) and (gam.stage_clear_count < 431)) then

				if gam.ending_stage_clear_flag
					then
						if gam.counter <= 4700 -- counter check to message
							then gam.last_message_decision = 1
							else gam.last_message_decision = 2
						end

            gam.backy_pattern = 34
            gam.backy_flip_x = false

            gam.stage_clear_count = 0

						_update = gam_last_message_upd
						_draw = gam_last_message_drw

					else
						if gam.stage_allclear_flag
							then -- stage all
								rectfill(gam.backy_point.x - 28, gam.backy_point.y - 16, gam.backy_point.x + 43, gam.backy_point.y - 8, 0)
								sspr(40,0,40,8,gam.backy_point.x - 28,gam.backy_point.y - 16) -- "stage"
								sspr(0, 104, 24, 8, gam.backy_point.x + 20,gam.backy_point.y - 16) -- "all"
							else -- stage no
								rectfill(gam.backy_point.x - 20, gam.backy_point.y - 8, gam.backy_point.x + 35, gam.backy_point.y, 0)
								sspr(40,0,40,8,gam.backy_point.x - 20,gam.backy_point.y - 8) -- "stage"
								spr(15 + slt.selected_no, gam.backy_point.x + 28, gam.backy_point.y - 8) -- "no"
						end
						rectfill(gam.backy_point.x - 16, gam.backy_point.y + 16, gam.backy_point.x + 31, gam.backy_point.y + 24, 0)
						sspr(0,96,48,8,gam.backy_point.x - 16, gam.backy_point.y + 16) -- "clear!"
				end
			end

			if gam.stage_clear_count == 140 then music(6) end

			if (gam.stage_clear_count >= 380) then
				music(-1)
				gam.stage_clear_count = 0
				-- gam.stage_allclear_flag check
				if gam.stage_allclear_flag
					then
						slt.selected_no = 10
						spl.transition_scene = to_gam
					else
						spl.transition_scene = to_slt
				end

        gam.backy_pattern = 34
      	gam.backy_flip_x = false

				_update = spl_in_upd
				_draw = spl_in_drw
			end
			gam.stage_clear_count = gam.stage_clear_count + 1
		else

			if ((gam.backy_point.x == gam.backy_old_point_x) and (gam.backy_point.y == gam.backy_old_point_y))
				then gam.backy_stay_count = gam.backy_stay_count + 1
			end
	end
end

function gam_menu_upd ()
end

function gam_menu_drw ()
	cls()
	-- button push check
	if btnp(4) or btnp(5) then
		if gam.menu_select == 1 then
			gam.menu_backy_pattern_tic = -1
			_update = gam_upd
			_draw = gam_drw
		end
		if gam.menu_select == 2 then
			music (-1)
			gam.menu_backy_pattern_tic = -1
			spl.transition_scene = to_gam
			_update = spl_in_upd
			_draw = spl_in_drw
		end
		if gam.menu_select == 3 then
			music (-1)
			if gam.stage_allclear_flag
			then
				gam.last_message_decision = 3
				_update = gam_last_message_upd
				_draw = gam_last_message_drw
			else
				gam.menu_backy_pattern_tic = -1
				spl.transition_scene = to_slt
				_update = spl_in_upd
				_draw = spl_in_drw
			end
		end
	end

	-- around view left side block
	for i=1,12 do
		sspr(108,8,4,8,gam.backy_point.x - 56,gam.backy_point.y - 56 + (i - 1) * 8)
	end
	-- around view right side block
	for i=1,12 do
		sspr(104,8,4,8,gam.backy_point.x - 56 + 124,gam.backy_point.y - 56 + (i - 1) * 8)
	end
	-- around view top block
	for i=1,15 do
		spr(29,gam.backy_point.x - 56 + 4 + (i - 1) * 8,gam.backy_point.y - 56)
	end
	-- around view bottom block
	for i=1,15 do
		spr(29,gam.backy_point.x - 56 + 4 + (i - 1) * 8,gam.backy_point.y - 56 + 88)
	end
	-- around view back ground mesh
	for y=1,10 do
		for x=1,15 do
			spr(28,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8)
		end
	end

  -- top frame show "stage *" or "congraturation"
  if gam.stage_allclear_flag
    then -- congraturation
      rectfill(gam.backy_point.x - 48, gam.backy_point.y - 56, gam.backy_point.x + 63, gam.backy_point.y - 49, 0)
      spr(176, gam.backy_point.x - 56 + 8, gam.backy_point.y - 57, 14, 1)
    else -- stage *
      rectfill(gam.backy_point.x - 20, gam.backy_point.y - 56, gam.backy_point.x + 35, gam.backy_point.y - 49, 0)
      spr(5, gam.backy_point.x - 56 + 36, gam.backy_point.y - 57, 5, 1)
      spr(15 + slt.selected_no,  gam.backy_point.x + 28, gam.backy_point.y - 57)
  end
	-- around view stage draw
	for y=1,10 do
		for x=1,15 do
			if gam.stage_data[x + (y - 1) * 15] == 0 then
				spr(28,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8) end
			if gam.stage_data[x + (y - 1) * 15] == 1 then
				spr(31,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8) end
			if gam.stage_data[x + (y - 1) * 15] == 2 then
				spr(30,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8) end
			if gam.stage_data[x + (y - 1) * 15] == 3 then
				spr(29,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8) end
			if gam.stage_data[x + (y - 1) * 15] == 4 then
				spr(27,gam.backy_point.x - 56 + 4 + (x - 1) * 8,gam.backy_point.y - 56 + y * 8) end
		end
	end
	-- around view backy draw
	gam.menu_backy_pattern_tic = (gam.menu_backy_pattern_tic+1)%9 -- tic processing
	if (gam.menu_backy_pattern_tic == 0) then
		-- left and right processing
		if gam.menu_backy_pattern == 11 then gam.menu_backy_pattern = 10
    elseif gam.menu_backy_pattern == 10 then gam.menu_backy_pattern = 11
    elseif ((gam.menu_backy_pattern == 12) and (gam.menu_backy_flip_x == false)) then gam.menu_backy_flip_x = true
    elseif ((gam.menu_backy_pattern == 12) and (gam.menu_backy_flip_x == true)) then gam.menu_backy_flip_x = false
		end
	end
	--
	spr(gam.menu_backy_pattern,gam.menu_backy_point_x,gam.menu_backy_point_y,1,1,gam.menu_backy_flip_x,false)

	-- select menu draw
	if btnp(2) and (gam.menu_select > 1) then gam.menu_select = gam.menu_select - 1 end
	if btnp(3) and (gam.menu_select < 3) then gam.menu_select = gam.menu_select + 1 end
	color = {5,5,5} -- all gray
	color[gam.menu_select] = 7 -- selected white
	-- menu draw
	print("return ",gam.backy_point.x - 56 + 52,gam.backy_point.y - 56 + 102,color[1])
	print("retry",gam.backy_point.x - 56 + 54,gam.backy_point.y - 56 + 112,color[2])
	if gam.stage_allclear_flag
		then print("retire",gam.backy_point.x - 56 + 52,gam.backy_point.y - 56 + 122,color[3])
		else print("select stage",gam.backy_point.x - 56 + 40,gam.backy_point.y - 56 + 122,color[3])
	end
end

function gam_last_message_upd ()
	if gam.last_message_counter == 260 then

    -- stage clear table reset
    for i = 1, #slt.clear_table do
      slt.clear_table[i] = false
    end

    gam.stage_clear_flag = false
    gam.stage_allclear_flag = false
    gam.ending_stage_clear_flag = false


		spl.transition_scene = to_opn

    gam.last_message_counter = 0

		_update = spl_in_upd
		_draw = spl_in_drw

	end

end

function gam_last_message_drw ()
	local x = gam.backy_point.x - 56
	local y = gam.backy_point.y - 56

	-- music play
	if gam.last_message_counter == 10 then music(6) end
	if gam.last_message_counter == 250 then music(-1) end

	if gam.last_message_decision == 1 then -- excellent
		rectfill(x + 0, y + 96, x + 127, y + 127, 0)
		spr(75, 0 + x, 96 + y, 5, 4)
		print("excellent!!", x + 62, y + 104, 10)
		print("see you next game", x + 50, y + 117, 7)
	end

	if gam.last_message_decision == 2 then -- nice
		rectfill(x + 0, y + 96, x + 127, y + 127, 0)
		spr(75, 0 + x, 96 + y, 5, 4)
		print("nice!", x + 74, y + 104, 9)
		print("see you next game", x + 50, y + 117, 7)
	end

	if gam.last_message_decision == 3 then -- thank you
		rectfill(x + 0, y + 96, x + 127, y + 127, 0)
		spr(75, 0 + x, 96 + y, 5, 4)
		print("thank you !", x + 62, y + 104, 7)
		print("see you next game", x + 50, y + 117, 7)

	end


	gam.last_message_counter += 1
end
__gfx__
00000000ccc0ccc0ccc000c000c00c00c000c0000000000000000000000000000000000000000000007777700077777000777700077777700777777007777770
000000000c00c000c00000cc0cc0c0c0cc00c0000077770007777770007777000077770007777770077777070777770707177177777777777000000770000007
000000000c00c000cc0cc0c0c0c0ccc0c0c0c0000770077000077000077007700770077007700000771777707717777007777777770770777070070770700707
000000000c00c000c00000c000c0c0c0c00cc0000770000000077000077007700770000007700000777777777777777777777770777777777000000770000007
00000000ccc0ccc0ccc000c000c0c0c0c000c0000077770000077000077007700770000007777770077717700777177077177177777777777070070770000007
00000000000000000000000000000000000000000000077000077000077777700770777007700000071177070777170707177177707777077007700770777707
00000000000000000000000000000000000000000770077000077000077007700770077007700000007777700071777007717770770000777000000770077007
00000000000000000000000000000000000000000077770000077000077007700077777007777770077707700077770077007077077777700777777007777770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc010010000d666111d0c0000c000aaaa00
0008800000888800008888000000880008888880000888000888888000888800008888000088880000000000cc7717cc011000006dddddd10c0000c00aa1aa00
0088800008800880088008800008880008800000008800000000088008800880080008800800088000000000c711111c011000006dddddd10cccccc00a0aa0a0
0008800008800880000008800080880008800000088000000000888008800880080008800800808000000000c711111c10010000d666111d0c0000c0aaaaaaaa
0008800000008800000888000800880008888800088888000000880000888800008888800808808000000000c111116c00001001111dd6660c0000c0aaaaaaaa
0008800000088000000008800800880000000880088008800008800008800880000008800808008000000000c111116c00000110ddd16ddd0c0000c0aa0aa0aa
0008800000880000088008800888888000000880088008800008800008800880080008800880008000000000cc6166cc00000110ddd16ddd0cccccc0a0aaaa0a
08888880088888800088880000008800088888000088880000088000008888000088880000888800000000000cccccc000001001111dd6660c0000c00aa00aa0
00000007770000000000000777000000000007777770000000cccccccccccc001000000100000000dd666666111111dd0cc1000000000cc1000000000aaa0000
0000007770007000000000777000700000007717717700000cc1111111111cc00111111000000000d66dddddddddd11d0cc1000000000cc1000000aaaaa00000
000777770077700000077777007770000000777777770000cc117771771111cc010000100000000066d66ddddddddd110cc1000000000cc100a0aaa11a000a00
007777777777000000777777777700007707777777777000c11771111111111c01000010000000006d6dddddddddd1d10cccccccccccccc100a0a0aaaa000a00
077777777770077007777777777007707777777777777700c17711111111111c01000010000000006d6dddddddddd1d10cc1c1c1c1c1c1c10aaa000aa000aaa0
071777777777770007177777777777000777717777177777c17111111111111c010000100000000066ddddddddd11d110cc1000000000cc10a4aa0aaaa0aa4a0
771777777777700077177777777770000007717771777777c17111111111111c0111111000000000d66dddddddddd11d0cc1000000000cc1aaa4aaaaaaaa4aaa
777777777777000077777777777700000007711771177077c17111111111161c1000000100000000dd666666111111dd0cc1000000000cc1aa4a4aaaaaa4a4aa
077771777777777707777777177777770007171717717000c17111111111161c0000000010000001111111dddd6666660cc1000000000cc1a4a4aaaaaaaa4a4a
007717777777777000777177717777700071777177771700c11111111111161c0000000001111110ddddd11dd66ddddd0cc1000000000cc1aa4a4aaaa4a4a4aa
000717771777700000077177717770000071777117771700c11111111111161c0000000001000010dddddd1166d66ddd0cc1000000000cc1a4a40aaa4aaa4a4a
000771117777770000077711177777000771771771771770c11111111111661c0000000001000010ddddd1d16d6ddddd0cccccccccccccc1aa0a0aaaaaa0a0aa
000777777777000000077777777000000700717771170070c11111111116611c0000000001000010ddddd1d16d6ddddd0cc1c1c1c1c1c1c1a0000aa00aa0000a
077177777771770000007777770000000000707770070000cc111661166611cc0000000001000010ddd11d1166dddddd0cc1000000000cc100000a0000a00000
0777177777177700000011111100000000000007000000000cc1111111111cc00000000001111110ddddd11dd66ddddd0cc1000000000cc1000aaa0000aaa000
00777000007770000000777777000000000000070000000000cccccccccccc000000000010000001111111dddd6666660cc1000000000cc100aa0aa00aa0aa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000551551550000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505151151515000000000000000000
00000000000000000000000000000000000000000000000000011000000110000000000000000000000000000000000005151111111111500000000000000000
00000000000000000000000000000000000000000100000000177110011771000000000000000000000000000000000005111111111111500000000000000000
000000000000000000000000000000000000000017100000001777711777710000000000000000000000000000000000511111fffff111150000000000000000
000000000000000000000001100000000000111177100000000177777777100000000000000000000000000000000000511ffffffffff1150000000000000000
00000001100000000000001771000000000177777710000000017777777710000000000000000000000000000000000511ffffffffffff150000000000000000
00000017710000000000017777100000000017777710000000001777777100000000000000000000000000000000000511fffffffffffff50000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051f11111fff1111150000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000059ff111fffff111f50000000000000000
000000011000000000000000010000000000000000000000000000100000000000000000000000000000000000000054fff7777fff7777f95000000000000000
000000177100000000000000171000000000110000110000000001710000000000000000000000000000000000000054fff1177fff1177f95000000000000000
000000177100000000000001771000000001771101771000000001771000000000000000000000000000000000000054fff1177fff1177f95000000000000000
000000177100000000011117771000000001777717771000000001777111100000000000000000000000000000000054fff777ffff777ff95000000000000000
0001117777111000001777777710000000001777777100000000017777777100000000000000000000000000000000054fffffff4f4fff950000000000000000
0017777777777100000177777771000000000177777100000000177777771000000000000000000000000000000000005fffffffffffff500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005ffffff999ff9500000000000000000
0000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000054ffffffff95000000000000000000
00000000000000000000000000000000000000000000017100000000000000000000000000000000000000000000000000054fffff9950005550005550000000
00000000000000000000000000000000000000000000017100000000000000000000000000000000000000000000000055555999994555553335053335000000
000000000000000000000000000000000000000000000177100000000000000000000000000000000000000000000055111ccffffffc11131173531173500000
00000000000100000000000000000000000000000000017710000000000000000000000000000000000000000000551111111cffffc111131173531173500000
000000000017110000000000000000000000000000000177100000000000000000000000000000000000000000051111111111cccc1111133773337733500000
00000000001777100000000000000000000000000000017771100000000000000000000000000000000000000055111111111111111911113333333335000000
00000000001777100000000000000000000000000000177777710000000000000000000000000000000000000511111111111111191911133333333333550000
00000000000177710000000000000000000000000011777777771100000000000000000000000000000000000511111111199991999999333333133133335000
00000000000177710000000111000000000000000177777777777710000000000000000000000000000000000511111111119111911911333133333331335000
000000000001777711111117771000000000000001777777777777100000000000000000000000000000000005111f1111119111199999333313333313335000
00000000000177777777777771000000000000001777777777777771000000000000000000000000000000005111f91111199991111911133331111133335000
0000000000017777777777777100000000000001777777777777777711111100000000000000000000000000511fff9111119111199999313333333333115000
0000000000017777777777711000000000000001777777777777777777777710000000000000000000000000511fff9111199991991913331333333331333500
00000000000177777777711000000000000011177777777777777777777711000000000000000000000000005114ff9111999119911933333111111113333350
000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000000001100000000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000000017710000000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000000177771000000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000001777777100000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000001777777100000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000017777777710000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000017777777710000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000017777777710000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000000177777777771000000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000001777777777777100000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000017777777777777710000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000000017777777777777710000000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000001177777777777777771100000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000017777777777777777777710000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000000177777777777777777777771000000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000000111777777777777777777777777111000000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000011777777777777777777777777777777110000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000000177777777777777777777777777777777771000000d111111111111111111111111111111d000000000000000000000000000000000000000000000000
000001777777777777777777777777777777777777100000dddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
000017777777777777777777777777777777777777710000dddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007777000770077000777700077777000077770007777770077007700777770000777700077777700077770000777700077007700000000000000000
07770070077007700777077007700770077007700770077000077000077007700770077007700770000770000007700007700770077707700000000000000000
07700000077007700777077007700000077007700770077000077000077007700770077007700770000770000007700007700770077707700000000000000000
07700000077007700777777007700000077007700770077000077000077007700770077007700770000770000007700007700770077777700000000000000000
07700000077007700770777007707770077777000777777000077000077007700777770007777770000770000007700007700770077077700000000000000000
07770070077007700770777007700770077007700770077000077000077007700770077007700770000770000007700007700770077077700000000000000000
00777700007777000770077000777700077007700770077000077000007777000770077007700770000770000077770000777700077007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700077000000777777000777700077777000007700000000000000000000011110000000000000000000000000000000000000000000000000000000000
07770070077000000770000007700770077007700077770000000000000000000177771000000000000000000000000000000000000000000000000000000000
07700000077000000770000007700770077007700077770000000000000000001777777100000000000000000000000000000000000000000000000000000000
07700000077000000777777007700770077007700077770000000000000000001777777710000000000000000000000000000000000000000000000000000000
07700000077000000770000007777770077777000007700000000000000000001777777771000000000000000000000000000011100000000000000000000000
07770070077000000770000007700770077007700000000000000000000000000177777777100000000000000000000000000177711000000000000000000000
00777700077777700777777007700770077007700007700000000000000000000017777777710000110111000000000000001777777100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000001777777771011771777101100000000001777777710000001111000000000
00777700077000000770000000000000000000000000000000000000000000000000177777777177777177717711000000001777777771011717777011000000
07700770077000000770000000000000000000000000000000000000000000000000017777777717777717771777100000000177777777177771777177100000
07700770077000000770000000000000000000000000000000000000000000000000001777777771777771771777100000000017777777717777177717710000
07700770077000000770000000000000000000000000000000000000000000000000000177777777177771777777710000000001777777771777717777771000
07777770077000000770000000000000000000000000000000000000000000000000000017777777717777777777710000000000177777777177777777771000
07700770077000000770000000000000000000000000000000000000000000000000000171777777717777777777710000000000177777777177777777771000
07700770077777700777777000000000000000000000000000000000000000000000001771777777777777777777710000000001717777777777777777777100
00000001110000000000000111000000000001111110000000000000011100000000017771777777777777777777771000000017717777777777777777777100
00000011100010000000001110001000000011111111000000000011111000000000177771777777777777777777771000000177717777777777777777777100
00011111001110000001111100111000000011111111000000101111110001000000177711777777777777777777771000000177117777777777777777777100
00111111111100000011111111110000110111111111100000101011110001000000177711777777777777777777771000001777117777777777777777777710
01111111111001100111111111100110111111111111110001110001100011100000177711177777777777777777771000001777711777777777777777777710
01111111111111000111111111111100011111111111111101111011110111100000017777177777777777777777771000000177771777777777777777777710
11111111111110001111111111111000000111111111111111111111111111110000001777177777777777777777771000000177777777777777777777777710
11111111111100001111111111110000000111111111101111111111111111110000000177777777777777777777771000000017777777777777777777777710
01111111111111110111111111111111000111111111100011111111111111110000000017777777777777777777710000000001777777777777777777777100
00111111111111100011111111111110001111111111110011111111111111110000000017777777777777777777710000000000177777777777777777777100
00011111111110000001111111111000001111111111110011110111111111110000000001177777777777777777100000000000011777777777777777771000
00011111111111000001111111111100011111111111111011010111111010110000000000017777777777777771000000000000000177777777777777710000
00011111111100000001111111100000010011111111001010000110011000010000000000001117777777777710000000000000000011177777777777100000
01111111111111000000111111000000000010111001000000000100001000000000000000000001177777777100000000000000000000011777777771000000
01111111111111000000111111000000000000010000000000011100001110000000000000000000011111111000000000000000000000000111111110000000
00111000001110000000111111000000000000010000000000110110011011000000000000000000000000000000000000000000000000000000000000000000
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
010300003805038150380503815038000381003800038100221000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000021336213362133621336213362133621336213361c3361c3361c3361c3361c3361c3361c3361c33600000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003955730557395573055739557305573955730557300030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c5150c500135000c500135000c50000000000000c500135000c500135000c50013500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001351500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000300302f0312e0312d0312c0312b0312a0312903130000300002f0002f0002e0002e0002d0002d0002c0002c0002b0002b0002a0002a00029000290000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600002105021050210502105021050210502105021050210502105021050210502105021050210502105000000000002105021050210502105023050230502305023050240502405024050240502605026050
010600002605026050260002600001000260002605026050260502605024000240002400024000240502405024050240502305023050230502305023050230502305023050240502405024050240502405024050
010600202405024050240502405024050240502305023050230502305023050230502305023050240502405024050240502305023050230502305024050240502405024050240502405024050240502405024050
010600002405024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000290000000026000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000201c0351c0351c0351c035210352103521035210351c0351c0351c0351c035210352103521035210351c0351c0351a0351a03518035180351a0351a0351c0351c03500005000051c0351c0350000500705
01100020210352103521035210351c0351c0351c0351c035210352103521035210351c0351c0351c0351c03521035210351d0351d0351c0351c03518035180351503515035000050000515035150350000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011c00001f0551f055200502005020050200551f0551f0001f0551f055200502005020050200551f0551f0001f0551f055200550c1001f0551f055200550c1001f0551f055210552305524055240002305500000
01100000240502405509100091000910009100091000910009100091000c1000c1000e1000e1000c1000c100101001010010100101000e1000e1000e1000e1000e1000e1000e1000e10000100001000000000000
01100000091000910009100091000910009100091000910009100091000c1000c1000e1000e1000c1000c1000b1000b1000b1000b1000e1000e00009100091000910009100091000910000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000101501015010150101551015010150101501015510150101501315013150000000000000000000000c1500c1500c1500c1550c1500c1500c1500c1550c1500c150101501015000000000000000000000
01100000091500915009150091550915009150091500915509150091500c1500c1500e1500e1500c1500c150101501015010150101550e1000e1050e1500e1550e1500e1500e1500e15000100001000000000000
01100000091500915009150091550915009150091500915509150091500c1500c1500e1500e1500c1500c1500b1500b1500b1500b1500e1000e00009150091550915009150091500915000000000000000000000
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
00 0a 42 43 44
00 0b 42 43 44
00 0c 42 43 44
02 0d 42 43 44
01 14 42 43 44
02 15 42 43 44
01 1e 42 43 44
02 1f 42 43 44
01 28 42 43 44
00 29 42 43 44
00 28 42 43 44
02 2a 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
