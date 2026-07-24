pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- ms/gg music player
-- two owls
tone = {0,0,0}
volume = {0,0,0}
tc = {0,0,0}
subtract=40.58
output = {0,0,0}

noiseoutput = 0
noisevol = 0
noise = 0
nc = 0
lfsr = 0x8000

scope = {}

voltable={
		32767, 26028, 20675, 16422, 13045, 10362, 8231, 6568,
		5193, 4125, 3277, 2603, 2067, 1642, 1304, 0
	}

vstr={}
tstrlo={}
tstrhi={}

tctxtlo={}
tctxthi={}
vctxt={}

numtunes=4
curtune=1

tunebank={}

title={}
title[1]="yuzo koshiro - the streets of rage (1/4)"
title[2]="motohiro kawashima - expander (2/4)"
title[3]="yuzo koshiro - fighting in the street (3/4)"
title[4]="motohiro kawashima - max man (4/4)"
titlepos=0

function stringindex(thestring, pos, offset)
	return ord(sub(thestring, pos, pos))-offset
end

function initcontext(c)
 c.vrun=0
 c.pos=1
 c.v=0
end

function resetall()
	for c =1,3 do
		tctxtlo[c]={}
		tctxthi[c]={}
		initcontext(tctxtlo[c])
		initcontext(tctxthi[c])
		
		tstrlo[c] = tunebank[curtune].tstrlo[c]
		tstrhi[c] = tunebank[curtune].tstrhi[c]
	end
	for c =1,4 do
		vctxt[c]={}
		initcontext(vctxt[c])
		vstr[c] = tunebank[curtune].vstr[c]
	end
	
	titlepos=0
end

function getnexttone(thestring, context)

	if context.vrun == 0 then		
		context.v = stringindex(thestring,context.pos,32)
		context.pos+=1

		if context.v < 32 then
			context.vrun = stringindex(thestring, context.pos,32)
			context.pos+=1
		else
			context.v &= 0x1f
		end
	else
		context.vrun -=1
	end

	return context.v;
end

function getnextvol(thestring, context)
	
	if context.vrun == 0 then
		context.v = stringindex(thestring,context.pos,32)
		context.pos+=1

		if context.v < 16 then
			context.vrun = stringindex(thestring, context.pos,32)
			context.pos+=1
		else
		 --careful of frac on shift!
 		context.vrun = ((context.v >> 4)&0x3) - 1
			context.v &= 0xf
		end
	else
		context.vrun -=1
	end

	return context.v;
end
	
