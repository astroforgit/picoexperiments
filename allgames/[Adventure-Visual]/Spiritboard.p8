pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--~~spiritboard~~
--by capnmarcy
timer = 0
gamestate = 0
spookystate = 0
pickedquestionnumber = 0
questionnumber = 0
questionstate = 0
questionsanswered = 0
scrollspeed = 2
gamemode = 0
spookysprites = false

dresser = {}
wardrobe = {}
door = {}
window = {}
room = {}
spiritboard = {}
planchet = {}
sprites = {}
randsused = {}
 
conversations = "111,gemnever give up and soon you will be the most confident gal we know!;samthat's nice. love youself gurrrl;,112,gem$wooooooooooh$w do you have a $wcrush$w? is that why you dyed your hair like hers? that's so cute.;jay$wgeeeeeeeeem!$w stop it! it's just a dumb game! my parents would kill me if they heard you saying that!;sam$d08heh. yeah.$d i guess they would.;gemsorry sorry+ i'm a big tease and you are great however you are. your parents suck dude.;,113,samaww gal pals! you guuuuuuys!;gemwe'll crush everyone with our friendship!;jayfriends till the end!;,114,jaywow+ that's right. she seems nice.;gemshe's $wdreamy$w. have you seen her at roller derby? she's like wonderwoman on skates.;samdoes our gem have a crush? sad she couldn't come tonight? i'll get you the ben and jerry's to cry in;gem*fake crying* oh woe is me+ she's too cool for a weeb like me. bring me the largest spoon;jayalways with the melodrama.;,115,,116,,117,gempaul is nice.;,118,,121,jay$c08*blushes more*$c;samthey are pals right? just pally pals.;gemyou uh+ didnt see those movies or books did you?;samtheres so much to see and do it's one series okay? they are those friends who like harry right?;jay$d09         yeah. the best of friends$d;,122,samdamn right! gotta love yourself when everyone is a jerk. not you girls though;jayyou're great don't listen to them.;,123,sam...that's just what i was thinking.$s creepy$s.;gemi'll chug your mead and have all the women! you should see me in my loincloth. they call me the leather lover+ my harem covers a continent;jay$wgeeeeeeem$w behave!;,124,samthat makes sense. she seems nice+ she told me she liked my hair once. she doesn't seem to be a prick like cindy;gemand gurl+ those muscles guuurl. maybe i can pick up roller derby so she can $wslam$w me into a wall.;jaythat's pretty fucking kinky dude! you need a cold shower?;samjay said fuck! not so christian camp now are ya? have an extra cookie;,125,,126,,127,jaypaul is nice;,128,,131,jay$d09i-in$d what way?;gemi don't know what it means. $d09...$d you're a very$d13 $dprecious friend and i like you lots+ $d09okay$d?;jaythanks gem. means a lot. i know you find it hard to speak like that;gem$d06what$d do you $smean?!$s i am a bastion of feelings! a hulkess of sharing emotion.;,132,gemlike thelma and louise we gonna burn down a school and surf on a pizzzza;samsaccrificing virgins and sitting next to each other in science class. so hardcore it hurt-cores? hardcuts?;,133,jaywow! that's hella lewd guys.;gemhaha it $wprobably$w means i like how i look. $wwhat$w pray tell are you thinking of jay?;jayyou know! i bet you know! i bet you do it as well! $c08ghost$cs don't lie!;gemhey it's natural and fun!;jay*$c08blushes$c* $wgeeeeeeeeeeeeeeem!$w;gemmake friends with your body!;,134,jay$d10...$d ;sam$d10...$d just ask her out already. we don't need a ghost telling us about how thirsty you are to know you like her!;gemcmon guys the ghost must be confused! i'm a pure maiden! and molly is just a friend!$d10...$d a hot friend!;sami'll tell her if you don't soon!;,135,,136,,137,sampaul is nice;,138,,141,jayoh thats good. we don't talk much so it's hard to know.;,142,samego boost get. we should hang with her more.;gemlet's take her camping out by the river! she seems sporty she'd probably love it!;jayyou looking to share a tent with her $wgeeeeenm$w?;gem$wwhy$w+ do you want to bunk up with $wsaaam$w?;,143,gem*blush*;jayand herewe see the rare blushing gem. caught offgaurd by a spooky toy mentioning her crush her heart rate quickens;jayblood is pumped into her face in an ingenious mating display she combines this with hunching forward emphasising her cleavage to try and;jay attract the mate she has selected in long hours of gazing around the classroom;gem$wjaaaaaaaaaaay$w!;,144,jayi know that feeling!;samdon't worry your friends care for you even when its hard for you!;gemmmm and the same goes for molly too;,145,,146,,147,gemhuh+ guess she doesn't know them;,148,,211,jay$si'm shocked$s positively $sbewildered$s+ after all the girl scout cookies i sell;gemis selling cookies the most active you get?;jay$sshocked$s;,212,jayif this $c08ghost$c is real then maybe we all already are!;samit's"

questionanswertable = "111,more and more;,112,more than you think;,113,as a friend;,114,if she knew her better;,115,neg;,116,neg;,117,he is nice;,118,neg;,121,like ron likes hermione;,122,yes;,123,yes shes like a fun barbarian;,124,she does;,125,neg;,126,neg;,127,he is nice;,128,neg;,131,not in that way;,132,such good friends;,133,physically more than mentally;,134,like a dog in heat;,135,neg;,136,neg;,137,he is nice;,138,neg;,141,yes;,142,she thinks sam is cool;,143,admiration from afar;,144,she trys;,145,neg;,146,neg;,147,neg;,148,neg;,211,no;,212,yes;,213,yes;,214,eventually;,215,yes;,216,not by monetary standards;,217,not forever but it will be sad;,218,she is already;,221,somewhat;,222,yes;,223,yes;,224,yes;,225,a harem awaits;,226,no;,227,sometimes;,228,eh;,231,soon she will;,232,of course;,233,yes;,234,sickeningly;,235,indeed;,236,yes;,237,no one escapes sadness;,238,mildly;,241,she will keep it up;,242,yes;,243,extremely;,244,sickeningly;,245,indeed;,246,yes;,247,periods of grief;,248,yes;,31,i will destroy everyone;,32,i will destroy everyone;,33,i will destroy everyone;,34,i will destroy everyone;,35,i will destroy everyone;,36,i will destroy everyone;,37,i will destroy everyone;,38,i will destroy everyone;,4,break the seal binding me here;,5,on her way;,6,fourty two;,7,otters are carnivorous mammals in the subfamily lutrinae   ;,8,enough stalling your time has come;,3000,yes;,3001,it is favoured to be so;,3002,in the near future;,3003,most definitely;,3004,you dont need a ghost to know that;,3005,the answer is yes;,3006,yeah;,3007,yes;,3008,aye;,3009,totally;,3010,yes;,3020,negative;,3021,the future says no;,3022,not even a ghost could make that true;,3023,no;,3024,nah nah nah;,3025,not now and not in the future;,3026,doesnt seem like it;,3027,probs not;,3028,nope;,3029,unlikely;,3030,ask something else;,"
questionmenustr = "does ____ like ____?,will ____ be _____?,what kills ____?,how do we banish you?,where's molly?,whats the meaning of life?,read wikipedia:otters,read the blazblu wiki,"
namemenustr = "jay,sam,gem,molly,bort,sarah,paul,paste,"
adjectivemenustr = "athletic,a witch,cute,happy,married,rich,sad,smart,"

objects = {}

btslut = { [1]="a",[2]="b",[3]="c",[4]="d",[5]="e",[6]="f",[7]="g",[8]="h",[9]="i",[10]="j",[11]="k",[12]="l",[13]="m",[14]="n",[15]="o",[16]="p",[17]="q",[18]="r",[19]="s",[20]="t",[21]="u",[22]="v",[23]="w",[24]="x",[25]="y",[26]="z",[27]=" ",[28]=",",[29]=".",[30]="$",[31]="#",[32]="1",[33]="2",[34]="3",[35]="4",[36]="5",[37]="6",[38]="7",[39]="8",[40]="9",[41]="0",[42]="+",[43]="!",[44]=";",[45]="'",[46]="?",[47]="*",[48]="-",[49]=":",[50]="&"}


function tostring(any)
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
        local str = "{ "
        for k,v in pairs(any) do
            str=str..tostring(k).."->"..tostring(v).." "
        end
        return str.."}"
    end
    if type(any)=="number" then
        return ""..any
    end
    return "unkown" -- should never show
end

function bytetostring(byte)
	return btslut[byte]	
end

function frommemory(endaddr,startaddr)
	local buffer = ""
	start = startaddr or 0
	for i=start,endaddr,3 do
		vals = {}
		for j=0,2 do
			add(vals,peek(i+j))
		end
		local temp = 0
		buffer = buffer .. bytetostring(band(vals[1],0b00111111))
		buffer = buffer .. bytetostring(band(bor(shl(vals[2],2),shr(vals[1],6)),0b00111111))
		buffer = buffer .. bytetostring(band(bor(shl(vals[3],4),shr(vals[2],4)),0b00111111))
		buffer = buffer .. bytetostring(band(shr(vals[3],2),0b00111111))
	end
	return buffer
end

function round(fract)
	if fract-flr(fract)>=0.5 then return flr(fract)+1 end
	return flr(fract)
end

function totable(string)
			local buffer,c,t = "","",{}
	for i=1,#string do
		c,string = sub(string,1,1),sub(string,2)
		if c == "," then
			add(t,buffer) buffer = ""
		else
			buffer = buffer .. c
		end
	end
	return t
end


--credit to @felice
function oneach(table,method_name)
	for _,obj in pairs(table) do
		obj[method_name](obj)
	end
end


function initconversations(inputvar)
	local table,c,buffer,i,tableindex = {},"","",1,0
	local inputstring = inputvar
	while true do
		c = sub(inputstring,i,i)
		if c == "," then
		inputstring = sub(inputstring,i+1)
					i,buffer,tableindex = 1,"",buffer + 0
		table[tableindex] = {}			
		while true do
			c = sub(inputstring,i,i)
			if c == ";" then
				inputstring = sub(inputstring,i+1)
				add(table[tableindex],buffer)
				i,buffer = 0,""
			elseif c == "+" then
				buffer = buffer ..","
			elseif c == "," then
				i += 1
				break
			else
				buffer = buffer .. c
			end
			i += 1
		end
		elseif c == "" then
			break
		else
			buffer = buffer..c
			i += 1
		end
	end
		return table
end

function spawndresser()
	local obj = {}
		obj.x,obj.y,obj.w,obj.h,obj.colour,obj.xoff,obj.yoff,obj.knobx,obj.knobrad = 26,50,22,18,12,2,2,12,1
		obj.state = 0

	obj.update = function(self)
		if self.state == 1 then
			self.w += 0x0.2
			self.h += 0x0.2
			self.y -= 0x0.2
			if(self.w == 29) del(objects,self) spawndresser() sprites:tofront()
		elseif self.state == 4 then
			self.x += 0x0.4
		elseif self.state == 5 then
			self.x -= 0x0.8
		end
	end

	obj.draw = function(self)
	local x,y,w,h,xoff,yoff,knobx,knobrad = self.x,self.y,self.w,self.h,self.xoff,self.yoff,self.knobx,self.knobrad
		rect(x + xoff,y - yoff,x + w + xoff,y - yoff + h,self.colour)
				rectfill(x,y,x + w,y + h,0)
		rect(x,y,x + w,y + h,self.colour)
				line(x,y,x + xoff,y - yoff)
		line(x + w,y,x + xoff + w,y - yoff)
		line(x + w,y + h,x + xoff + w,y - yoff + h)
				circfill(x + knobx,y + 3,knobrad,self.colour)
		circfill(x + knobx,y + 9,knobrad)
		circfill(x + knobx,y + 15,knobrad)
		circfill(x + knobx,y + 3,knobrad - 1,0)
		circfill(x + knobx,y + 9,knobrad - 1)
		circfill(x + knobx,y + 15,knobrad - 1)
				line(x,y + 6,x + w,y + 6,self.colour)
		line(x,y + 12,x + w,y + 12)		
	end

	dresser = obj

		add(objects,obj)