function _init()
	memset(0x4300,0,96)
	
	for t=1,numtunes do
		tunebank[t]={}
		tunebank[t].vstr={}
		tunebank[t].tstrlo={}
		tunebank[t].tstrhi={}
	end
	
	local t=tunebank
	
	t[1].vstr[1]="/O%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%$&C\'C(C9Z;I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<I*#I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<I*#I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<I*#I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<I*#I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<I*#I*#I*#E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[\\]^/#E6GXYZ[\\]>E6GXYZ[<C&_&%C&AC&AC&_&IC&AC&_&%C&AC&AC&_&_&-C&_&%C&AC&AC&_&IC&AC&_&%C&AC&AC&_&_&-HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[HY:HY:HY:DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[\\M^/#DVGXYJ[\\M>DVGXYJ[LMN/_/_/_/_/_/_/R"
	t[1].vstr[2]="++*+)+(+\'+&+%+$+#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#?B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&1\'1(\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&\'B%\'&\'B%\'&\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&1\'1(\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&\'B%\'&\'B%\'&\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&1\'1(\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&\'B%\'&\'B%\'&\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&1\'1(\'B%\'&1GB%\'&\'B%#B%\'&1GB%#B%\'&\'B%\'&\'B%\'&\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'B%\'&1GB%\'&-B%\'&1\'\'B%\'&1\'1(\'%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%_%D&C\'C(B/_/_/_/_/H"
	t[1].vstr[3]="/_O&_&_&_&_&_&_&_&_&_&_&_&_&_&_&_&_&]E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6G8E6G8E6G8E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6I:E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6GXIJ[LM^OE6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6GXY:E6G8E6G8E6G8E6GXIJ[LM^/_/_/_/_/_/_/H"
	t[1].vstr[4]="/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/;CFGHI:CFG8CFGHI:CFGH4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:CFG8CFGHI:CFGH4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:CFG8CFGHI:CFGH4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:CFG8CFGHI:CFGH4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/%4/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:D/$D/(E/$D/(E/$D/(D/$CFGHI:D/$D/(E/$D/(D/$B/(D/$CFGHI:CFG8CFGHI:CFG8/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/X"
	t[1].tstrlo[1]="</YRY@?\"@YRY@?\"@YRY@?\"@YRY@?\"@>+5+)+>/@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^./PQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMNPQPNMKMN5+\"+5/WXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTUWXWUTRTU)+>/@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@>0ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ>0ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZW+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^&/HI?/@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_ /ACA@^]^@ACA@^]^@ACA@5/WXWUTRTUWXWUTRTUWXWU>/@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^./PQPNMKMNPQPNMKMNPQPN?/@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_ /ACA@^]^@ACA@^]^@ACA@5/WXWUTRTUWXWUTRTUWXWU\"/EHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_B?/@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_ /ACA@^]^@ACA@^]^@ACA@5/WXWUTRTUWXWUTRTUWXWU>/@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^\\[\\^@A@^./PQPNMKMNPQPNMKMNPQPN?/@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_@B@_][]_ /ACA@^]^@ACA@^]^@ACA@5/WXWUTRTUWXWUTRTUWXWU\"/EHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_BEHEB_\\_B>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^&/HI>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PS>%+%3%5/WXWUTRTUWXWUTR5/WXWUTRTU>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\>0@A>%+%3%)/KLKIHFHIKLKIHF)/KLKIHFHI>/@A@^\\[\\^@A@^\\[>/@A@^\\[\\^-/PSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSPMJGJMPSP"
	t[1].tstrhi[1]="%/@A !?\" !A !?\" !A !?\" !A !?\"@\'+&+%;&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"E$_$_$_$7&+\'+&_&_&_&_&\'%;&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"E\'/(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'4(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'\"-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$$1#/$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$%3$\"%$$\"%$&C%/&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"E$C#/$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$%3$\"%$$\"%$&C\'3&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"G#/$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$%3$\"%$$\"%$&C%/&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"%$&\"E$C#/$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$$\"#$%3$\"%$$\"%$&C\'3&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'$&\"\'&-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$$1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(1\'%-%*%&U%/&\"%$&\"%2&\"%4&!\'%-%*%%_%%&\"%$&\"%2&\"%$(_(_(_(_(_(_(_(*"
	t[1].tstrlo[2]="?_?_?_?_?\';_;_;_;O?_?_?_?_?\':_:_:_:O!_!_!/?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?O\'%?=<%?_?E;%?=;%?1;/AG;/AG?O\'%?=<%?_?E;%?=;%?1;/AG;/AG?O\'%?=<%?_?E;%?=;%?1;/AG;/AG?O\'%?=<%?_?E;%?=;%?1;/AG;/AG?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?X"
	t[1].tstrhi[2]="?_?_?_?_?\'1_1_1_1O?_?_?_?_?\'7_7_7_7O4_4_4/?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?O5%?=/%?_?E1%?=1%?11/2!0/1!?O5%?=/%?_?E1%?=1%?11/2!0/1!?O5%?=/%?_?E1%?=1%?11/2!0/1!?O5%?=/%?_?E1%?=1%?11/2!0/1!?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?_?X"
	t[1].tstrlo[3]=" /YRY@?\"@YRY@?\"@YRY@?\"@YRY@?\"@YRY@?\"@YRY@?\"@YR;+4+(+=/^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^]-/OPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKMOPOMKJKM4+ +4/VWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRTVWVTRQRT(+=/^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^][Z[]^@^];/^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XUX[^A^[XU<13+<13%<1 +<1 %<1 +</BHB\\UOU\\=+<1=%<1 1<+ %<1 +<73+<13%<1 +<1 %<1 +</BHB\\UOU\\=+<1=%<1 1<+ %<1 +<73+<13%<1 +<1 %<1 +</BHB\\UOU\\=+<1=%<1 1<+ %<1 +<73+<13%<1 +<1 %<1 +</BHB\\UOU\\=+<1=%<1 1<+ %;%=% %%%3%-%<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\"-\"+\"<\"3\"+\">\"3\"5\">\")\"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\")\"+\"<\" \"+\">\" \"5\">\" \"5\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\"<\" \"%\"<\"=\"%\"=%\"\"=\">\"\"\">1)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %-%>% %\"%)%&%>1)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>7)+>1)%>1 +>1 %>1 +>/ADA^ZWZ^.+>1.%>1 1>+ %>1 +>/ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ^ADA^ZWZ"
	t[1].tstrhi[3]=" 0A !?\" !A !?\" !A !?\" !A !?\" !A !?\" !A !?\" !A\'+&+%<F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%!$_$_$_$7&+\'+&_&_&_&_&\'%<F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%&F%!\'0H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'&H\'#/1*+/1*%/1*+/1*%/1*+//0\"/$(+/1(%/1*1/+*%/1*+/7*+/1*%/1*+/1*%/1*+//0\"/$(+/1(%/1*1/+*%/1*+/7*+/1*%/1*+/1*%/1*+//0\"/$(+/1(%/1*1/+*%/1*+/7*+/1*%/1*+/1*%/1*+//0\"/$(+/1(%/1*1/+*%0%+%*%.%*%(%/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"(\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\"-\"/\"*\"-\"\'\"*\"&\"\'\"%\"&\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'\"/\"%\".\"/\"+\".\"(\"+\"\'\"(\"%\"\'4%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%(%%+\'%%%$%\'1%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'7%+\'1%%\'1%+\'1%%\'1%+\'/(\"\'$$+\'1$%\'1%1\'+%%\'1%+\'/(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'$(\"\'#"

	t[2].vstr[1]="#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#:_W_#:_W_X_Z/.#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_#_/_/_/_/_/_/_%_%/?%_%>?%_%>?%_%>?%."
	t[2].vstr[2]="A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56AD56A$\'56AD56A$\'56AD56A$\'56AD56AD56AD56A$\'56A$\'56A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$-?4A$#A$%\'#A$#A$%\'#A$#A$%\'#D\'#A$%\'#D\'#A$/"
	t[2].vstr[3]="?&#?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?\'$?$$?\'$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?$$?$$?$$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?\'$?$$?\'$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?$$?$$?$$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?\'$?$$?\'$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?$$?$$?$$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?\'$?$$?\'$?$$?&$?%$?$$?#$?\"$?&$?$$?$$?\'$?$$?$$?\'$?$$?$$?$$?$$?$*?$-?$*?$-?$*?$-?$*?$*?$*?$*?$*?$-?$*?$-?$*?$-?$*?$*?$*?$*?$*?$-?$*?$-?$*?$-?$*?$*?$*?$*?$*?$-?$*?$-?$*?$-?$*?$*?$*?$*?$*?$-?$*?$-?$*?$-?$*?$*?$*?$*?$*?$-?$*?$-?$*?$-?$*?$*?$*?$$?$:_X_$:_X_$R_X_$:_X_$R_X_$:_X_$R_X_$:_X_$R_X_$:_X_$R_X_$:_X_$R_X_$:_X_$R_X_$:_X_$7/_/_/_/_/_/_/1)_)_)_)_)_)M"
	t[2].vstr[4]="D/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#F/#CFGF/#F/#CFGF/#F/#F/$4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFW4/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFGD/#CFG/%CFGCFG/%CFGCFG/%CFGCFG/%CFGCFGCFGCFG"
	t[2].tstrlo[1]="\"#^Z.)ML5#Z_\"/^Z.)ML5#Z_\"G^Z.)ML5#Z_\"/^Z.)ML5#Z_\"G^Z.)ML5#Z_\"/^Z.)ML5#Z_\"G^Z.)ML5#Z_\"/^Z.)ML5#Z_\"C1#_M7)FV*#MO1/_M7)FV*#MO1G_M7)FV*#MO1/_M7)FV*#MO1G_M7)FV*#MO1/_M7)FV*#MO1G_M7)FV*#MO1/_M7)FV*#MO1C%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>+%#P\\\")VK%#[Q>)GQ%#P\\\")VK%#P\\5+\"+>_>_>_>_>_>_>+PMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVS"
	t[2].tstrhi[1]="\'$H))HG&%\'0H))HG&%\'HH))HG&%\'0H))HG&%\'HH))HG&%\'0H))HG&%\'HH))HG&%\'0H))HG&%\'C#$$+#7$+#O$+#7$+#O$+#7$+#O$+#7$+#J.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'7.#KH\')IL.#KI\')JL.#KH\')IL.#KH&+\'_\'_\'_\'_\'_\'_\'8KOSW[^BFJNRVZ^BFIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_CFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\@CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BFIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_CFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\@CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BFIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_CFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\@CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BFIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_CFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\@CGKOSW[_CGJNRVZ"
	t[2].tstrlo[2]="*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*U8% %*%7+8+*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS*1%%*%%%*78%*+8/@Q*1%%*%%%*781\'/MS"
	t[2].tstrhi[2]="<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<U?%>%<%:+?+<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151<1.%<%.%<7?%<+?/ !<1.%<%.%<7?151"
	t[2].tstrlo[3]="@#CEHKNP?%#%_CHLQU?1*%?%*%#DEHKNP?%#%?I#DEHKNP?%#%_CHLQU?1*%?%*%#DEHKNP?%#%?I#DEHKNP?%#%_CHLQU?1*%?%*%#DEHKNP?%#%?I#DEHKNP?%#%_CHLQU?1*%?%*%#DEHKNP?%#%?I&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:+&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:+&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:+&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:+&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:+&&R^JVB#)WK_TH&&\\SI@V:)CMWAJ&&R^JVB#)WK_TH&&R^JVB*+#+:%!#]Y-)LK5#Y^!/]Y-)LK5#Y^!/]Y-)LK5#Y^!#]Y-)LK5#Y^!/]Y-)LK5#Y^!/]Y-)LK5#Y^!#]Y-)LK5#Y^!/]Y-)LK5#Y^!/]Y-)LK5#Y^!#]Y-)LK5#Y^!/]Y-)LK5#Y^!/]Y-)LK5#Y^0#^L6)FU*#LO0/^L6)FU*#LO0/^L6)FU*#LO0#^L6)FU*#LO0/^L6)FU*#LO0/^L6)FU*#LO0#^L6)FU*#LO0/^L6)FU*#LO0/^L6)FU*#LO0#^L6)FU*#LO0/^L6)FU*#LO0/^L6)FU*#L/_/_/_/_/_/_/!N-!LK*!IH\'!FE$!CBOLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKHEB_\\YVSPMJGDA^[XUROLIFC@]ZWTQNKH"
	t[2].tstrhi[3]="@.COPQR3&.%SRPNLJ)%3+-%)%-%.DOPQR3&.%)I.DOPQR3&.%SRPNLJ)%3+-%)%-%.DOPQR3&.%)I.DOPQR3&.%SRPNLJ)%3+-%)%-%.DOPQR3&.%)I.DOPQR3&.%SRPNLJ)%3+-%)%-%.DOPQR3&.%)I<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/+<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/+<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/+<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/+<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/+<&YVTQO.)PSUX[<&YWUSP/)RTVY[<&YVTQO.)PSUX[<&YVTQO-+.+/%\'$H))HG&%\'0H))HG&%\'0H))HG&%\'$H))HG&%\'0H))HG&%\'0H))HG&%\'$H))HG&%\'0H))HG&%\'0H))HG&%\'$H))HG&%\'0H))HG&%\'0H))HG&%#$$+#7$+#7$+#+$+#7$+#7$+#+$+#7$+#7$+#+$+#7$+#7$+#_#_#_#_#_#_#\'DEFGHIJKLMNOPQRSTGKOSW[^BFJNRVZ^BEIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_BFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\_CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BEIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_BFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\_CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BEIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_BFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPTX\\_CGKOSW[_CGJNRVZGKOSW[^BFJNRVZ^BEIMQUY]AEIMPTX\\@DHLPTX[_CGKOSW[_BFJNRVZ^BFJMQUY]AEIMQUX\\@DHLPT"
	
	t[3].vstr[1]="B5F8B5F8B5F8B5F8B%0&%\'+(+\'7&+$*B%#FGHD\'$XIF($IZB%#FGHD\'$XIF($IZBU7B5F8B5F8B5F8B%_%=B%#B%#B%#B%#B%)B%#B%#FGHD\'$XIF(#B%#B%#B%#B%#B%0&%\'+(+\'7&+$*B%#FGHD\'$XIF($IZB%#FGHD\'$XIF($IZBU7B5F8B5F8B5F8B%_%=B%#F(#B%#B%#B%#F(#B%#B%;B5F8B5F8B5F8B5F8B%0&%\'+(+\'7&+$*B%#FGHD\'$XIF($IZB%#FGHD\'$XIF($IZBU7B5F8B5F8B5F8B%_%=B%#B%#B%#B%#B%)B%#B%#FGHD\'$XIF(#B%#B%#B%#B%#B%0&%\'+(+\'7&+$*B%#FGHD\'$XIF($IZB%#FGHD\'$XIF($IZBU7B5F8B5F8B5F8B%_%=B%#F(#B%#B%#B%#F(#B%#B%;F(5C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&)C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&)C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&)C&%(#F(#C&#H*#H*#C&#G)#C&#C&#G)#C&#G)#C&#G)#C&#C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&)C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&)C&%(#F(#C&#H*#H*#C&#H*#H*#C&#C&#C&#C&)C&#C&$GH9C&#C&#C&$GH9C&$GH9C&$GH9C&#C&#C&#C6G9D7H:D7H:D7H:B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#B%#B%#B%#B%#B%)B%#B%+\'#E\')H*#H*)\\]B%#B%#B%#B%#B%)B%#B%)B%#B%+\'#E\')H*#D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:D7H:B%#B%#B%#B%#B%("
	t[3].vstr[2]="/7B%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FB%\'FB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FB%\'FB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFBEFBEFBEFBEFB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FB%\'FBEFB%\'FB%\'FB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFBEFBEFBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFB%\'FBEFBEFB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFBEFBEFBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FDW8BEFB%\'FBEFB%\'FBEFDW8BEFB%\'FBEFBEFB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFB%\'FBEFBEFB%\'FBEFBEFB%\'FBEFB%\'FBEFBEFBEFBEFBEFBEFBEFB%\'6"
	t[3].vstr[3]="C6G9C6G9C6G9C6GI3&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#E\'#E\'%)#G)%*#C&#E\'#E\'%)#E\'#E\'#C&#C&#C&#C&#C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#C&$GH9C&#C&$GH9C&#C&$GH9C&$GH9C&#C&$GH9C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#E\'#E\'%)#G)%*#C&#E\'#E\'%)#E\'#E\'#C&#C&#C&#C&#C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#E\'#E\'%)#G)%*#C&#E\'#E\'%)#E\'#E\'#C&#C&#C&#C&#C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#C&$GH9C&#C&$GH9C&#C&$GH9C&$GH9C&#C&$GH9C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#C&#E\'#E\'%)#G)%*#C&#E\'#E\'%)#E\'#E\'#C&#C&#C&#C&#C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&$GH9C&#C&#C&#C&#B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8B5F8D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'$XIJKLD\'$XIJKLD\'$XID\'#D\'$XID\'$XID\'$XID\'#D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'$XIJKLD\'$XIJKLD\'$XIJKLD\'#D\'#D\'#D\')D\')D\'#D\'#D\'#D\'$XID\'$XID\'$XID\'#D\'#D\'#D\'#D\'$XIJKLC&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#C&#B%#C&#C&#D\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)C&#C&#C&#C&#C&)C&#C&$GH9C&#E\'#E\'#E\'#E\'#E\'#E\'#C&#C&#C&#C&#C&)C&#C&$GH9C&#C&5C&)B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#D\'#B%#C&#C&#C&#B%#B%#B%#B%#C&#CV"
	t[3].vstr[4]="/84/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/$3FGF/$6/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/$3FGF/$6/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/$3FGF/$6/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/$3FGF/$6/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/#D/#F/#F/#F/#CFGF/#F/#F/#CFGCFGCFGCFGCFGCFG/%CFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/$3FGF/#F/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/$3FGF/#F/#F/#D/#CFGD/#D/$3FGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGF/#F/#F/$4/#F/#F/#F/#CFGF/#F/#F/#D/#CFGD/#D/#CFGCFGCFGCFW4/#F/#F/#F/$3FGF/#F/#F/#D/#CFGD/#D/$3FGF/#F/#F/$4/#F/#F/#F/$3FGF/#F/#F/#D/#CFGD/#D/$3FGCFGCFGCFW4/#F_"
	t[3].tstrlo[1]="5%3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C8C5%3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C.%8=5%3% %3% /ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C8C5%3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&%)%&+8% %&%*/KLK*!I*!KLK*!I5\"*\"3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C8C5%3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C.%8=5%3% %3% /ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&C8C5%3\"5\" \"3% 2ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@ACA@^]^@&%)%&+8% %&%*/KLK*!I*!KLK*!I*/KLK*!I*! %+% 75% %5%+%\'%+%\'+3+ %+% 75% %5%+%\'%+%\'+3+ %+% 75% %5%+%\'%+%\'+3+ %+% 7\"%3%0%-%0%5%-%3%5%)% %+% 75% %5%+%\'%+%\'+3+ %+% 75% %5%+%\'%+%\'+3+ %+% 75% %5%+%\'%+%\'+3% 1-%0+\"+5+)%7%8%*\"8\"4\"*\"\'\"4\"5\"\'\" 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&%3\"*\";\"3%;\"\'\"3\" \"\'\"3\" %3\"-\" \")\"-%)%-\" \")\"&\" %&\")\" \"-\")\"+\"-\";\"+%;\"=\"+\"3\"=\"+\"3%+\"=\"3\"5\"=%5%=\")\"5\".\")%.\"5\")\"=\"5\" 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&% 71+ %8+ %8+ %8/Y[ 71+ %8+&%*+&%*+&%3\"*\";\"3%;\"\'\"3\" \"\'\"3\" %3\"-\" \")\"-%)%-\" \")\"&\" %&\")\" \"-\")\"+\"-\";\"+%;\"=\"+\"3\"=\"+\"3%+\"=\"3\"5\"=%5%=\")\"5(3% %3% *"
	t[3].tstrhi[1]="&%%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$C#C&%%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$I#=&%%E$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$C#C&%%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$%&%$+#%%%$%#=&\"#\"%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$C#C&%%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$I#=&%%E$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$C#C&%%\"&\"%?$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"%$$\"E$%&%$+#%%%$%#U*%-%*%%%*+&%*%&%-%+%-%++*1-%*%%%*+&%*%&%-%+%-%++*1-%*%%%*+&%*%&%-%+%-%++*1-%*%%%*+\'%*%\'%(%\'%&%(%%%&%%%*%-%*%%%*+&%*%&%-%+%-%++*1-%*%%%*+&%*%&%-%+%-%++*1-%*%%%*+&%*%&%-%+%-%++*7(%\'7&+%%$%#+\"\"#\"\"%!\"\"\"%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%,\"#\"0\",%0\"+\",\"*\"+\",\"*%,\"(\"*\"&\"(%&%(\"%\"&\"$\"%%$\"&\"%\"(\"&\"-\"(\"1\"-%1\"+\"-\"*\"+\"-\"*%-\"(\"*\"&\"(%&%(\"%\"&\"$\"%%$\"&\"%\"(\"&\"%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%%7#+%%#+%%#+%%#1%7#+%%#+$%#+$%#+$%,\"#\"0\",%0\"+\",\"*\"+\",\"*%,\"(\"*\"&\"(%&%(\"%\"&\"$\"%%$\"&\"%\"(\"&\"-\"(\"1\"-%1\"+\"-\"*\"+\"-\"*%-\"(\"*\"&\"(%&%(\"%\"&(%<"
	t[3].tstrlo[2]="!/YRY@?\"@!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7?7;+?C/+\'+!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7?7;+?C/+\'+!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;+?1;%3%;%?+/%?%!7;1%+ 1;7!7;1%+ 1;7!7;1%+ 1;7!7;+?1;%3%;%?+/%?%!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7?7;+?7!%?%;+?C\'+!%=+;%?%;%?+/%\'%!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7!+ %!%;1%+ 1;7?7;+?7!%?%;+?C\'+!%=+;%?%;%?+/%?%!*"
	t[3].tstrhi[2]="4/@A !?\"@4701.+/1074701.+/1074701.+/1074701.+/1074701.+/1074701.+/1074701.+/107?70+?C6+5+4701.+/1074701.+/1074701.+/1074701.+/1074701.+/1074701.+/1074701.+/107?70+?C6+5+4701.+/1074701.+/1074701.+/107470+?10%,%0%?+6%?%4701.+/1074701.+/1074701.+/107470+?10%,%0%?+6%?%4+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%07?70+?74%?%0+?C5+4%2+1%?%1%?+6%5%4+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%074+*%4%01.+/%*%/%07?70+?74%?%0+?C5+4%2+1%?%1%?+6%?%4*"
	t[3].tstrlo[3]="=\"?\"0\"=\"5\"0%5. +5+ +5+ +5+ %5%3%-%3%-%3%-% %0% %0%\"%0%-%\'%+%51 +5+ +5+ +5+ %5%3C>% 7-%\"+57 +5+ +5+ +5+ %5%3%-%3%-%3%-% %0% %0%\"%0%-%\'%+%51 +5+ +5+ +5+ %5%3\"5\" \"3\"-\" %-\")\" \"-\")\" \"-\"3\" \"+\"3%+\"=\"3%=\"+\"3\"=\"+\"\'\"=\"3\"\'\"5+ +5+ +5+ +5+ %5%3%-%3%-%3%-% %0% %0%\"%0%-%\'%+%51 +5+ +5+ +5+ %5%3C>% 7-%\"+57 +5+ +5+ +5+ %5%3%-%3%-%3%-% %0% %0%\"%0%-%\'%+%51 +5+ +5+ +5+ %5%3\"5\" \"3\"-\" %-\")\" \"-\")\" \"-\"3\" \"+\"3%+\"=\"3%=\"+\"3\"=\"+\"\'\"=\"3\"\'\"+/NQ5/WX=/@C;% %;% +%++/NQ5/WX=/@C;% %;% +%++/NQ5/WX=/@C;% %;% +%++/NQ5/WX.+ %\'+=+0+\"%+/NQ5/WX=/@C;% %;% +%++/NQ5/WX=/@C;% %;% +%++/NQ5/WX=/@C;% %;% +%+0+-%=7.+ %3++5NQ577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+ %3% 13% 13% 13% 7+% 1+% 1+% %)%3%+%)%577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+577+5% 13%)% +3%)%577+5% +3%./PQPNMKMN7+ %3% 13% 13% 13% 7+% 1+% 1+% %=%0%5%0%5*"
	t[3].tstrhi[3]="(\"?\"\'\"(\"&\"\'%&.*+&+*+&+*+&+*%&%%%(%%%(%%%(%%%\'%%%\'1(%+%-%&1*+&+*+&+*+&+*%&%%U*+(%\'+&7*+&+*+&+*+&+*%&%%%(%%%(%%%(%%%\'%%%\'1(%+%-%&1*+&+*+&+*+&+*%&%,\"&\"*\",\"(\"*%(\"&\"*\"(\"&\"*\"(\",\"*\"-\",\"*\"-\"(\"*%(\"-\"*\"+\"-\"+%*\"+\"&+*+&+*+&+*+&+*%&%%%(%%%(%%%(%%%\'%%%\'1(%+%-%&1*+&+*+&+*+&+*%&%%U*+(%\'+&7*+&+*+&+*+&+*%&%%%(%%%(%%%(%%%\'%%%\'1(%+%-%&1*+&+*+&+*+&+*%&%,\"&\"*\",\"(\"*%(\"&\"*\"(\"&\"*\"(\",\"*\"-\",\"*\"-\"(\"*%(\"-\"*\"+\"-\"+%*\"+\"-1&1(/)!1%/%1%/+.+-1&1(/)!1%/%1%/+.+-1&1(/)!1%/%1%/+.+-1&1)+*%++(+\'1-1&1(/)!1%/%1%/+.+-1&1(/)!1%/%1%/+.+-1&1(/)!1%/%1%/+.+\'+(=)+*+,%-7&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C%%,%*%%+,%*%%+,%*%%+,%*%%+*%-%%+*%-%%+*%-%%+*%-%%%&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C&7$+&%%U&7$+&%%1$C%%,%*%%+,%*%%+,%*%%+,%*%%+*%-%%+*%-%%+*%-%%%(%\'%&%\'%&*"
	
	t[4].vstr[1]="CFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGCFGB5F7DGHE7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9B5F7DGHE7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9B5F7E7H9E7H9B5F7E7H9E7H9B5F7E7H9A45FCFGDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FCFGDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FCFGDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FCFGDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGHA45FDGHDGHA45FDGHDGHA45FDGH3"
	t[4].vstr[2]="@$_$=@$_$=@$_$=@$_$=@$_$=@$_$=@$_$=@$_$=AD56A$\'56AD56A$\'56AD56AD5FGH9JK<=AD5FGH9DWXIJGYZ[<AD56A$\'56AD56A$\'56AD56AD5FGH9JK<=AD5FGH9DWXIJGYZ[<AD56A$\'56AD56A$\'56AD56AD5FGH9JK<=AD5FGH9DWXIJGYZ[<AD56A$\'56AD56A$\'56AD56AD5FGH9JK<=AD5FGH9DWXIJGYZ[<AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD56AD560"
	t[4].vstr[3]="?3&/E\'1)1*/\\-$.$/_/JC&/E\'1)1*/\\-$.$/_/JC&/E\'1)1*/\\-$.$/_/JC&/E\'1)1*/\\-$.$/_/JB%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%#D\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'#B%%\'#E\'#B%%\'#E\'#B%%\'$"
	t[4].vstr[4]="D/5D/5D/5D/5D/5D/5D/5D/64/5D/5D/5D/5D/5D/5D/5D/64/)F/$4/#CFG/&4/06/#D/#D/#CFGD/)F/#D/)F/#D/#CFG/%D//F/#D/#D/#CFGD/)F/$4/)F/$4/#CFG/&4/06/#D/#D/#CFGD/)F/$4/)F/#D/#CFG/%D//F/#D/#D/#CFGCFGCFGCFW4/#F/#D/)CFGD/#F/)D/#F/#D/)CFGD/#F/*4/#F/#D/)CFGD/#F/)D/#F/#D/)CFGD/#F/*4/#F/#D/)CFGD/#F/)D/#F/#D/)CFGD/#F/*4/#F/#D/)CFGD/#F/)D/#F/#D/)CFGCFGCFGCFW4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$4/#F/#D/#D/$3FW4/#F/#D/$"
	t[4].tstrlo[1]="?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+?7*+&+>O&%>+&=7%&+7=5%7+5=>O&%>+&=7%&+7=5%7+5=>O&%>+&=7%&+7=5%7+5=>O&%>+&=7%&+7=5%7+5=>O&%>+&=7%&+7=5%7+5=>O&%>+&=7%&+7=5%7+5=_"
	t[4].tstrhi[1]="\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+\"+#7$+%O$%%+$_$-&%$+&=%O$%%+$_$-&%$+&=%O$%%+$_$-&%$+&=%O$%%+$_$-&%$+&=%O$%%+$_$-&%$+&=%O$%%+$_$-&%$+&=B"
	t[4].tstrlo[2]=":/@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ;/AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[=/CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]7/]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW]C]WPJPW:/@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ@F@ZSMSZ;/AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[AGA[TNT[=/CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]CIC]VPV]+/NQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHKNQNKHEHK:%=+:%=+:%\'/JM+C:%=+:%=+:%\'/JM+C:%=+:%=+:%\'/JM+C:%=+:%=+:%\'/JM+C:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%:%\'%=%/%Z"
	t[4].tstrhi[2]="7/8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$0/1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$2/3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$:0[:&[:&[:&[:&[:&[:&[:&[:&[:&[:%7/8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$8\"7$0/1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$1\"0$2/3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$3\"2$-_-?7%++7%++7%+1-C7%++7%++7%+1-C7%++7%++7%+1-C7%++7%++7%+1-C7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%7%9%+%6%W"
	t[4].tstrlo[3]="@RUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^!1B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!!ORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^!1B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!!ORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^!1B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!!ORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^AORUX[^ADGJMORUX[^!1B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!\"B!\"@!!-O>%-+>=5%>+5=.%5+.=-O>%-+>=5%>+5=.%5+.=-O>%-+>=5%>+5=.%5+.=-O>%-+>=5%>+5=.%5+.=-O>%-+>=5%>+5=.%5+.=-O>%-+>=5%>+5=.%5+.>"
	t[4].tstrhi[3]="@!$\"*C!%\"*C!%\"*C!%\"*#_#X!%\"*C!%\"*C!%\"*C!%\"*#_#X!%\"*C!%\"*C!%\"*C!%\"*#_#X!%\"*C!%\"*C!%\"*C!%\"*#_#X(O%%(+%=&%%+&=)%&+)=(O%%(+%=&%%+&=)%&+)=(O%%(+%=&%%+&=)%&+)=(O%%(+%=&%%+&=)%&+)=(O%%(+%=&%%+&=)%&+)=(O%%(+%=&%%+&=)%&+)>"

	resetall()
end

function _draw()
	palt(0)
	sspr(0,0,128,128,0,0)
	
	line(18,scope[1],18,scope[1],10)
	for x=1,92 do
		line (x+18,scope[x],10)
	end
	
	print(title[curtune],titlepos,1,3)
	print(title[curtune],titlepos+#title[curtune]*4+10,1,3)
	--print(vctxt[4].v,0,0,7)
end

function clocklfsr()
	local output = lfsr & 1

	local feedback = (lfsr ^^ (lfsr >> 3)) & 1

	lfsr >>= 1
	--careful, sign extension...
	lfsr &= 0x7fff
	lfsr |= feedback << 15

	return output
end

function updatebuf()
	-- update tone channel + vol
	
	if tctxtlo[1].pos>#tstrlo[1] then
		if tctxtlo[1].vrun==0 then
			resetall()
		end
	end
	
	for c=1,3 do		 
		 tone[c]=getnexttone(tstrlo[c], tctxtlo[c])
		 tone[c]|=getnexttone(tstrhi[c], tctxthi[c])<<5  
		 
		 volume[c]=getnextvol(vstr[c],vctxt[c])
	end
	
	--update noise channel + vol
 -- all the tunes ive seen so far only use zero
	noise = 4
	noisevol=getnextvol(vstr[4],vctxt[4])
	
	for x=0,91 do
	
	 local vol=128
	 
		for c=1,3 do
		
			if output[c]==1 then
				vol += voltable[volume[c]+1]/1024
			else
				vol -= voltable[volume[c]+1]/1024
			end
			
			tc[c]-=subtract
			if tc[c]<0 then
				tc[c]+=tone[c]
				output[c] ^^= 1
			end
		end
		
		--noise channel
		
		if noiseoutput==1 then
			vol += voltable[noisevol+1]/1024
		else
			vol -= voltable[noisevol+1]/1024
		end
		
		nc -= subtract;
		
		if nc < 0 then
			local adder = tone[3]

			if ((noise & 3) < 3) adder = 0x10 << (noise&3)

			--lfsr is only clocked an a 0->1 transition, so:
			adder *= 2

			nc += adder
			noiseoutput = clocklfsr()
		end
		
		scope[x+1]=vol/5+88
		
		poke(0x4300+x,vol)
		
	end	
end


function _update60()
	if (stat(108)<512) then
		updatebuf()
		serial(0x808, 0x4300,92)
	end
	
	if btnp(‹) then
		curtune = mid(1,numtunes,curtune-1)
		resetall()
	end
	if btnp(‘) then
		curtune = mid(1,numtunes,curtune+1)
		resetall()
	end
	titlepos -= 1
	if (titlepos<(-4*#title[curtune]-9)) titlepos=0
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111111111110aaaaaaaaaaaaaaaa9aff999aa999aaa9a9999aaaa11111110444444445555550005566000000000000005555000555660050505050044444
011111111111111000aaaaaaaaaaafaaaaaaaaaaaa9aaaf9999fafaaaaa111110444444555550000000055600000000005560056560000556000550555044444
011111111111110c11000aaaaa9aaaaaaaa44aa9aaa9fa9999aaa99aa99a11110444445555000000000005600000000000056000656000005600005050504444
01111111111111011111100aaaa0aaaaaa4044aa9449faaaa4aaa999119911110444445500000055550005500000000000000600065000000500000505054444
011111111111110c1111111aaa01aaaaa00404aaa4049aaa9a449aff991aa1110444455000000550000000500000000000005050006000000060000005504444
01111111111110c11111111a9a01aa5a0110004a40444aaaaaa049aaaa91aa110444455000005500000000000000000888000055500600000000000000550444
011111111111a0c1a11111aaa015aaa011c1c1000004499aaaaa0a9a999111110444450000055000000000000004000888880005400500804000050000050444
011111111111aa001aa111a9a019aa011c1c1c1c1c104499a9aa04a9a99911110444450000050000000000880000400088888800040500800400005000050044
0111111111119aa400aa001aa11aaa0111c1c1c1c1cc0449a0aa94499a9911110444450040550000000898888800400088888880090000800480005000005004
01111111111119aaa49aaa09911a51111c1c1c1c1c1cc449a00a90aa9a9911110444400445500000009989888880040088888888049000080480000500005505
0111111111111a9aaa4aa9a4911a5111c1c1c1c1c1ccc449900a904a9a9a11110444400405500000099898888888090f99999888809000098080000005000050
01111111111114a9aaa99a4a900a011c1c1c1c1c1cccc449400a904a9a91111104444044055000000899898888ff0f0ff9999999999400088000000000000505
011111111111144a9aa9aa499995500001c1c1c1c1ccc499400a904a9aa1111104444044055000008989989fffff0fffff999999999900000000000005000050
011111111111ff94a9a9a49999a9999990000c1c1ccc499540a9914aaa11111104444044055000008898fffffffffffff9994449999944000000000000005005
01111111111f9449499a499999aa99999999900000ccc95040a9914aa411111104444044005000000889ffffffffffff90009999999f90000000000005550000
01111111111f44944aa49999994aa999999999999900000499a911aa4111111104444444405000000899ffffffff90000999999904ff9000000fff0000555000
01111111111f49494444999994944aa999999999999999949a9111aa4111111104444444405500000899999fffff90099000000009ff994000f999f000050500
0111111111194449994999f99440a94aa499f9f9f9999999991111a4111111110444444444050400009444449f999994000070009ffff94000f4449f00055050
011111111119949949499999995000094a999f9f9f999af911111a411111111104444444440504000099444499ff999996500049ffff99400f94949f00055500
0111111111119499999999f9990cfc00049999f9f9aaaf99111111111111111104444444444050440000000709ff99fff90999fffff999000f4994f050005550
0111111111114499f99999999990c1760499999f9944f9411111111111111111044444444444000400096500099f999fffffffffff9999000949999005500505
0111111111a4949f99999999f9999994499999f9500044411111111111111111044444444444400040099000499f999fffffffffff99990009494f9005050550
0111111111f4ff949999999ffff9f99999999995061104111111111111111111044444444444444440009f9999ff9999fffffffff999990009949f0005500055
011111111af4f99999999999ffff9999999999f901654011111111111111111104444444444444444400ffffffff9999ffffffff9f9999004f94990000550505
011111111aaa4f4999999999fff9f99999999999999949111111111111111111044444444444444444009fffffff99999ffffffff99999004ff9900000555000
01111111aaa9a449999999999f9f999999999999ffff9111111111111111111104444444444444444400fffff9ff99999fffffff9f99990099f7944000005505
01111111aa9aa9494999999999f99999999999999fff91111111111111111111044444444444444444409fffffff9ff9fffffffff99999004f56544440005550
0111111a19aa99949499999999999999ff999999f9ff91111111111111111111044444444444444444409ffffffffff99fffffff9f9999004467649448000055
01111111aa9999444999999999999994f99999f99ff9111111111111111111110444444444444444444009ffffff4499f9fffff9f9999900948a499484800005
0111111199999994949999999999999499999f9ff9f9111111111111111111110444444444444444444009fff94499999f9fff9f9f99990099a4849948488000
011115669999f99449499999999999994449f9ff9ff91111111111111111111104444444444444444440009fff9999999999fff9f9999400998a849944888880
01156699999f9994449499999999999994444ff49f9111111111111111111111044444444444444444000009fffff98888889fff999990049f8744494848a888
055699999999f994444999999994999999994449f9911111111111111111111104444444444444444400000099ff89994444fff9f999400499655949948488a8
06999999999f9f99449499999940549999999999f91111111111111111111111044444444444444444000000499f9888f84fff9f9999400999f5994994488a8a
099999999999f9994449999999405667775099999111111111111111111111110444444444444444440000000499f99999f94f999f94400999ff9999948488a8
09999999999f9f994444999999940055550499991111111111111111111111110444444444444444440000004499fffffffff9f9f994440999ff999994488888
09999999999ff99944449999999994099949999911111111111111111111111104444444444444444440000488aa9ff9fff9f99f9944440999ff999994848888
0999999999ff9999944449999999994449999995111999999111199999991111044444444444444444400088aa8889ffff9f9f999444490999ff999994488888
0999999999f9f99994444499999999f99f9999775599999999999999999999910444444444444444444004aa888888f9fff9f999444f990999ff999994848888
0999999999ff9999944444499999999ff9999667665999999999ffffffff99990444444444444444488404888888884ffff9994449f999099fff999994488888
0f99999999fff99999444444999999f9f9994766766999999999999ff9ffff990444444444444888888a0088888888849f94444f9fff99099fff999994848888
0799999999ff9f99999444444999999ff9944466676659999999999f9f9fffff0444444448888888aaa800888888888888888888f99f99999fff999994484888
0799999999fff999999444444499999f9944947677666599999999f9f9f9f9ff044444444488aaaa88888008888888888888888aff99f9999fff999944848888
07f9999999ff9f99999944444444999994499947677766599999999f9f9f9fff0444444444488a888888800888888888888888a00ff9f999fff9999948488888
0679999999f9f9f9999994444444444449999947676776659999999999ffffff04444444444488a88888880888888888888888a09ff99f9ffff9999484848888
067f999999ff9f999999994444444444999999476677666659999999999fffff044444444448088a888888088888888888888a0999ff99ffff99999448484888
0577999999fff9f99999999444494999999999476676667659999999999999ff044444444488808a88888888888888888888a09999ffffffff99994484848488
07677f9999fffffff999999999999999999994766777776765999999999999990444444444488808a888888888888888888a0999999ffffff999944444444488
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddddddddddddddd777ddd77ddddd77ddddd7777777ddddd77dddddddddddd2222222777777722222772222222222227772222777777777222227777777222
dddddddddddddddd77777ddd77dddd777ddddd7777777ddddd77dddddddddddd2222222777777772222772222222222777772222777777777222227777777222
dddddddddddddddd77d77dddd77dd777ddddd77dddddddddd77ddddddddddddd2222227722227772227722222222222772772222222227772222277222222222
ddddddddddddddd77dd77dddd77d777dddddd77dddddddddd77ddddddddddddd2222227722227722227722222222227722772222222277722222277222222222
dddddddddddddd77dd77dddddd7777dddddd77dddddddddd77dddddddddddddd2222277222277722277222222222277227722222222777222222772222222222
dddddddddddddd77dd77dddddd777ddddddd777777dddddd77dddddddddddddd2222277777777222277222222222277227722222227772222222777777222222
ddddddddddddd7777777ddddd7777dddddd7777777ddddd77ddddddddddddddd2222777777772222772222222222777777722222277722222227777777222222
dddddddddddd77777777dddd77777dddddd77dddddddddd77ddddddddddddddd2222772222277222772222222227777777722222777222222227722222222222
dddddddddddd77ddd77dddd777dd77dddd77dddddddddd77dddddddddddddddd2227722222277227722222222227722277222227772222222277222222222222
ddddddddddd77dddd77ddd777ddd77dddd77dddddddddd77dddddddddddddddd2227722222772227722222222277222277222277722222222277222222222222
dddddddddd77ddddd77dd777ddddd77dd777777777ddd777777777dddddddddd2277777777772277777777722772222277222777777777722777777777222222
dddddddddd77ddddd77dd77dddddd77dd777777777ddd777777777dddddddddd2277777777222277777777722772222277222777777777722777777777222222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
ddd77777ddd77777dd77ddd77dd777777dd77777ddddddddddddddddddd7777d2227777722277777227722277227777772277777222222222222222277777222
ddd777777d7777777d77ddd77dd77777ddd777777ddddddddddddddddd77777d2227777772777777727722277227777722277777722222222222222277777722
dd777dd77d77ddd77d77ddd77d77dddddd777dd77dddddddddddddddd77dd77d2277722772772227727722277277222222777227722222222222222277227722
dd777777d77dddd7777d7d77dd77777ddd777777dddddddddddddddd7777777d2277777727722227777272772277777222777777222222222222222277777222
d77777ddd77ddd77d7777777d777ddddd77777ddddddddddddddddd7777777dd2777772227722277277777772777222227777722222222222222222772277722
d77dddddd7777777d777d77dd7777777d77dd77dddddddddddddddd77ddd77dd2772222227777777277727722777777727722772222222222222222777777722
d77ddddddd77777dd77ddd7dd777777dd77ddd77ddddddddddddddd77ddd77dd2772222222777772277222722777777227722277222222222222222777777222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddd777dd77dd77dd77dd77dd77777ddddddddddddddddddddddddddd7777d2222227772277227722772277227777722222222222222222222222222277772
dddddd777dd77dd77dd77d777dd777777ddddddddddddddddddddddddd77777d2222227772277227722772777227777772222222222222222222222222777772
ddddd777dd77dd77dd7777777d777dd77dddddddddddddddddddddddd77dd77d2222277722772277227777777277722772222222222222222222222227722772
d77dd777dd77dd77dd7777777d777777dddddddddddddddddddddddd7777777d2772277722772277227777777277777722222222222222222222222277777772
d77d777dd77dd77dd77d7d77d77777ddddddddddddddddddddddddd7777777dd2772777227722772277272772777772222222222222222222222222777777722
d777777dd777777dd77ddd77d77dddddddddddddddddddddddddddd77ddd77dd2777777227777772277222772772222222222222222222222222222772227722
dd7777dddd777dddd77ddd77d77dddddddddddddddddddddddddddd77ddd77dd2277772222777222277222772772222222222222222222222222222772227722
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
ddd77777ddd77777ddd777777dd777777dd7777dddddddddddddddddd77777dd2227777722277777222777777227777772277772222222222222222222277772
dd7777777dd777777dd77777ddd77777ddd77777ddddddddddddddddd777777d2277777772277777722777772227777722277777222222222222222222777772
ddd77dd77d777dd77d77dddddd77dddddd77dd77ddddddddddddddddd77dd77d2227722772777227727722222277222222772277222222222222222227722772
dddd77dddd777777dd77777ddd77777ddd77dd77ddddddddddddddddd77777dd2222772222777777227777722277777222772277222222222222222277777772
d77dd777d77777ddd777ddddd777ddddd77dd77ddddddddddddddddd77dd777d2772277727777722277722222777222227722772222222222222222777777722
d7777777d77dddddd7777777d7777777d777777ddddddddddddddddd7777777d2777777727722222277777772777777727777772222222222222222772227722
dd77777dd77dddddd777777dd777777dd77777dddddddddddddddddd777777dd2277777227722222277777722777777227777722222222222222222772227722
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222222222222222222222222222222
dd555555555555555559a555555555555555555555555555555555555555555d2255555555555555555555555555555555555555555555555555555555555552
dd500050005000500011caa0005000500050005000500050005000500050005d2250005000500050005000500050005000500050005444400050005000500052
dd5000500050005000a119ca005000500050005000500050005000500050005d2250005000500050005000500050005000500050004404040050005000500052
dd5000500050005000494f4a005000500050005000500050005000500050005d2250005000500050005000500050005000500050004888004450005000500052
dd5555555555555555a99f95555555555500f55555555555555555555555555d2255555555555555555555555555555555555555555949040044455555555552
dd5000500050005000499950005ff9f90100f95000500050005000500050005d2250005000500050005000500050005000500050005999004440045000500052
dd50005000500050969949644ff49990ca0f995000500050005000500050005d2250005000500050005000500050005000500050005098400044005000500052
dd5000500050005967999676999999901e09905000500050005000500050005d2250005000500050005000500050005000500050000ee8988004005000500052
dd5555555555555977696764994455555555555555555555555555555555555d22555555555555555555555555555555555555555e07900800e5455555555552
dd5000500050005976777779945000500050005000500050005000500050005d22500050005000500050005000500050009900f08e877e089f8e005000500052
dd5000500050000096777776405000500050005000500050005000500050005d2250005000500050005000500050005009990099444444449998005000500052
dd500050005000ff04676460005000500050005000500050005000500050005d2250005000500050005000500050005000508899945888844098005000500052
dd555555555550f991464155555555555555555555555555555555555555555d2255555555555555555555555555555555558955555507005555555555555552
dd500050005000099cc11150005000500050005000500050005000500050005d22500050005000500050005000500050005009500058e8444050005000500052
dd50005000500051111c1cc0005000500050005000500050005000500050005d2250005000500050005000500050005000500050005e7e884050005000500052
dd500050005000511c1cc11c005000500050005000500050005000500050005d2250005000500050005000500050005000500050008784444450005000500052
dd55555555555551c1c01111c55555555555555555555555555555555555555d225555555555555555555555555555555555555555eeee884455555555555552
dd500050005000511c1001111c5000500050005000500050005000500050005d2250005000500050005000500050005000500050009940599450005000500052
dd50005000500051c1c000111c5000500050005000500050005000500050005d225000500050005000500050005000500050005000f9905f9950005000500052
dd500050005000111cc0000111c000500050005000500050005000500050005d225000500050005000500050005000500050005000990050f940005000500052
dd555555555555116c55555011c555555555555555555555555555555555555d22555555555555555555555555555555555555555f945555f945555555555552
dd500050005000117c500050111c00500050005000500050005000500050005d2250005000500050005000500050005000500050099400500f90005000500052
dd50005000501116c0500050111c00500050005000500050005000500050005d2250005000500050005000500050005000500050094000500f90005000500052
dd50005000501111cc500050111c00500050005000500050005000500050005d2250005000500050005000500050005000500050f99000500994005000500052
dd5555555555111cc5555555111c55555555555555555555555555555555555d2255555555555555555555555555555555555555945555555594555555555552
dd500050005111c00050005011c000500050005000500050005000500050005d2250005000500050005000500050005000500050995000500099005000500052
dd5000500051cc50005000501cc000500050005000500050005000500050005d2250005000500050005000500050005000500050005000500000005000500052
dd5000500050005000500050000700500050005000500050005000500050005d2250005000500050005000500050005000500058405000500008405000500052
dd5555555556765555555555778655555555555555555555555555555555555d2255555555555555555555555555555555555550045555555550055555555552
ddddddddddd8086dddddddddd7876ddddddddddddddddddddddddddddddddddd2222222222222222222222222222222222222227822222222227842222222222
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