end

function spawnwindow(state)
	local obj = {}
		obj.toppanex,obj.toppaney,obj.toppanew,obj.toppaneh = 51,27,25,11
	obj.bottompanex,obj.bottompaney,obj.bottompanew,obj.bottompaneh = 51,30,25,10
	obj.framex,obj.framey,obj.framew,obj.frameh = 51,27,25,21
	obj.colour = 12

		obj.state = state or 0
		obj.update = function(self)
		if(self.state==1) then 
			if(self.bottompaney < 37) self.bottompaney += 0x0.8
		elseif self.state == 2 then
			self.toppanex -= 0x1
			self.framex += 0x1
			self.bottompanex -= 0x0.4
			self.bottompanew += 0x0.8
			self.bottompaney -= 0x0.4
			self.bottompaneh += 0x0.4
			if (flr(self.bottompanex) == 17) del(objects,self) spawnwindow() sprites:tofront() window.bottompaney = 37
		elseif self.state == 3 then
			del(objects,self)
		end
	end

		obj.draw = function(self)
						rect(self.framex,self.framey,self.framex + self.framew,self.framey + self.frameh,self.colour)
				rect(self.toppanex,self.toppaney,self.toppanex + self.toppanew,self.toppaney + self.toppaneh)
		line(self.toppanex + round(self.toppanew /2),self.toppaney,self.toppanex + round(self.toppanew /2),self.toppaney + self.toppaneh)
				rect(self.bottompanex,self.bottompaney,self.bottompanex + self.bottompanew,self.bottompaney + self.bottompaneh)
		line(self.bottompanex + round(self.bottompanew /2),self.bottompaney,self.bottompanex + round(self.bottompanew /2),self.bottompaney + self.bottompaneh)

	end

	window = obj

		return add(objects,obj)	
end

function spawnwardrobe()
	local obj = {}
		obj.x,obj.y,obj.w,obj.h,obj.colour,obj.xoff,obj.yoff,obj.knobx,obj.knobrad,obj.timer = 88,17,17,50,12,-3,2,5,1,0
		obj.state = 0
		obj.update = function(self)
		if self.state == 1 then
			self.x += 0x0.1
			self.y += 0x0.1
			self.w -= 0x0.2
			self.h -= 0x0.2
			if (self.h == 25) del(objects, self) spawnwardrobe() sprites:tofront()
        elseif self.state == 2 then
            self.timer += 1
                        if(self.timer%4 == 0) self.knobx += rnd(2)
            if(self.timer == 120) del(objects,self) spawnwardrobe() sprites:tofront()
		elseif self.state == 4 then
			self.x += 0x0.4
		elseif self.state == 5 then
			self.x -= 0x0.8
		end
	end

		obj.draw = function(self)
				local x,y,w,h = self.x,self.y,self.w,self.h
						rect(x + self.xoff,y - self.yoff,x + w + self.xoff,y - self.yoff + h,self.colour)
				rectfill(x,y,x + w,y + h,0)
		rect(x,y,x + w,y + h,self.colour)
				line(x,y,x + self.xoff,y - self.yoff)
		line(x,y + h,x + self.xoff,y - self.yoff + self.h)
				circfill(x + self.knobx + 1,y + h /2 + 2,self.knobrad)
		circfill(x + w - self.knobx,y + h /2 + 2,self.knobrad)
		circfill(x + self.knobx + 1,y + h /2 + 2,self.knobrad - 1,0)
		circfill(x + w - self.knobx,y + h /2 + 2,self.knobrad - 1,0)
				line(x + round(w /2),y,x + round(w /2),y + h,self.colour)
	end

	wardrobe = obj

		add(objects,obj)	
end

function spawndoor(state)
	local obj = {}
		obj.corneronex,obj.corneroney = 7,39
	obj.cornertwox,obj.cornertwoy = 19,32
	obj.cornerthreex,obj.cornerthreey = 19,68
	obj.cornerfourx,obj.cornerfoury = 7,80
	obj.handlex,obj.handley,obj.handlelength = 15,57,4
	obj.hasntparent= true

	obj.colour = 12
		obj.state = state or 0
		obj.update = function(self)
		if self.state == 4 then
			del(objects,self)
		elseif self.state == 7 then
						if(self.handley < 59) self.handley += 0x0.4
			if(self.handlex < 16) self.handlex += 0x0.1
			if(self.handlex >= 16 and self.handley >= 59) self.state = 8
		elseif self.state == 8 then
			if(self.handley < 65) self.handley += 0x0.4
			if(self.handlex > 15) self.handlex -= 0x0.1
			if(self.cornertwox < 20) self.cornertwox += 0x0.1
			if(self.cornertwoy < 42) self.cornertwoy += 0x0.4
			if(self.cornerthreex < 20) self.cornerthreex += 0x0.1
			if(self.cornerthreey < 84) self.cornerthreey += 0x0.6
			if(self.cornerthreey >= 84) self.state = 11
		elseif self.state == 11 then
		elseif self.state == 9 then
			self.child = spawndoor(7)
			door = self
			self.child.hasntparent = false
			self.state = 10
		elseif self.state == 10 then
		end
	end

		obj.draw = function(self)
						if(not self.hasntparent) rectfill(self.corneronex,self.corneroney+3,self.cornerthreex,self.cornerthreey,0)
		if(self.hasntparent) rectfill(0,80,7,39,0)
		line(self.corneronex,self.corneroney,self.cornertwox,self.cornertwoy,self.colour)
		line(self.corneronex,self.corneroney,self.cornerfourx,self.cornerfoury)
		line(self.cornerthreex,self.cornerthreey,self.cornerfourx,self.cornerfoury)
		line(self.cornerthreex,self.cornerthreey,self.cornertwox,self.cornertwoy)
				if(self.state < 8)line(obj.cornertwox,obj.cornertwoy + round(0x0.5*obj.cornerthreey),self.handlex,self.handley)
		if(self.state == 8)line(obj.cornertwox,obj.cornertwoy + round(0x0.45*obj.cornerthreey),self.handlex,self.handley)
				if(self.state == 11)line(obj.cornertwox,obj.cornertwoy + round(0x0.4*obj.cornerthreey),self.handlex,self.handley)


	end

	door = obj

		return add(objects,obj)	
end

function spawnroom()
	local obj = {}
		obj.backwallx,obj.backwally,obj.backwallw,obj.backwallh,obj.c1y,obj.c2y,obj.c3y,obj.c4y = 23,-1,83,65,10,9,87,87

	obj.colour = 12
		obj.state = 0
		obj.update = function(self)
		if self.state == 4 then
			self.backwallx += 0x0.5
			if(flr(self.backwallx)==56) self.state = 5 wardrobe.state = 5 dresser.state = 5 
		elseif self.state == 5 then
			self.backwallx -= 0x0.a
			if (flr(self.backwallx) == -50) del(objects,self) del(objects,wardrobe) del(objects,dresser) spawnroom() spawnwardrobe() spawndresser() spawndoor() local temp = spawnwindow(1) temp.bottompaney=37 sprites:tofront()
		end
	end

		obj.draw = function(self)
						rect(self.backwallx,self.backwally,self.backwallx + self.backwallw,self.backwally + self.backwallh, self.colour)
				line(self.backwallx,self.backwally,0,self.c1y)
		line(self.backwallx + self.backwallw,self.backwally,128,self.c2y)
		line(self.backwallx,self.backwally + self.backwallh,0,self.c3y)
		line(self.backwallx + self.backwallw,self.backwally + self.backwallh,128,self.c4y)
	end

	room = obj

		add(objects,obj)
end

function spawnspiritboard()
	local obj = {}
	obj.trigdivider,obj.triginc = 28,2
	obj.yesstr,obj.nostr,obj.goodstr,obj.byestr = "yes","no","good","evil"

	obj.colour = 12
	obj.state = 0
	obj.update = function(self)
		if(self.trigdivider == 240 or self.trigdivider ==28) self.triginc = -self.triginc
	end

	obj.getindex = function(self,letter)
		local alpha,bet,a,b = "abcdefghijklm ","nopqrstuvwxyz "		
		for i=1,14 do
			if (sub(alpha,i,i) == letter) a = i
			if (sub(bet,i,i) == letter) b = i
		end
		return a,b
	end

	obj.draw = function(self)
		local alpha = "abcdefghijklm"
		local bet = "nopqrstuvwxyz"
		line(0,88,128,88,8)
		local j,inc = 0,1
		for i=1,13 do
			if(j == 7) inc = -1
			j += inc
			print(sub(alpha,i,i),4+8*i,104 + round(13*sin((j)/self.trigdivider)),12)
			print(sub(bet,i,i),4+8*i,108 - round(13*sin((j)/self.trigdivider)),12)
		end
		print(self.yesstr,8,91)
		print(self.nostr,119-4*#self.nostr,91)
		print(self.goodstr,8,120)
		print(self.byestr,119-4*#self.byestr,120)

		if(self.state == 1) sspr(42,48,14,8,99,103,29,25)

	end

	spiritboard = obj

	add(objects,obj)
end

function spawnplanchetletter(x,y,tx,ty,letter,parent)
			local obj = {}
	obj.timer,obj.x,obj.y,obj.parent,obj.state,obj.letter = 0,x,y,parent,0,letter
	local xdist,ydist = tx-x,ty-y
		obj.dx = xdist/30
	obj.dy = ydist/30
	obj.update = function(self)
		self.timer += 1
		self.x += self.dx
		self.y += self.dy
		if (self.timer== 30) del(objects,self) self.parent.displaystring = self.parent.displaystring .. self.letter
	end

	obj.draw = function(self)
		print(self.letter,self.x,self.y,8)
	end

	add(objects,obj)
end

function spawnplanchet()
	local obj = {}
	obj.x,obj.y,obj.dx,obj.dy,obj.targetx,obj.targety,obj.printstr,obj.timer,obj.displaystring,obj.trigtimer,obj.line,obj.incrementedline,obj.nbtf = 55,102,0,0,55,102,"",0,"",0,0,true,true

	obj.state = 0



	obj.print = function(self,str)
		if(self.nbtf) del(objects,self) add(objects,self)
		if (#str == 0) self.state,self.timer,gamestate,self.line,self.nbtf = 3,0,1,0,true playconversation(questionnumber) return
		self.printstr = str
		self.state = 1
		local a,b = spiritboard:getindex(sub(str,1,1))
		local c,d = a,b
		if a==nil then
			if (b>=7) d = d - 13 
			self.targetx,self.targety = 8*b,104 - round(13*sin((b)/spiritboard.trigdivider))
		else
			if (a>=7) c = c - 13 
			self.targetx,self.targety = 8*a,100 + round(13*sin((a)/spiritboard.trigdivider))
						if(a==14) self.targetx,self.targety = 55,102
		end
		local xdist,ydist = self.x-self.targetx,self.y-self.targety
		self.goaldir = atan2(xdist,ydist)
		self.dx = -2*cos(self.goaldir)
		self.dy = -2*sin(self.goaldir)
	end

		obj.update = function(self)
				self.trigtimer = (self.trigtimer+1)%30
				if self.state == 0 then
				elseif self.state == 1 then
						self.x += self.dx
			self.y += self.dy
									if abs(self.x-self.targetx) <= abs(self.dx)+0x2.f and abs(self.y-self.targety) <= abs(self.dy)+0x2.f then
				self.state = 2
				self.timer = 0
				self.x,self.y = self.targetx,self.targety
			end
				elseif self.state == 2 then
			self.timer +=1
						if(#self.displaystring%21==0 and not #self.displaystring == 0 and self.notincrementedline) self.line+=1 self.notincrementedline = false
						if(self.timer == 10) spawnplanchetletter(self.x,self.y,24+(4*(#self.displaystring))%84,self.line*9+7+2*sin((#self.displaystring*2+self.trigtimer)/15),sub(self.printstr,1,1),self) self:print(sub(self.printstr,2)) self.notincrementedline = true
				elseif self.state == 3 then
			self.timer += 1
			if(self.timer == 90) self.displaystring = ""
		end
	end

	obj.draw = function(self)
		sspr(112,27,11,11,self.x,self.y)
		if #self.displaystring>0 then
			rectfill(27,7,27+4*#self.displaystring,7+6,0)
			if(#self.displaystring-21 > 0) rectfill(27,16,27+4*(#self.displaystring-21),22,0)
			if(#self.displaystring-42 > 0) rectfill(27,16,27+4*(#self.displaystring-21),22,0)
			j = 0
			for i=1,#self.displaystring do
				print(sub(self.displaystring,i,i),24+4*(i-1)%84,j*9+7+2*sin((i*2+self.trigtimer)/15),8)
				if(i%21==0) j += 1
			end
		end
	end

	planchet = obj

	return add(objects,obj)
end

function spawnstaticsprites()
	local obj = {}

	obj.tofront = function(self)
		del(objects,self)
		spawnstaticsprites()
	end

	obj.update = function(self)
	end
	
	obj.draw = function(self)
		sspr(42,24,16,24,37,58)
		sspr(58,24,16,24,56,48)
		sspr(74,24,16,32,76,49)
		sspr(58,48,16,8,56,72)
	end

	sprites = add(objects,obj)
end

function initializeroomobjects()
		spawnroom()
	spawndresser()
	spawnwardrobe()
	spawnwindow()
	spawndoor(0)
	spawnspiritboard()
	spawnplanchet()
	spawnstaticsprites()
end

function spawntitlescreen()
		local obj = {}
	obj.timer,obj.child = 0,fakeplanchetprint("spiritboard")
	trackervarinit()

	obj.update = function(self)
		self.timer += 1
		if btnp(4) or btnp(5) then
			del(objects,self)
			del(objects,self.child)
			initializeroomobjects()
			playconversation(1000)
		end
	end

	obj.draw = function(self)
		sspr(109,38,19,17,46+3*sin(self.timer/15),54+3*cos(self.timer/15),42,42)
		print("press â— to play",33,107,8)
		print("text speed options in menu",12,123)
		print("by @capnmarcy",38,36)
	end

	add(objects,obj)
end

function spawngameendscreen()
	local obj = {}
	

	obj.update = function(self)
		if btnp(4) or btnp(5) then
			objects = {}
			spawntitlescreen()
		end
	end

	obj.draw = function(self)
	print("thank you for playing!",22,20,8)
	print("press x to play",33,105)
	print("to see more conversations",14,112)
	print("try story toggle in the menu",8,119)
	end

	add(objects,obj)
end

function textspeed(speed)
	scrollspeed = speed
end

function trackervarinit()
	questionstate,spookystate,questionsanswered,randsused,timer,gamestate = 0,0,0,{},0,0
end

function initpausemenu()
		menuitem(1,"text spd: fast",function() scrollspeed = 1 end)
	menuitem(2,"text spd: medium",function() scrollspeed = 2 end)
	menuitem(3,"restart no intro cutscene",function() objects = {} initializeroomobjects() trackervarinit() questionmenu() texttriggers(17) end)
	menuitem(4,"restart with cutscene",function() objects = {} spawntitlescreen() end)
	menuitem(5,"togglestory",function() if gamemode== 0 then gamemode = 1 else gamemode = 0 end end)
end


function _init()
	palt(0,false)
	palt(15,true)
	cls(1)
	print("loading...",1,123,2)
	conversations = conversations .. frommemory(0x42d5,0x0dff)
	conversations = initconversations(conversations)
	questionanswertable = initconversations(questionanswertable)
	questionmenustr,namemenustr,adjectivemenustr = totable(questionmenustr),totable(namemenustr),totable(adjectivemenustr)
	initpausemenu()
	spawntitlescreen()
end


function clock()
	timer += 1
	timer = timer%32000
end

function questionmenu(state)
		local obj = {}
	obj.state,obj.timer,obj.cursorx,obj.cursory,obj.offset,questionnumber,obj.outstring,obj.question,obj.trigtimer = state or 0,0,0,0,-40,0,"",0,0

	obj.update = function(self)
		self.trigtimer = (self.trigtimer + 1)%30
						if btnp(0) then
			self.cursorx -= 1
				elseif btnp(1) then
			self.cursorx += 1
				elseif btnp(2) then
			self.cursory -= 1
				elseif btnp(3) then
			self.cursory += 1
			
		end
				if(self.state == 0) self.cursorx = self.cursorx%1
		if(self.state == 0) self.cursory = self.cursory%2
				if(self.state == 1 or self.state == 2) self.cursorx = self.cursorx%2
		if(self.state == 1 or self.state == 2) self.cursory = self.cursory%4
				if(self.state > 2) self.cursory = self.cursory%1 self.cursorx = self.cursorx%1
				if(not(self.offset == 0)) self.offset += 2
				if(btnp(4) and self.state < 60) then
			if self.state == 0 then
				self.question,self.state,self.outstring = self.cursory,1,sub(questionmenustr[self.cursory+1],1,5)
				questionnumber += self.cursory+1
			elseif self.state == 1 then
				local menuindex = self.cursory+self.cursorx*4+1
				questionnumber *= 10
				questionnumber += menuindex
				local name = namemenustr[menuindex]
				if(menuindex == 8) name = stat(4)
								if #self.outstring < 6 then
	
					if self.question == 0 then
						self.outstring = self.outstring .. name .. " like "
					elseif self.question == 1 then
						self.outstring = self.outstring .. name .. " be "
						self.state = 2
					elseif self.question == 2 then
						self.outstring = self.outstring .. name
						self.state = 69
					else
						self.outstring = self.outstring .. name .. " "
						self.state = 2
					end
												else
										self.outstring = self.outstring .. name .. "?"
					if(questionstate == 3) questionstate += 1
					self.state = 69
				end
						elseif self.state == 2 then
				local menuindex = self.cursory+self.cursorx*4+1
				questionnumber *= 10
				questionnumber += menuindex
				self.outstring = self.outstring .. adjectivemenustr[menuindex]
				self.state = 69
			elseif self.state > 2 then
				questionnumber = self.state
				if self.state == 3 then
					self.outstring = "what kills "
					self.state = 1
				elseif self.state > 3 then
					questionnumber = self.state
					self.outstring = questionmenustr[self.state]
					self.state = 69
					questionstate += 1
				end
			end
		elseif(btnp(5) and self.state < 60) then
			del(objects,self)
			local temp = questionmenu(questionstate)
			temp.offset = 0
		end

				if self.state > 8 then
			self.timer += 1
			self.offset -= 4
			if (self.timer == 60) then
				del(objects,self)
				gamestate = 3
				pickedquestionnumber = questionnumber
				if(questionanswertable[questionnumber] == nil) planchet:print(randanswer()) return
				if(questionanswertable[questionnumber][1] == nil) planchet:print(randanswer()) return
				if(questionanswertable[questionnumber][1] == "neg") planchet:print(randneg()) return
				if(questionanswertable[questionnumber][1] == "pos") planchet:print(randpos()) return
				planchet:print(questionanswertable[questionnumber][1])
			end
		end

	end

	obj.draw = function(self)
				for i=1,#self.outstring do
			print(sub(self.outstring,i,i),27+4*(i-1),7+2*sin((i*2+self.trigtimer)/15),12)
		end
		camera(0,self.offset)
		rectfill(0,88,128,128,0)
		rect(1,88,127,127,12)
		if self.state == 0 then
			for i=1,2 do
				print(questionmenustr[i],5,84+i*8,12)
			end
			rect(2,self.cursory*8+90,87,self.cursory*8+98,12)
		elseif self.state == 1 then
			for i=1,4 do
				print(namemenustr[i],16,84+i*8,12)
				print(namemenustr[i+4],80,84+i*8,12)
			end
			if(self.cursorx == 0) rect(14,self.cursory*8+90,50,self.cursory*8+98,12)
			if(self.cursorx == 1) rect(78,self.cursory*8+90,110,self.cursory*8+98,12)
		elseif self.state == 2 then
			for i=1,4 do
				print(adjectivemenustr[i],16,84+i*8,12)
				print(adjectivemenustr[i+4],80,84+i*8,12)
			end
			if(self.cursorx == 0) rect(14,self.cursory*8+90,50,self.cursory*8+98,12)
			if(self.cursorx == 1) rect(78,self.cursory*8+90,110,self.cursory*8+98,12)
		elseif self.state > 2 and self.state < 9 then
			print(questionmenustr[self.state],5,92,12)
			rect(2,self.cursory*8+90,110,self.cursory*8+98,12)
		end
		camera()
	end

	return add(objects,obj)
end

function playconversation(convnumber)
	local obj = {}
	obj.conv = conversations[convnumber] or randanswer()
	obj.linefinished,obj.spr,obj.state,obj.timer,obj.index,obj.namelist = true,0,0,0,1,totable("jay,sam,gem,phone,molly,")

	obj.update = function(self)
		if(self.index > #self.conv and self.linefinished) self.state = 2
		if self.linefinished and self.state == 0 then
			local convstr,name = sub(self.conv[self.index],4),sub(self.conv[self.index],1,3)
			if name == "jay" then
				self.spr = 0
			elseif name == "sam" then
				self.spr = 1
			elseif name == "gem" then
				self.spr = 2
			elseif name == "phn" then
				self.spr = 3
			elseif name == "mol" then
				self.spr = 4
			end
			emoprint(convstr,self)
			self.linefinished = false
			self.index += 1
		elseif self.state == 1 then
						self.timer += 1
			if (self.timer == 90) then
				self.timer = 0
				self.state,self.linefinished = 0,true
			end
		elseif self.state == 2 then
			self.timer += 1
			if self.timer == 80 then
				gamestate = 2
				if spookystate == 0 then
					if(gamemode==0)questionsanswered += 1
					if(questionsanswered%2 == 0)texttriggers(questionsanswered)
				else
					questionsanswered += 1
				end
				if not (questionsanswered == 10) then 
					questionmenu(questionstate)
				end
				del(objects,self)
				return
			end
		end

	end

	obj.draw = function(self)
		if (self.state == 2) camera(0,-self.timer*0x1.a)
		rectfill(0,89,128,128,0)
		rectfill(0,91,29,120,12)
		rectfill(1,92,28,119,0)
		rectfill(2,93,27,118,8)
		sspr(self.spr*24,0,24,24,3,94)
		if spookysprites then
			if self.spr == 0 then
				rectfill(11,113,20,117,0)
				line(12,116,12,117,12)
				line(13,115,13,116)
				line(13,115,17,115)
				line(17,115,17,116)
				line(18,116,18,117)
			elseif self.spr == 1 then
				rectfill(9,111,16,116,0)
				line(13,113,17,113,12)
			elseif self.spr == 2 then
				rectfill(11,111,21,114,0)
				line(14,113,16,113,12)
			end
		end
		local name = self.namelist[self.spr+1]
		print(name,14-#name*2,122,12)
		camera()
	end

	add(objects,obj)
end

function randanswer()
		if(rnd(1)>0.5) then
		return randpos()
	else
		return randneg()
	end
end

function randpos()
		questionnumber = 3000
	return randomqn()
end

function randneg()
		questionnumber = 3020
	return randomqn()
end

function randomqn()
			local randindex = flr(rnd(10)+0.125)
		while(69) do
		if (not((randsused[randindex] or 0) == 1)) randsused[randindex] = 1 break
		randindex = flr(rnd(10+1))
	end
		questionnumber += randindex
			if(gamestate == 3) questionanswertable[pickedquestionnumber] = questionanswertable[questionnumber] return questionanswertable[questionnumber][1]
	if(gamestate == 1) conversations[pickedquestionnumber] = conversations[questionnumber] return conversations[questionnumber]
end

function emoprint(str,parent)
	local obj = {}
		obj.x,obj.y,obj.delay,obj.colour,obj.strtoprint,obj.charsprinted,obj.children,obj.parent,obj.charsonline = 32,91,scrollspeed,12,str,0,{},parent,0

	obj.checkforspace = function(self,charsreq)
		if (self.charsonline+charsreq) > 23 then
			self.charsonline = 0
			self.y += 6
		end
	end

	obj.printbuffer = function(self,buffer)
		add(self.children,standardprint(buffer,self))
			end

	obj.findtag = function(self,buffer,tag)
		local index = 1
						self.strtoprint = sub(self.strtoprint,3)
		while true do
						if (sub(self.strtoprint,index,index+1) == tag) break
						buffer = buffer .. sub(self.strtoprint,index,index)
			index += 1
		end
		return buffer
	end

	obj.checkifchildprinting = function(self)
		if(self.children[#self.children].state == 2) return false
		return true
	end

	obj.update = function(self)
		local buffer,i,printablenotfound = "",1,true
				if #self.children == 0 or (self.children[#self.children].state == 2) then
									while printablenotfound do
								local flagcheck = sub(self.strtoprint,i,i+1)
								if flagcheck == "$w" then
										if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$w")
										self:checkforspace(#buffer)
					add(self.children,wobbleprint(buffer,self))
					self.strtoprint = sub(self.strtoprint,#buffer+3)
					self.charsonline += #buffer
					break
				elseif flagcheck == "$s" then
										if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$s")
										self:checkforspace(#buffer)
					add(self.children,shakeprint(buffer,self))
					self.strtoprint = sub(self.strtoprint,#buffer+3)
					self.charsonline += #buffer+2
					break
				elseif flagcheck == "$b" then
										if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$b")
										self:checkforspace(#buffer)
					add(self.children,bloodprint(buffer,self))
					self.strtoprint = sub(self.strtoprint,#buffer+3)
					self.charsonline += #buffer
					break
				elseif flagcheck == "$d" then
															if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$d")
										local specialdelay,buffer = sub(buffer,1,2),sub(buffer,3)
										self:checkforspace(#buffer)
					add(self.children,standardprint(buffer,self))
					self.children[#self.children].delay = specialdelay+0
					self.strtoprint = sub(self.strtoprint,#buffer+5)
										break
				elseif flagcheck == "$c" then
															if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$c")
										local specialcolour,buffer = sub(buffer,1,2),sub(buffer,3)
										self:checkforspace(#buffer)
					add(self.children,standardprint(buffer,self))
					self.children[#self.children].colour = specialcolour+0
					self.strtoprint = sub(self.strtoprint,#buffer+5)
					break
				elseif flagcheck == "$p" then
										if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$p")
															add(self.children,fakeplanchetprint(buffer,self))
					self.strtoprint = sub(self.strtoprint,#buffer+3)
										break
				elseif flagcheck == "$$" then
					if (#buffer > 0) self:printbuffer(buffer) printablenotfound = false break
					buffer = self:findtag(buffer,"$$")
					texttriggers(0+buffer)
					self.strtoprint = sub(self.strtoprint,5)
					break
				else
					buffer,self.strtoprint = buffer .. sub(self.strtoprint,i,i),sub(self.strtoprint,i+1)
					if #self.strtoprint == 0 then
						if(#buffer>0) add(self.children,standardprint(buffer,self)) break
						for c in all(self.children) do
							c.timer,c.state,c.delay = 0,1,90
						end
						self.parent.state = 1
						del(objects,self)
						break
					end
				end
			end
		end
	end

	obj.draw = function(self)
	end

	add(objects,obj)
end

function createprintobject(parent)
	local obj = {}
	obj.timer,obj.state,obj.printedstr = 0,0,"",false


	obj.commonupdate = function(self)
		self.timer +=1
				 		if self.timer >= self.delay then			
		self.timer = 0
			if self.state == 0 then
				self.printedstr,self.strtoprint = self.printedstr .. sub(self.strtoprint,1,1),sub(self.strtoprint,2)
				if(#self.strtoprint == 0) then
					self.state = 2
					self.timer = 0
					self.delay = 90
				end
			elseif self.state == 1 then
				del(objects,self)
			end
		end
	end

	return obj
end

function standardprint(str,parent)
	local obj = createprintobject()
	obj.parent = parent
	obj.x,obj.y,obj.delay,obj.strtoprint,obj.colour,obj.lineoffset,obj.nothadchild = parent.x,parent.y,parent.delay,str,parent.colour,parent.charsonline,true
	if(not( #str + obj.lineoffset > 23)) parent.charsonline += #str

	obj.update = function(self)
		self:commonupdate()
		if(#self.printedstr+self.lineoffset == 24 and self.nothadchild) self.parent.charsonline,self.nothadchild = 0,false self.parent.y += 6 add(self.parent.children,standardprint(self.strtoprint,self.parent)) self:commonupdate()
	end

	obj.draw = function(self)
				print(self.printedstr,self.x+self.lineoffset*4,self.y,self.colour)
	end

	add(objects,obj)
	return obj
end

function shakeprint(str,parent)
	local obj = wobbleprint(str,parent)

	obj.draw = function(self)
		rectfill(self.x,self.y-1,self.x+5*#self.printedstr,self.y+5,0)
		for i=1,#self.printedstr do
			print(sub(self.printedstr,i,i),self.x+5*(i-1)+sin((i*2+self.trigtimer)/6),self.y,self.colour)
		end
	end
	return obj
end

function wobbleprint(str,parent)
	local obj = createprintobject()

	obj.parent = parent
	obj.x,obj.y,obj.delay,obj.strtoprint,obj.trigtimer,obj.colour = parent.x+4*parent.charsonline,parent.y,parent.delay,str,0,parent.colour


	obj.update = function(self)
		self.trigtimer += 1
		if (self.trigtimer == 30) self.trigtimer = 0
		self:commonupdate()
	end

	obj.draw = function(self)
		rectfill(self.x,self.y-1,self.x+4*#self.printedstr,self.y+5,0)
		for i=1,#self.printedstr do
			print(sub(self.printedstr,i,i),self.x+4*(i-1),self.y+2*sin((i*2+self.trigtimer)/15),self.colour)
		end
	end

	add(objects,obj)
	return obj
end

function bloodprint(str,parent)
	local obj = createprintobject()
	obj.parent = parent
	obj.x,obj.y,obj.delay,obj.strtoprint,obj.bloodtimer,obj.colour,obj.blooddrips = parent.x+4*parent.charsonline,parent.y,parent.delay,str,0,parent.colour,1

	obj.update = function(self)
		self.bloodtimer += 1
		if (self.bloodtimer == 40) self.bloodtimer = 0 self.blooddrips += 1
		self:commonupdate()
	end

	obj.draw = function(self)
		rectfill(self.x,self.y-1,self.x+4*#self.printedstr,self.y+5,0)
		for i=1,self.blooddrips do
			print(self.printedstr,self.x,self.y+i,8)
		end
		print(self.printedstr,self.x,self.y,self.colour)
	end
	add(objects,obj)
	return obj
end

function fakeplanchetprint(str,parent)
	local obj = createprintobject()
	obj.delay,obj.strtoprint,obj.displaystring,obj.trigtimer = 5,str,"",0

	obj.initx = 64 - #str*2


	obj.update = function(self)
		self:commonupdate()
		self.trigtimer = (self.trigtimer+1)%30
		if #self.printedstr > 0 then
			spawnplanchetletter(64,138,self.initx+4*(#self.displaystring),7+2*sin((#self.displaystring*2+self.trigtimer)/15),self.printedstr,self)
			self.printedstr = ""
		end
	end

	obj.draw = function(self)
		if #self.displaystring>0 then
			rectfill(27,7,27+4*#self.displaystring,7+6,0)
			for i=1,#self.displaystring do
				print(sub(self.displaystring,i,i),self.initx+4*(i-1),7+2*sin((i*2+self.trigtimer)/15),8)
			end
		end
	end

	add(objects,obj)
	return obj
end

function texttriggers(trigger)
	if trigger == 41 then
			spookysprites = false
		del(objects,door)
		spawnmolly()		
		spawndoor(7)
	elseif trigger == 01 then
				spiritboard.state = 1
		sset(28,29,8)
		sset(28,30)
		sset(29,29)
		sset(30,28)
		sset(30,29)
		sset(30,30)
	elseif trigger == 17 then
				window.state = 1
	elseif trigger == 69 then
		objects = {}
		spawngameendscreen()
	elseif trigger == 2 then
				wardrobe.state = 1
	elseif trigger == 4 then
		dresser.state = 1
	elseif trigger == 6 then
		wardrobe.state = 2
	elseif trigger == 8 then
		window.state = 2
	elseif trigger == 10 then
		wardrobe.state = 4
		dresser.state = 4
		window.state = 3
		room.state = 4
		door.state = 4
		spookystate = 1
		questionstate = 3
		spookysprites = true
		playconversation(2000)
	elseif trigger == 87 then
		questionsanswered += 1
	end
end

function spawnmolly()
	local obj = {}
	obj.timer,obj.sprite,obj.x,obj.y,obj.state = 0,0,0,39,0

	obj.update = function(self)
		self.timer += 1
		if self.state == 0 then
			if(self.x<20) self.x += 0x0.4
			if(self.x==20 and self.sprite==0) self.state = 1
			if(self.timer==10) self.timer = 0 self.sprite = (self.sprite+1)%3
		elseif self.state == 1 then
		end
	end

	obj.draw = function(self)
		clip(21,38,15,47)
		sspr(self.sprite*14,24,14,32,self.x,self.y)
		sspr(95,24+self.sprite*10,14,10,self.x,self.y+32)
		clip()
	end

	add(objects,obj)
end

function _update( ... )
		clock()
		oneach(objects,"update") 
end


function _draw( ... )
	cls()
	oneach(objects,"draw")
	cursor()
end











__gfx__
0000000ccccccccccc000000888888888888888888888888000cccccccccccccccc000000cccccccccccccc0000000c000000000000c00ccccccc00000000fff
000cccc0cccccccc0c00000088888888888888888888888800ccccccccccccccccccc0000c0ccccccccccc00000000c000000000000c0cccc0000c0000000fff
00cc00ccccccccccccc000008888880880000000008880880ccccccccccccccccccccc000c00000000000000000000c000000000cccc0ccccccc00c000000fff
cc0cccccccccccccc0c000008880088880000000008088880cccccccccc0ccccccccccc00c0000000ccccccccccc00c000000ccc0c000ccccc0ccccc00000fff
cccccccc0cccc0cccccc00008088088080000000008088880cccccccccc0cc00cccccccccc00000cccccccccccccccc0000cc0c0c00000cc0cc0cccc00000fff
cc0cccc0ccc0cccc000ccc008008888808000000008008880ccccccccc00cc000ccccccccc0000ccc0000000000cccc000cc0c0c000000c0cccccccc00000fff
0ccc0cccccc0cccc000000c08008008888800000008008880cccccccc000cc000ccccccccc0000ccccccccccccccccc0ccc0c0000000000cc0c0cc0c00000fff
ccccccc0cc0ccc000000000c8800800888800000008000880ccccccc000ccc00cccccccccc00000cc0000000000cccc00c0c00000000000cc0cc0c0000000fff
ccc00ccc00ccc0000000000088808cc800880000ccc80088cc0ccc00000cc00ccccc000c0c0000000ccccccccccc00c0c0c000000000000c0c0c0cc000000fff
cc0c0cc00000000000000000808c88c88c0800ccccc8cc88c00ccccc0000000000cccc000c00000000000000000000c00c00000000000000cc0c00c000000fff
0000cccc0000000000cccc0000ccc0008c0800cc0008cc08c0cccccccc000000cccccccc0c00cccccccc0000000000c0c000000000000000cc0c000c00000fff
00cccccccc000000ccccccc000ccc000880000cc0008cc08c0cccc00cc000c00cc00cccc0ccccccccccccc00000000c0000cccc000000000cc0ccccc00000fff
00cccc00cc000000cc00ccc000ccc000cc0000cc0008cc08c0cccc00cc00cc00cc00cccc0ccc00000000ccc0000000c00ccc000cc0000000cccc00cc00000fff
00cccc00cc000000cc00ccc00000cccc00000000ccc8000800cccc00cc00cc00cc00cccc0ccccccccccccc00000000c00ccc000cc0000000ccc000cc00000fff
00cccc00cc000c00cc00ccc0000000000000c000000080080000cccc0000cc0000cccc000c00cccccccc0000000000c00ccc000cc0000000ccc000cc00000fff
0000cccc0000cc0000cccc0000000000000cc000000080080000000000000c00000000000c00000000000000000000c0000cccc00000c000000cccc000000fff
000800000000cc000800000000000000000cc000000080080000000000000000000000000c0000000cccccccccccccc000000000000cc0000000000000000fff
000808080000cc0008080880000000c0000000000000800800000000000000ccccc000000c000000ccccccccccccccc000080800000cc0000008080000000fff
0000888800000c0008888000000000cc0000000000008008c000000000000cc0cc0000000c000000c0000000000000c000808080000000000080808000000fff
000000800000000000800000c0000000cc000000000080c8cc00000000ccc00cc000000ccc0000000cccccccccccccc000000000000000000000000000000fff
00000000000000000c0000000c00000000ccc000000008080cc00000000ccccc000000cccc00000000000000000000c00000000000000000ccc0000000000fff
000000000000000cc000000080cc000000000000000cc8000cccc000000000000000cccccc000000ccccccccccccc0c0cc0000000ccccccc0000000c00000fff
cc0000000ccccccc0000000c8000ccc000000000ccc008000cc0cccc000000000ccc0ccc0c00000cc00000000000ccc000c0000000000000000000c000000fff
00c00000000cccc0000000c08000000ccccccccc000008000cc00000ccccccccc0000cc00c000000ccccccccccccc0c0000cc000000000000000cc00ffffffff
fffffcfcfffffffffffc0cfffffffffffc0cfffffffffff00000fffffffffff88888ffffffffffffff0000ffffffff0ffffc0000cfffffffffffffffffffffff
ffffc0c0ccffffffffc0c0ccffffffffc0c0ccffffffff000000f000fffffff888888fffffffffffff00000fffff8f0ffffcc0000cffffffffffffffffffffff
ffffccccc0cfffffffccccc0cfffffffccccc0cffffff0000cccf000fffff88880888fffffffffffffcccc00fff88f0fffffc0000cffffffffffffffffffffff
ffffcc0cccffffffffcc0cccffffffffcc0cccffffff0000ccccc000fffff8c8c0c888ffffffffffffc0ccc0fffc0f0fffffc000cfffffff8fffffffff8fffff
fffcc0c0c0cffffffcc0c0c0cffffffcc0c0c0cffff00cc8cccc0c00ff0ff8c8000088fffffffffffc0c0cccffc0cc0fffffc000cfffffff88fffffff88fffff
fffc0c0c0ccffffffc0c0c0ccffffffc0c0c0ccfff008cc8ccc0cc000f0f8888000088fffffffffffc000cccffcccc0fffffcccccffffffff888888888ffffff
fffcc0cc00cffffffcc0cc00cffffffcc0cc00cfff08ccc8cc000c00ff0f8888000c88fffffffffffc000cccfccccc0fffffc00cffffffffff888f888fffffff
fffc000c00cffffffc000c00cffffffc000c00cfff088ccfc0000c00ff0f8880ccc0888fffffffffffc000cccffccf0ffffcc000cfffffffff88fff88fffffff
ffffcc000cffffffffcc000cffffffffcc000cfffff088ffc000c000ff0f888ccccc088ffffffffffffcccffffffff0ffffc0cc0ccfff000ff88fff88fffffff
ffffffcccfffffffffffcccfffffffffffcccffffffffff00ccc0000ff0fc880c00cc88cfffffffffcc0cccccfffff0ffffcc00ccccff000ff8fffff8f0fffff
ffffffc0cfffffffffffc0cfffffffffffc0cfffffffff00c00c0000ff0c0000cc0c0000cfffffffc0c00cccffffff0ffffccc00000cc000fff8fff8ff0fffff
ffffcccccfffffffffcccccfffffffffcccccfffffffff0c0000c000ff0c00000ccc0000cfffffffc00ccc00cfffff0ffffc00c00000c000fff8fff8ff0fffff
fffccc000cfffffffccc000cfffffffccc000cffffffff0cccccc000ff0cc0c000c00000cfffffffc0000cc0cfffff0ffffc0cc0000cc000ffff888fff0fffff
fffc0c000ccffffffc0c000ccffffffc0c000ccfffffffcc0000c000ff0cccc000000c00c0ff00fc00000ccccfffff0ffffccc000cccf000fffff8ffff0fffff
fffc0c000cccfffffc0c000cccfffffc0c000cccffffffc0000c0000ff0c00c000000cccc0ff00c00000cc00c0ffff0ffffcc00cccfff00000088880ffffffff
fffccc00c00cfffffccc00c00cfffffccc00c00cffffffc0000cffffff0c00c000000c00c0ff00c00000c000c0ffff0ffffcc00ccffff00000088888ffffffff
fffcccccc0ccfffffcccccc0ccfffffcccccc0ccffffffc0000cffffff0c00cccccccc00c0ff00fc0000c000c0ffff0ffffccccffffff000008888008fffffff
ffc0c000cccfffffc0c000cccfffffc0c000cccfffffffc0cccccfffff0c00c000000c00c0ffffffc000c000c0ffff0fffcccccffffff000008008008fff8fff
ffc0c000cfffffffc0c000cfffffffc0c000cfffffffffccc000ccccff0c0cc0ccccccc0c0ffffffc000c000c0ffff0fffc0ccccfffff000008008008fff8fff
ffc0c000cfffffffc0c000cfffffffc0c000cffffffffccccc00000ccf0fcfccccc00cfcffffffffc00cc000c0ffff0fffcc00cccffff000008888888fff888f
ffc0c000ccffffffc0c000ccffffffc0c000ccfffffccc0000000000cc0fffc00cc00cffffffffffc00c000ccfffff0ffffcc0000cfff888808000088888888f
ffc0c000ccffffffc0c000ccffffffc0c000ccffffc00ccccccccccccf0fffc00cc00cffffffffffc00c000ccfffff0ffffcc0000cfff888888000088888888f
fc00c000ccfffffc00c000ccfffffc00c000ccffffccccffffffffffff0fffc00cc00cffffffffcccccc00cccfffff0ffffcc0000cfff8888888888888888880
fccccc0cccfffffccccc0cccfffffccccc0cccffffffffffffffffffff0ffffccffccffffffffccc0cc0cc00cfffff0ffffcc0000cfff888888888888888000f
c00000c00cffffc00000c0ccffffc00000c0ccffffffffffffff8888fff88888888888888fffc00cccccc0cccfffff0ffffcc0000cfff0088888888888888fff
c00000000cffffc00000000cffffc00000000cffffffffffff888f88fff8f8fff88fff8f8ffc00000c00cccfffffff0ffffccc0ccffff0088888888888888888
c00000000cffffc00000000ccfffc00000000ccffffffffff88f8f88fff8fff88ff88fff8ffc000ccccccccfffffff0ffffcccc00cfff0088888888888888888
fcc000000cfffffcc0000000ccfffcc0000000cfffffffff8f888888fff8f88ffffff88f8ffc00000cc000cfffffff0ffffccccccccff0000888888888888888
ffc000000cffffffc00000000cffffc0000000cffffffff88888f888ff8ff88ff8fff88ff8fcc000000cc0ccffffff0ffffccc0cccccf0000888888880880888
ffcc00000cffffffc00000000cffffc0000000cfffffff88f8f88888ff8ffff88ff88ffff8ffcccc0000cc0cffffff0ffffc0cc00cccc000008880888808f888
fffc00000cfffffffcc000000cfffffcc00000cfffffff8f8f888888ff8f8ffff88ffff8f8ffffffccc000cccfffff000000000000000000008800088000f000
fffcc0000cffffffffcc00000cccffffc00000cffffff88888888888ff8888888888888888ffffffffcccccfffffff00000000000000000000000000000fffb9
25d44d61c6b424c4b15f46b92146ce1543905de4b93f05b50bd29013d6ed44d39973dab5245b3d61c6e11068702f8744cb50bd1583552e41b121c42845d6f455
417415c62c318440bc580a8cd4143ec3bd48424da95b1032511019d61845caca2146ed09e9fa0c453125c4fa730bc580e8c921469c64c3e4b4d6c42b41b15841
bd4f45e01bd36c6412105d1b350dc554bc03bd44523c2bd59058c69d35d64122d35d18c6183915842ec1b2b741d40c03b91f84bd3e41b50e01bd3e41b91f84b5
0c03be64125c64122515c6ed5d453d21445515843daed5ca2146ed5741541541541543ba771bc58029c921469c67d3e01584bd58c3b1254bc03b9050b741d025
4bc03e2ba409539d6050251e053d67d35134c6e416512d6c414d6183915842ec1b51cc45c6840014583ae6943b152569837c64d3b15842ec2b502c3515b90f46
3d6dc3251b139c25c6412546bd518341b350d46f45da45c6050251e053d6142e05b15841bd3e413d67414159837c6d40294941447bd6506013f845c69d359435
1c81b50e01b919834c67121053d62527024d66c32d69d3557b93f05b15841d0b741d43d43dc6ed5506013f845877d69d35d45036c6e119e9412f84f45702c46e
11d1ba409977d1541541541541541541541541d8771bc58069cd4143dc3e419d69c4e4b4d64125c65834c6f81b15841bd5f84c01dd68413c2b53fc44d6051f04
c41b50251e4b4d6252302b925d44d61c6840e01645c0b741d46f45bd0183b50cc51463d6742651b550d6f83bd5540c058c61834c66c3c03fc5b158404d63d334
21039c44d6d41d413d66c32d62516d3c45452f831849d64515833d6050741b139c25c6350d0ba40952bd3e039d66c3c03fc5b15841b15251245302505b535435
c4b91f84b131453029837c61c686abc1b142d3a413059035c626a963505584b15541ec4b141c1547d57c27128627a409d38c6ec3dd69c67d3e01584bd58404d6
8400145834c4d1b350d01f83d25bd5f84256b502c3515bd58404d64129c4b9734a7e18c3315ed0b15842ec2357b925d44d66c33453d6f83b56f45b50e01b11f4
2ec1b56f452d6241315d1b741dc62413524413d64d3741412584bd55c6340ec67414d64122d35d18c6183915842ec1dd69d355bc03b919834c69d3594b92f46d
d6903cc6d40b41bd45945cac27128727741d835415415415415415415415415844cace4143fe11c40d4f61651ec64125c6ed09e9702fc44973c6b83fc53d69d3
55b251b15f04bd36c64125c63031c43dac27168027350d42bd5f834412d6712105b52b151c25c6514ee63d2942ec1ee6393fc52c3184442ec1ee62d3c03584b1
1584246ee68c32d45c6c403512d645078bb949c4bc62c3852ec1e2b741d42b90505b56f45d23cc6241b50b92fc17412d6d45dcace4143013540351b93fc6b424
c4be694bc03b11fc6183915842ec1be694bc03b51651ec6ac37cac27168127350dc58c3102b1584045b3d6094505456bd0fc3ccab50c058c35d18c6412983b42
ec1b502c3515b524d62419837c61c63d3340c42315b54551584b14593bc67524d08c69c4e4b4d61c4bd3252742e40cc61c4b524d6312f45c01b9050b741dc018
3d25b974089e51424974c64d3b945404c69d3594b969835c4ca2146905de4b142d3ec35933414c6a52e41b56f45b9051541bc581a8cd1543712105de4b935c5e
2ba409db1559414139db983441501c27168327350dc0183d25bd51424d64d3bd4541bd58404d6ed4640e051c49973d6515f04940bd5842302b91983103c46b15
5403025c4b535c6712105b12104052e413d4b5231b741d42b15842ec2b5245b3d6340c03501b97312f05b15f049c0ed4b50e01b5245b3d64c3793b504d64125c
6d40c03ce4143f45302b2bc58129c92146ed09e9fa0c453125c4fa730b350d423d6412105b50b921c0b04f05b50ec475129bb90515b524d64c35c4e4b4d61833
d5584b15841b545513159c3e47bd32d6742651b935532412d4dd6440d83b148c3e419d6ed09e9702fc44973c69c4b15540352ec1b5350b741d43541452ec1b50
4d68412d68c35d45c66c32d64125c6e427024d67125845c6751b55351b50bd4052252490f40211b50e01bd55402d6345451b939c1805941357b92146b5314624
1bd55c61845c64125c6840251dcaca2146ed09e9fa0c453125c4b121844412dbed0c27168527350d42ec64125c6645455251b52d63b531c29837c62523025c4b
d5f83d25b51852315be6712fc6750e053d64d3b50d403d4bd5540c058c6712583b56f45bd0183b91906bd484249bce15437c3f01b135d0bcac27168627350d83
fc6302183741b15841251b15841ecaca21469d35d6340ec61037509d4b15103bc64d3b553d6981b56f45bd5183457b56f45b11f83d25b935414c64d3bd1fc690
5b50cc3e41d1b741d426c69d35d6b41504b152569837c61834c6e416512d6742651b550d6314983e42ec1bd3ec61834c6f83b51651e05550c039d69d355bc03b
902511c2b15884f45702be64121053d68c37d61c6484903cc67d32d23dace4143f02e21fc69d35d6750e05b15fc6ed5484903c877d6d41e2b741dcbed09e9203
5d48873cbc27168727350d8735188bba73d6712105b15841b159053d64c35c4b158404d6d41183ee6ed4502eeaed4ce1543d409905c64129c4b9734a7e18c331
5ed0b523d6251103b50605584b50c03c271a8027741d43146241b52d63bd1593e40b92f42ec62d3c03584b11584246ca2146f02b523d6412105bd4fc69d35d63
40ec67407d2b504d6ed5dc3c039977d6f83b15841b14905302b50e01b52ec64125c6312fc558431b741d83fcab15841bd40d3215b13fc3bc4b91593dd6412105
de4b50c03dd6314f844d6312fc55843d61845c63d01849d61839d5146ca2146ed5741dc68403d61c63845d48c6f83b53f03c46ed5c271a8127741d42bd15513d
4b52d63b142514159d6ed5314fc3b46ed5b50c84540446ca2146841c031c6314fc3b46dd69d35d60554d69d3594bd1f01440d83b90cc3f01bd3ec64125c63149
84905b90f40211b2b741d8734a7e18c33153973c6e41501b90cc3f01b15fc6355d43f83b15841dcabd3412584752351b524d67d35134c6a45315b905c61c64d3
91bc582a8cd15439c64c3e4b4d6b83fc5b12fc5b15fc6641503b502c3515b50b9734a7e18c3315ed0bd0f43013943583452ec1b535c6c42b41b1584041b350dc
5f45c01b524d6841c04b526c6751b503d2501b524d6981b97353f03c46ed4b91f45e01b56f45bd051550b741d877d4140140140140d8771bc582e8cd41439d35
d67c34d64125c6a403c20d34dace154394b4c6c42b41b15fc6412183bc64125c6ed09e9702fc44973c61834c6d46b912525834c4b504d64129c4bd5f83441291
513b935c531bc58229cd15439c67d3e01584bd58c3b1584195bc03b9058bb52bd5f834412d6981bd554bc03b905c6302903402fc34c63d554141254021531b35
0d46f45b905054512d67414d6cc3fc29837c66c32d61c6302903402fc34c63d5541412540215bd3c01903fc0bc4ce154394bdc61c6dc3e058c6f034412d64121
83b56f45b115115cab50b53f83412b2bc58269c921469c62414d69d35d6d402949d69834d3b52457ce15434c3e4b4d67d3294957b52d23cc62459d6950c03bd4
9c0b41e42ec1b112513d45c4bd4fc69d35d6340ec67414d63557402d6dc3d431c4b15fc3c271a8627741d47d57ca2146d57d1b350d47d57ce1543412105de4b1
42514159d66453c29837c64402d2b9734a7e18c3315ed0b11511547ca2146d43dc69d35d6e41501b53f845c664090580b350dc0183bd18c33153d6840651b911
42412e2ba409158419d6d427024dab50605584b50c03b158419d6d45315b90503941651b52ec6183b50605584b139815c6981b158419d61845c6c42652ec1b52
41bc582e9cd154394bc03b151c25c6905b2ba4091584045b3d67129d6905de4b93f05b50b565c4ce1543d41183b2bc58328cd1543752c03bd4841b905c0f435c
6585583b53f845c6ed4d453d0c419973d61834c6ed4245681ed4e60ec47512d6d41b158423d6312905456b9734a7e18c3315ed0ce4143013540351b11f83d25b
112d3f03bd3ec64125c63149849052c31844c6741d0bc58368cd1543983451251315983747b52bd5f834412d6981bd55c6840651b912525834c4bd58c3bd5f83
d25b905c67524d084131ba40952d63b50bd08849c4452183bd4fc69c6094f80180c46bd5f83d25b905c61c67524d080b350d42b53540ec69d35d6412983bc61c
6cc34d6f81b524d69c4bd5183bc6412f45702ce154394bdc6ec34d6355251b56f452d6050251e053d64841c1742ec1b56f45b15fc6302594302bd5903cc6315f
04bd3594bd59053029d6983603551ec05c4c271e8227350d42b15842ec2b52bd2ec37d63d3d41f835c6712fc61c12515c4bd59058c6412105dd6ed5741d87757
b11901b56f45b53f855c64125c6013183302505e2b741d83f045cab535d445b651b90541ec64125c6ed09e9702fc44973c69c6d45315bd4146b524d6b83fc53d
6712105b5245b3d6450cc29837c6180f454d6412f45702d1bc583e8c92146412105de4b939c0547bd4841b50cc51463d6cc3fc23d6b42e011c63504c6184f45e
01b129c18c4302fc3c0b741d465408cabd1fc34c6ac32c6dc3c039dab905c68400149dac271e8427350d426c6f83c46bd55c6b835c5bd58c3b524d67503d64d3
fc6751bd0f45c01b531c25c60d3f84bd1543b135c43d6e41295f4531ba409d38c64125c68c3294f84bd36c6ec34d6b83fc598370b741d877d15555555555563d
43977d6751b50251b52ec6842702bd4302fc3c47bd55c6184583d25b115c4051250451bd3c01bd02d3e413d6712f4bc03b53184256b15841b91984315b145843
d3ec64d3bd19855c6412543b50bd4ec370bc58369cd15439c6b835c5b524dabd4841d23cc62413c3d41b15841bd5f84c013d6784540451315b52341bd0251143
bd08416c63131c48c62d3c03584b11584246bd4c40312b94fc0b414d63d0941e059c441ba4099744a5e50f5841251e11b11901b56f45bd0f435c6514bd59058c
6412105e2bc583a9cd1543751b935414c64d3b90252ec1b12584b52e05fc6f452d63c3651ec6640315584b15fc6d40b41b12584b135c43d635040b350d431462
41bd55c61845c62c34125849837c68412d61834c63125c64c35c4e4b4d6750e05b912525834c4ca2146751bd0183bd3e039d64c3bd3594b905c44d64d3b12503
0dac271e8727350d82146ae67121054461c6d40b41bd36c6412105e2ba40912512ee69c6d41183bd4841bd4541dc4b955849d6303585584d57d1b350d426c6a4
09d63509d4bd4fc694bc03b90503941651b524dac27228c921467459d4b52d63b912511c29837c6f454d61c62424d6340ec6751bd44d309be14ec3bd3e41bd44
d30d4e14ce41434c3e4b4d67d32949d6a409d694bdc6841251dd6702fc44d4b11f83d25b51852315e14751b11f8701b741dc3b409d674221339ab53146241b93
fc5b523d64125c6452d41bd5841ec6751b905c0f435c67524d0841357b909d6b42c039837c61c6702fc4457bd0183b519058412d6f81b56f45b53f8558bca214
6ed5ec3ed5ce41439c6340ec6840211c46b90c42ec2ce1543905de4bd4452c03b90f45e01b15fc65d4b50e01b121c4b50b115159d64d3b50ec47512d64122d35
d18c64125c6355d43f839837c62c31844c6593452cc6905b121c4b91513c46bd0f435c69834d3bd3594b14c40e41ca21468c37d64c3b56f45bd2ec37d64129c4
ee61845c69d35d67c39837c6f816c6412105bd11435c6f81b11231bd55c6013146501e2b741d42da55c6251101b13f053d6180f454d6702fc44d4b50e01bd590
53025c4be6981b158419d61c0455103b51852315e149c64c3fc3e14b158c3351b90fc3bc4b539c1805b905c64125c6b41957c27268c921467459d4b52d63b912
511c29837c6f454d61c62424d6340ec6751bd44d309be14ec3bd3e41bd44d30d4e14ce41434c3e4b4d67d32949d6a409d694bdc6841251dd6702fc44d4b11f83
d25b51852315e14751b11f8701b741dc3b409d674221339ab53146241b93fc5b523d64125c6452d41bd5841ec6751b905c0f435c67524d0841357b909d6b42c0
39837c61c6702fc4457bd0183b519058412d6f81b56f45b53f8558bca2146ed5ec3ed5ce41439c6340ec6840211c46b90c42ec2ce1543905de4bd4452c03b90f
45e01b15fc65d4b50e01b121c4b50b115159d64d3b50ec47512d64122d35d18c64125c6355d43f839837c62c31844c6593452cc6905b121c4b91513c46bd0f43
5c69834d3bd3594b14c40e41ca21468c37d64c3b56f45bd2ec37d64129c4ee61845c69d35d67c39837c6f816c6412105bd11435c6f81b11231bd55c601314650
__gff__
7a1edb3c0c92a85b20159b0719d5b07850f654db5165d3f62c41e6b247d17857d3344dd334cff33ccff3300cc36459e65d5b10044110200882b04a905d4110044110044110044110745bb20d81b3358f556cc111240e3b054df654db145805b155d3ca360f330556416cd9536d86f434db850494cb1e45432185546c57306dc1
7620cf446dcdc3ac5bb009c9b14dd0f32cd97620cf44adac126409b55dc1b41995b3050eb15148e16c57306dde641552e64d9bf3509b5139ec5134d7f33c57b7251b853cd581505bb25dc1b41d4fe21c1bf56c47416dde3541cfb31484776d01b55148b1150eb1514821151d3b050d8504ce326dc6236dc3d324ceb1350fc364
__map__
e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c14526c4b91752c278a9c126447954d5bd2369b2115c19238c7f654d4166c42426d43e06c57b14dd403b91ee43cdbe314db443dd0e441
ec1434c4e3b4d4763d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c7166c07f24c54b70d81b315098514d2f6185bf6545bf35885cb2a41e65dcee3
5dec1434c93604ce860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5be0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554df33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4b33d95b4414ce014ac1264c8736dc4b3654fb52dce736d14924cee1648c5
963dd5763c89736c8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c14526c4b91752c278e9c126447954d5bd2369b2115c19238
c7f654d4166c42426d43e06c57b14dd403b91ee43cdbe314db443dd0e441ec1434c4e3b4d4763d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c716
6c07f24c54b70d81b315098514d2f6185bf6545bf35885cb2a41e65dcee35dec1434c93604ce860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5be0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554df33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4
b33d95b4414ce014ac1264c8736dc4b3654fb52dce736d14924cee1648c5963dd5763c89736c8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435
c981509b506c14526c4b91752c27929c126447954d5bd2369b2115c19238c7f654d4166c42426d43e06c57b14dd403b91ee43cdbe314db443dd0e441ec1434c4e3b4d4763d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546
254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c7166c07f24c54b70d81b315098514d2f6185bf6545bf35885cb2a41e65dcee35dec1434c93604ce860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5be0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554d
f33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4b33d95b4414ce014ac1264c8736dc4b3654fb52dce736d14924cee1648c5963dd5763c89736c8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b151
48916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c14526c4b91752c27969c126447954d5bd2369b2115c19238c7f654d4166c42426d43e06c57b14dd403b91ee43cdbe314db443dd0e441ec1434c4e3b4d4763d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74
151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c7166c07f24c54b70d81b315098514d2f6185bf6545bf35885cb2a41e65dcee35dec1434c93604ce860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5b
e0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554df33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4b33d95b4414ce014ac1264c8736dc4b3654fb52dce736d14924cee1648c5963dd5763c89736c8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c
5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c14526c4b91752c279a9c126447954d5bd2369b2115c19238c7f654d4166c42426d43e06c57b14dd403b91ee43cdbe314db443dd0e441ec1434c4e3b4d476
3d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c7166c07f24c54b70d81b315098514d2f6185bf6545bf35885cb2a41e65dcee35dec1434c93604ce
860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5be0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554df33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4b33d95b4414ce014ac1264c8736dc4b3654fb52dce736d14924cee1648c5963dd5763c89736c
8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c14526c4b91752c279e9c126447954d5bd2369b2115c19238c7f654d4166c4242
6d43e06c57b14dd403b91ee43cdbe314db443dd0e441ec1434c4e3b4d4763d92946d4a906d49db6c482115dd7620cf444d1bf1382db5155832511e74151bf178107b14cdb304d976241233a95b136442b139cfb525d34621c546254db15d48e16c57b109c5f034c57625d4801453b709d9b6240c9338c7166c07f24c54b70d81
b315098514d2f6185bf6545bf35885cb2a41e65dcee35dec1434c93604ce860412c1649bc024cec21e459350edb44d54c2309bf0540eb151cf564d5be0101b124c5bb01115956dd4b305ce7415d24621d2531dc84621c536554df33889736cc21348c4563954c26c09b521c1b41915c364dbf034c59638d4b33d95b4414ce014
ac1264c8736dc4b3654fb52dce736d14924cee1648c5963dd5763c89736c8f616c141250db1134c5f6181b2113db556c10136405e1b247d124ad556c5211101bf350d316084f456d07f24cd4b4050eb15d093520c5b46e89b15148916dc1405501b3155832511e946cc4f33c1eb451c833159bf03ccbb435c981509b506c1452
6c4b91752c377247d138c950acdbf46c145248c5964c5bb05d41b63dc6564ddb515054e21c1b85484f75201b852453c71e45b35148b119155549c5964c4e4b6d145224d2b451cf064905910cd42654d4f654d2b451cfd6044ba16e57b10955c210db5349db73391bf240c5b4050eb111521134d34621d2531dc8160c54f2385b
e0101b515085d4244e40258fb3b24a9011cf963dd5860456b14d4f535048e21c1b534cd3163849536c141250db10385b305055c030d986140cb45593eb41ce432189735c09c320050379103b05cd1b55494131d9eb11e9986c14f25407426d09b55dc1b441524151d9363c0fe311ec513443e06c45422185b43dc6963dd54621
89b36c8fb105db1564db556c43e06c542039c9846c14526cc21348c4f6489b2015c1b25148b14d45c06c8fb35148b149cfd36c86f4341b524885cb4e413341094525ceb15d8fd3521b5230d076250cb32594cb1e45e33cd456394c314d5bf654db1038db0425d456384f75201bf56c825404cb763d0fd16d43e06c57b13d50e1
6c14526c57e210cf356d86f4341b524885cb4e41d3641bf25453b12593d3521b8514dbf11044d0385be150850449c9546cc936044e4b6d4a35511b5530cc96501bf56cc4b35148e21c137b144df654dbf0540cb12181556cc1363581446dc8534dc5ca4e41333581446dc8534dc5b40552b10d52006d1712505b626cd3d3148f
536c48302cd39638d4b3654f256d4e415d8fb4b8ac1264ce436d14526c54d2141b13104931ad5bb22181556c81b325441174db51345b326dd953491b843c4eb13d8ecb1e45931501e2b24a903d4b906dc7f31c4cd16d53e1101b5560d4463d5bf3304cc64288333d9294a9db853c1bf16cd9536d57e0501bf56c5481512e7b14
cdb304d9763ccfc114db5438c4461518b551cfe60de9f90a4c3521af376c90545054b6350fc364ac12641e01a65dd779043b058d478069d7751ef11ec97130c5cb4288732101356d14526c4d314dc151b8ec513448916dcdc330d9363c4d136cc9863c50b1490fc314d2461492906d57e150dbb304d9363c4d136c4db1050eb1
5148b11d89c44c5b2015db44250cb355d096185bf654db1538d4463ddbf034c5263d95436c51554c54f2385b13480b7b14cd76152db14945c030d9c6244bb151cf3615c5963dd51638c4462185544cdb040552b14d4c514089736c135519c666540cb34dd4036d10530453b10d4f536c46c530db443dd056605b816d05c64288
733cd49650dd463c5bf654db1538d4463ddb5438c49650db236d03123847b12594cb1e4533150ec14e41933dd5b638cfb55dc51648c596381b5114d0362109b51d45e36e141250db154c5bb041524151d936545431655b534c5370141d7b144db21109e1b4d476050eb52185b45148e22c89736c49db6cc1761589443c2bab04
59f6545b20155bb079d3552412f178d3ba3d4b906dc7f31c4cb14d85436c5481511bf56c90545054b6350fc3642c8438171250d34621c5d614d3141c85cb2a41963dd5e61405b151cf363c4db149c981509bf35c5b42b5d3462452c11e458314d936510fb4b24a9029d5446dc3d314db55b40cb311cf1638198524ceb151cfd6
044bb125d456411bf56cd95375dbf034c5363c4db10d4f53b047d17897120441907917ab0419932cc5262507426dce73ad2c8438c7436d09d511cf963dd576050eb551cf36150eb125d4f648db8004ce516c09e5b24a904d8543ac1e21a69b474c8f2465db51349b50515bd2369b54040c936dd3104805c11e459350edb43d4b
90a91b8504d4b41d95e3041b152cc5166c5211304cb65d4522115b81414ce00454f2381b853cd581745bc030db556c43e06cc4b339cfb525d3463d9b50304961155be26c4821752c477247d16441b64d48d14edbf0348973acdb556c4a35519b5314c4463d9b9010c5f654d246254dc12a4196b456b11d0fb5051bc404ceba31
05b535c5164ccb4621c5e61418b53d4ed1b15cc92941362109d56dc7436c44d0385b5334c5e60de97920cf447943c74e4193b456b11d0fb525d4ca72263705cd5530cce63cd77615dbe23cd7d63c52b105c25351db43518534addb84145b534dd426145bc034cf446d4821152c777247d178447a5e411004411004884778de08
__sfx__
540e316d336420193726c552236317b5325c55150641b2150d9250652101b2138c343a66105d1325c15364630d50421c40331660541315066333031ec011ee55366661bb332d171316230dd152d121120051bb27
42b5d3f606d2638120180761bb332dd55267011e63522a71073172095126a61120261401138c54346410fa2321c0015243073350dd51343250ec030d504137661971509d51343630db310cd51132600545305464
4153b0532c404366222dd131d064001660271421c5523166197152dd1413503043333c464117661301134c24163630cc112d14400166013323d060131441b405081143666101515306341136415b002cd0436402
50db2065103020f02518421033261b70534c55353432dc2329c250456602d0335470142430733421c24365020f4152c125123212c21124514333431b11435e15062200cc171c524213660ad21304440156611d21
4479c3ba096172cd00031661342108925364040ff132487401374015133d455204211b7252c11511001193363c8150650209b262e515153230fe1138c34160661e32215400237641bc1118d24267602974720c74
09b151cf1dd74333630ff153125410622145532d154354051b903115742627609d552c974035661352215c5501263134232d115110030c93315045324051d4571446005220145532d531120051bc2014c4536420
1915b309065020533720c740454015324158153464015c23111441166613c2130864163200e10714824065631b32118d242632117b313d815326051711314455203011b225394553066405d112c5153506005323
2405d9961511339c24344272c2112412112166078170c925260251342508d151600313f130501521b2314332154000337105d103cc350612012d0325574252760d9330d474354220e33305c35260220cc1335c21
c253511b38455203660111201d70045660f6131486212026029143045513544129012d5201626414b252d12112166078170c92110564145020d551313432dc241e424133441b515091151066609b230506033620
a468d7751224209e130cd6516266025042d14431644156132d121121661250130c55012631342214511151441333539024214660133604454316430151534d51105441433720c74045220e7043d0702b22019634
326dc9761ec040e50403321145532d934330251333138824061631bc2024c1506502096173496611123093363cc21031660133425805162431bf1614c5523166148170cd2406420079062c53502560083323cc74
d2334d1b3c825261440fd1311144005660f4142c511323041d45714c643b1210d333149253460205a2311144153401bb24244300250319331388242604415b2014c15065020533230c74031471e1503a97516060
05101448052211bb0708174214660fe0311144316400f102114722b220196371d424111210550534c5237566012252cd45135660f311249763650201c23111443160205b03386523b1210d91536c553322019b53
b11952310561431c450650209b2325c153650201c2309c40031641bc2014c513782227f003c411257601bc272c1211216612f17344613b1210d1032d964233611b1032d12112166027110892406220133333d464
4f256dd721c51003630fc033d874160430433421c24264630fd1325c15364210141510c55042251433421c24267602974301d40142051eb030d94413503043321445520003053343dc552046313b232507035366
1041c12a2340304d342e515103630b90135d51333651bb000407035276100110c5643064505e110cd5133364145022d5642530101d041e4240340201b2504c511514309b2339c740452112e3601a32277660dd26
e64159310113021c04143201b62538c44346430f32415815163250e4011486614023100110c5643064505e110cd5133364145022d5642530101d052dd0014166197152d144214211b63324e360126313c260d876
17ab04593990506321145532d134223011b71511551052211b60511d211416614015384520bf2029951321541064713f2020c74130021eb240e504237012904321440352570445714c60375411552515d2530247
04c8462132605089162c451052211b63324e360126313c260d4553246612501304523b1210d90610455025660191634a25063220bd030dc040442112b54321161aa321c70534c74333630ff17204613b4200d135
b1059b5301c250e55522305052250c125223611dc520444532605087151d040356221433705c1516425094252cd70205221dd3531a6118a322043305c64052210e3342482406502053323cc0004166025033c464
8fb451521c555301211b8110010526b1307d0510440316650533315564333431bc2014c550126313c233d834160660671509125253211bb073c454121660fa230d57413105089161c0723b4200dc2024c1506463
044ca21530122033333cc741222113b34240343166012d250806401166025063c0153162214b3004824160660301138414316050f33215c0400266094232d901142230545714460052211933424820133151b225
c81d459304b3424034316650fd24100740b56602d0305c552432010d342a404363740e7121155113025070133d634156641b3243d805064030510315856166631555215c55122030c9161c455131272c43226646
cdca4e4118455025660be171cd15065020533614125254211b7252c511323250cc030d125204051b40225060132430733421c24361020f3242d93423466140152c1242144019332154150530513b542a40436121
1dc83351333441b6152092536521053132d1143232301c200c551151641433138c151514413d342a404364200db54321161aa501c21124d44160231b63424e36042630331510071117660d90109c240650209b23
816cd3801b1132d56431464096172c535025021b52339a66140230933714d243446609c2325c1516066078170c9213a62206b312c535214211b9031d844334051b9131d574053011b5150cd15365221481321c44
8f9538c73c4703366109a240c551353632c43226e46087420113108d24365211b32509d240650209b23395143a17108713119753062213e1512d51125641433714c6426021096172cd11131200b9330507031623
6d14526c065020533031c003300205c230d574131020ff262e5403562116d062c5153046405b2331c4412166085022da66111230933134c55150261bd1708d243642013b212d655326610fc230dd04344660f524
360d49e1013232da66140232fb0014d14023212fc54096460a117139051c5200336609d5430c51101271b93714562316430562508d551152113b2531634113050850215c55150641bc2004825065220dd0325874
8c554cdb0cc2436003013232d5311214405334214243666405c2319c401416614f1311144112441b01124815260261b1030c4401114314d33111441166604f1634a253642105d1311d7436121143342142433421
0552b151234660fc2014815064210f82414c553436601e1111144223611b1023c4213560508d052cd44346201b325099011426405c5204445133231bc2014c45160440533518d2033603053232d515013411b107
c02cdd46089062cd15133211bf010896414f0307d0520420121020545305460125022ec5204c45032660a505285200bf402915532534113260fd230dc003366405d0325825261440fd1321c743560508d012d535
5b6115522142436661096252c540356200cc13054351066609e1311144112441b32705c34111441d45714464025641b9031d500332661401110d15364020f524258743160508d0108d51111210c9161cc1506563
4841136c3634305c5204c45063220bd030587436345052243d805163211481710455300050fa233d815364630d50421c40339432c32134c440650209e132c121121261bd111c04035642153242d114316220e334
b638cfb5034150946517f031ca4126232374200df073c824065631bb163cc3516266075250cd113b603054232dd043426609c230d57413166115250c1253234313331084740556615b232ed44365200ec2311d74
2e3b054d1d14400566197152d534003641b10215451052220eb1138c34160430433421c4434647031571e844334051eb0325c15361250e6112c125013031b51530a6118a3227c32044451306205b230dd2033421
1418b5b222166197152d121122430b331084740556609c2321c0004166016142c114300621710211c110b3710551015470043211b10215c55031011db34140253b46601b232cd701316601a07149252622019b36
b34d41b61ca4126242371210d22110c44100032c3213404401303013331d5240156604524144112b22019d2020844267650761108164263571745305c64032661372514025121660ef152d974336630ed030dc00
ad546c4c1114400d031ca4102642272201911435e1516003179010dd5113260053343dc511124304b3714925364630d50421c40331660e5073161510323153242d11431602012242c93423466197152d65536325
acdec572322211bc2014451132401210225d55231660141520d0003144099042a40436357031570a0643540205b260d4723b1210de171cd5512264133230dd15344642c211249753512105505144241112105d05
7614d4262215126a61120260e50704025225211dd352d164322211b515349661402317d030dc00336410f3050dd5523366140152cd34333011bc2024874314661471714021121442b457144642010505a231dd24
959358853c015011660fe031114431647031571e844334051eb031dd24360200e332154003166508f1414c15133211b51534c24043172215102a61120261790110551313211333421c4434623059062c12112166
5148e16c344211b1132d1240152112d1138c440452203e541e424035020f3252cd00141661771211c152622019c5204c41105051b1162c121121661eb011e63032364146332cd503336513331308640650209b23
d2369bf317d030dc00133151bc072cd0013605089161cc652614405d031d5400336609b2319c04121660562538455203261481138c3416663155542c924336050f33009d701516609c250ed51141200c45714464
41d3049910d551454405b312cd210312112324050703164015c2325834361020f3240d5550162213c2311144005660d11720825260211b32409d00331211233421c0033665055542c121122430b3343dc700b374
5d4821151016609c250ed511256414332154001124307b3110d663466317e1319421155440533425464013220ed030507031622145532d5542230101b3424454316201b70134c24065020571225551052220ef03
f65885b41b1142dd040052501c1424555324432dc2319d20146660102031c44100400cd0311d742642101c1301d2403403054571446005222133333c870151441310425c703360201b231dc70131661211720825
c540b9ec35c450622101c04321161a8301c7053403435062096172c114254431db371451002317221510aa65111231381708925160431372508551125022ec5204445177271701110551112011b9371455501604
2d5b426d140231750215455363251bd0001d24005220ef0305c513334505c1311d74260211b320150603566315c2331420055211233224551131051450239a62120261b51124114316650533321474053011b103
9534c5b414f13150410432009e13055252030515d130d47403425149161cc560650201c231d574053011b0223d014200031933214455306030f6172cd003346505a241e42403220089031d42536c421bb2734420
53e14cc5250253b46601332248251636312d0319864335211293325d002336317e5325c551152113b2325c55313051b52315824065631bc200402507317221510ea611202609b3514c003362214b350445431466
25c646212602514b3110d6634664149143045112044043343d4511212012c540964608117139051014400d231333009520055261b40518c401320505d342a404365211b30138462356440590430c45362430ff23
0331c1d405b360dc46391020f32439d14162641bc1125874316220633715451313432dc2305c15326200271511555354271dd341e424136210181331420153741b0251481526421161151c55105222133350c825
c6963dd524c140622003b14321161a8311c70534021122641b63324e360126313c260d455324660a52311d551152113b2138c343612519b2332615103602dd1738c513782227f003c411257601b2051112537622
6d4cb214061630e5542d511151041b1142d5213466505d5430451112611b71511555203662733204060336200ec031d4203560508d0309524003660652415115316430572331a6118a3026433054602446302b25
f13c0fd11b5112411421376093353987423376178112dd0014166197152dd04342220ef0335c203b64205d021545502d2313b34244543160508d030d105203221381325074145221311321455223660850215c55
cf436c81316341136105c233d830316231933204c1432466197152d174214011333721c74365200e4232d925336620e7172d5111554106d332546633642153242d164322211b01508d24261631233421c2426003
6c54513803166138273c00536645092050cd55111211ad0325451112010e5542dd50333651bc2014015316650fd2410c5110166115250c1253234313d342a404363130152720c40339631b3010c1052146614015
f648dbf4017052c5303236414d34321161a8711c70534c443624305f231114400d621b9132d0743156614011105522b22019b37204551612008e5321c7425276041142cd451356601b232cd0033e611b20130864
5b53040e34420052220ef063263411321181031016436a130a9013d844361210dd34321161a8121c70534044116661eb011e630323641463328651121261db313dc25160440533421c24363430533721c7416264
b456b14d356050fb3338c74352761990305c40133151bd0001d20142210eb0138c34065020533721470131660c91614c0034605095152c121122430733721c45061630e5542dd45135660be171c1723b4200d725
b60552b115d153c07401166140152c12405166078170c12537622145532d9013434001a0424551132620533421c243614405f033d834361020f3240d9661112315f002cd30141611dc5409e42182170a9011d144
c7436cce11144214211be172cd34336460f6150c55522366140152c1340552512d062e540356640871531820133151b511101252146609e03250253b46607d2638c0406220100253845520326179013596611123
105b426d3356609d552c154354051bb272c564350021bd1708d24360251291714515073171552515d253024717c520444532605089162c451052211b63324e360126313c260d4553246612501304523b1210d906
__music__
03 41 16 43 0b
01 41 42 1b 05
00 14 1b 43 44
03 41 34 43 05
04 41 42 43 44
04 24 14 43 14
01 41 42 24 12
01 31 05 0e 31
00 0d 42 43 44
01 41 42 21 01
05 35 42 43 34
02 35 42 16 38
03 41 26 04 44
05 37 05 43 44
04 41 42 43 44
00 41 30 43 44
04 41 21 09 44
00 41 13 43 44
02 41 42 43 44
00 41 3d 1b 44
06 30 42 16 3d
02 15 2b 04 44
01 04 14 1b 44
06 14 42 43 1e
02 41 42 43 44
00 10 04 43 10
02 41 2b 43 31
02 41 42 20 05
04 41 42 43 44
04 41 42 32 1d
00 41 31 43 44
01 41 3c 0c 13
02 41 42 43 44
01 01 42 43 44
04 21 42 1b 37
03 24 42 43 44
01 05 37 43 01
04 41 42 06 14
04 14 0e 43 44
02 41 42 10 1b
00 15 30 43 44
00 1c 42 32 44
00 41 20 11 1b
00 41 42 1b 44
02 41 42 43 44
02 41 42 43 1b
05 41 42 43 33
04 3d 15 35 44
01 41 42 21 44
01 41 3c 43 44
06 41 42 15 44
03 41 42 14 44
01 41 34 05 15
06 34 05 43 2a
02 41 42 43 44
04 32 42 05 14
02 38 42 43 3d
01 41 14 34 2f
00 41 42 43 31
04 11 09 31 25
03 41 42 43 44
04 14 34 43 05
00 24 13 43 44
01 09 42 43 44
