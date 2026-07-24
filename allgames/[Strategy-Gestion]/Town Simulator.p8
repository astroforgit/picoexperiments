pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
	sound=0
	talk1 = ceil(rnd(5.99999)+0.00001)
	talk2 = ceil(rnd(5.99999)+0.00001)
	talk3 = ceil(rnd(5.99999)+0.00001)
	talk4 = ceil(rnd(5.99999)+0.00001)
	addamount = 0
	bubble1 = 0
	bubble2 = 0
	bubble3 = 0
	bubble4 = 0
	bubbleon = 0
	go = 0
	day = 1
	cloop = 0
	select = 0
	h = 0
	lloop = 0
	lib = 10
	addlib = 0
	cloop = 0
	con = 10
	addcon = 0
	playerx = 0
	playery = 95
	ctype = 32
	layer = 7
	blayer = 56
	posx = 0
	bposx = 0
	xoffset = 0
	bxoffset =0
	posy= 99
	bposy = 0
	loop = 1
	loop2 = 1
	loop3 = 1
	loop4 = 1
	mode = 0
	prompt = 0
end
 
function reset_var()
sfx(7)
	sound=0
	talk1 = ceil(rnd(5.99999)+0.00001)
	talk2 = ceil(rnd(5.99999)+0.00001)
	talk3 = ceil(rnd(5.99999)+0.00001)
	talk4 = ceil(rnd(5.99999)+0.00001)
	addamount = 0
	bubble1 = 0
	bubble2 = 0
	bubble3 = 0
	bubble4 = 0
	bubbleon = 0
	day+=1
 select = 0
	h = 0
	lloop = 0
	addlib = 0
	cloop = 0
	addcon = 0
	playerx = 0
	playery = 95
	ctype = 32
	layer = 7
	blayer = 56
	posx = 0
	bposx = 0
	xoffset = 0
	bxoffset =0
	posy= 99
	bposy = 0
	loop = 1
	loop2 = 1
	loop3 = 1
	loop4 = 1
	mode = 0
	prompt = 0
end

function _update()

if (mode==0) then
	if(btn(”)) then
		if(xoffset>153 and xoffset<174) then
			mode = 1
			sfx(1)
		end
		
		if(xoffset>23 and xoffset<34) then
		sfx(8)
			if(bubble1==0) then
				bubbleon = 1
				bubble1= 1
			else
				bubbleon = 0
				bubble1=0
			end
			h=0
			
			while(h<10)do
				flip()
				h+=1
			end

		end
		
		if(xoffset>57 and xoffset<68) then
			sfx(8)
			if(bubble2==0) then
				bubbleon = 1
				bubble2= 1
			else
				bubbleon = 0
				bubble2=0
			end
			h=0
			
			while(h<10)do
				flip()
				h+=1
			end
			
		end
		
		if(xoffset>91 and xoffset<102) then
			sfx(8)
			if(bubble3==0) then
				bubbleon = 1
				bubble3= 1
			else
				bubbleon = 0
				bubble3=0
			end
			h=0
			
			while(h<10)do
				flip()
				h+=1
			end
			
			
		end
		
		if(xoffset>125 and xoffset<136) then
			sfx(8)
			if(bubble4==0) then
				bubbleon = 1
				bubble4= 1
			else
				bubbleon = 0
				bubble4=0
			end
			h=0
			
			while(h<10)do
				flip()
				h+=1
			end
			
			
		end
		
		
	end


	if(btn(‹)) then
		if(playerx>=0) then
		sound+=1
		if(sound==8) then
			sfx(0)
			sound=0
		end
			playerx -= .5
			xoffset -= .75
			bxoffset -= .25
			ctype+=1
			if(ctype>47) then
				ctype = 35
			end
		end
	end
	
	if(btn(‘)) then
		if(playerx<120) then
		sound+=1
		if(sound==8) then
			sfx(0)
			sound=0
		end
			playerx += .5
			xoffset += .75
			bxoffset += .25
			ctype+=1
			if(ctype>47) then
				ctype = 32
			end
		end
	end

	if(btn(—)) then
		mode=0
	end
	
	if(btn(Ž)) then
		game_over()
	end
	
	if(lib>19) then
		lib = 19
		game_over()
	end
	
	if(lib<0) then
		lib = 0
		game_over()
	end
	
	if(con>19) then
		con = 19
		game_over()
	end
	
	if(con<0) then
		con = 0
		game_over()
	end

end

end


function draw_background()

if(mode==1) then
	rectfill(0, 0, 128, 128, 6)
end

if(mode==0) then
	rectfill(0, 0, 128, 128, 12)
	map(0, 0, 0, 0)
end
end

function draw_hall()

	draw_background()

	rectfill(0, 110, 128, 128, 5)

	spr(180, 40, 78)
	spr(181, 48, 77)
	spr(181, 56, 76)
	spr(181, 64, 76)
	spr(181, 72, 77)
	spr(182, 80, 78)
	
	spr(177, 40, 72)
	spr(178, 48, 72)
	spr(178, 56, 72)
	spr(178, 64, 72)
	spr(178, 72, 72)
	spr(179, 80, 72)
	
	spr(161, 40, 64)
	spr(162, 48, 64)
	spr(162, 56, 64)
	spr(162, 64, 64)
	spr(162, 72, 64)
	spr(163, 80, 64)
	
	spr(145, 40, 56)
	spr(146, 48, 56)	
	spr(146, 56, 56)
	spr(146, 64, 56)
	spr(146, 72, 56)
	spr(147, 80, 56)
	
	spr(164, 40, 48)
	spr(165, 48, 48)
	spr(165, 56, 48)
	spr(165, 64, 48)
	spr(165, 72, 48)
	spr(166, 80, 48)
	
	spr(148, 40, 40)
	spr(149, 48, 40)
	spr(149, 56, 40)
	spr(149, 64, 40)
	spr(149, 72, 40)
	spr(150, 80, 40)
	
	spr(129, 40, 34)
	spr(130, 48, 33)
	spr(130, 56, 32)
	spr(130, 64, 32)
	spr(130, 72, 33)
	spr(131, 80, 34)
	
	spr(180, 104, 82)
	spr(181, 112, 83)
	spr(182, 120, 84)
	
	spr(177, 104, 76)
	spr(178, 112, 76)
	spr(179, 120, 76)
	
	spr(161, 104, 68)
	spr(162, 112, 68)
	spr(163, 120, 68)
	
	spr(145, 104, 60)
	spr(146, 112, 60)
	spr(147, 120, 60)
	
	spr(164, 104, 52)
	spr(165, 112, 52)
	spr(166, 120, 52)
	
	spr(148, 104, 46)
	spr(149, 112, 46)
	spr(150, 120, 46)
	
	spr(129, 104, 38)
	spr(130, 112, 39)
	spr(131, 120, 40)
			
	spr(180, 0, 84)
	spr(181, 8, 83)
	spr(182, 16, 82)
	
	spr(177, 0, 76)
	spr(178, 8, 76)
	spr(179, 16, 76)
	
	spr(161, 0, 68)
	spr(162, 8, 68)
	spr(163, 16, 68)
	
	spr(145, 0, 60)
	spr(146, 8, 60)
	spr(147, 16, 60)
	
	spr(164, 0, 52)
	spr(165, 8, 52)
	spr(166, 16, 52)
	
	spr(148, 0, 46)
	spr(149, 8, 46)
	spr(150, 16, 46)
	
	spr(129, 0, 40)
	spr(130, 8, 39)
	spr(131, 16, 38)
	
	rectfill(20, 92, 108, 128, 4)
	rectfill(25, 114, 103, 128, 9)
	rectfill(20, 92, 108, 108, 5)
	rectfill(25, 94, 103, 106, 4)
	rectfill(30, 115, 98, 126, 4)
	 
end

function draw_cards()

// cards

	rectfill(5, 5, 123, 48, 7)
	rectfill(5, 59, 59, 95, 7)
	rectfill(68, 59, 122, 95, 7)
		
if(prompt==1) then

// prompt
	print("a bill is proposed that", 7, 7, 0)
	print("allows any woman to have all", 7, 14, 0)
	print("the right to abort their", 7, 21, 0)
	print("child if they wish so.", 7, 28, 0)
	//     #############################

	// left card
	print("sign off on", 7, 61,0)
	print("the bill.", 7, 68,0)
	//     #############
	
	// right card
	print("do not sign", 70, 61,0)
	print("off on the", 70, 68,0)
	print("bill.", 70, 75,0)
	//     #############
end

if(prompt==2) then

// prompt
	print("a bill is proposed that", 7, 7, 0) 
	print("allows women to abort their", 7, 14, 0)
	print("children if shown that the", 7, 21, 0)
	print("conceivemnt was nonconsensual", 7, 28, 0)
	print("or the birth of the child", 7, 35, 0)
	print("will harm the woman or child.", 7, 42, 0)
	//     #############################

	// left card
	print("sign off on", 7, 61,0)
	print("the bill.", 7, 68,0)
	//     #############
	
	// right card
	print("do not sign", 70, 61,0)
	print("off on the", 70, 68,0)
	print("bill.", 70, 75,0)
	//     #############
end

if(prompt==3) then

// prompt
	print("a riot in the streets is", 7, 7, 0) 
	print("formed; poor people are", 7, 14, 0)
	print("protesting about their unfair", 7, 21, 0)
	print("treatment and demand", 7, 28, 0)
	print("something to be done about", 7, 35, 0)
	print("it.", 7, 42, 0)
	//     #############################

	// left card
	print("do nothing;", 7, 61,0)
	print("let the", 7, 68,0)
	print("problem", 7, 75,0)
	print("resolve", 7, 82,0)
	print("itself.", 7, 89,0)
	//     #############
	
	// right card
	print("take action", 70, 61,0)
	print("and resolve", 70, 68,0)
	print("the problem", 70, 75,0)
	print("yourself.", 70, 82,0)
	//     #############
end

if(prompt==4) then

// prompt
	print("should we spend 20% of the", 7, 7, 0) 
	print("military funds to help gun", 7, 14, 0)
	print("protection in less protected", 7, 21, 0)
	print("neighborhoods?", 7, 28, 0)
	//     #############################

	// left card
	print("spend the", 7, 61,0)
	print("extra amount", 7, 68,0)
	print("to help shady", 7, 75,0)
	print("neighborhoods", 7, 82,0)
	//     #############
	
	// right card
	print("spend less or", 70, 61,0)
	print("none to keep", 70, 68,0)
	print("the military", 70, 75,0)
	print("strong.", 70, 82,0)
	//     #############
end

if(prompt==5) then

// prompt
	print("a neighboring country has", 7, 7, 0) 
	print("been having frequent", 7, 14, 0)
	print("terrorist attacks. should we", 7, 21, 0)
	print("lend a helping hand?", 7, 28, 0)
	//     #############################

	// left card
	print("yes we should",7, 61,0)
	//     #############
	
	// right card
	print("no we should", 70, 61,0)
	print("not.", 70, 68,0)
	//     #############
end

if(prompt==6) then

// prompt
	print("a question about the death", 7, 7, 0) 
	print("penalty has come up at a", 7, 14, 0)
	print("meeting, should you choose to", 7, 21, 0)
	print("use the death penalty for", 7, 28, 0)
	print("murders and crimes that are", 7, 35, 0)
	print("believed to deserve it?", 7, 42, 0)
	//     #############################

	// left card
	print("no we should",7, 61,0)
	print("not. it is",7, 68,0)
	print("cruel and",7, 75,0)
	print("inhumane.",7, 82,0)
	//     #############
	
	// right card
	print("yes, adopt", 70, 61,0)
	print("the penalty", 70, 68,0)
	print("to try to",70, 75,0)
	print("stop these",70, 82,0)
	print("murders.",70, 89,0)
	//     #############
end

if(prompt==7) then

// prompt
	print("a bill is proposed that", 7, 7, 0) 
	print("legalises same-sex marriage.", 7, 14, 0)
	//     #############################

	// left card
	print("sign off on", 7, 61,0)
	print("the bill.", 7, 68,0)
	//     #############
	
	// right card
	print("no, do not", 70, 61,0)
	print("sign off on", 70, 68,0)
	print("the bill.", 70, 75,0)
	//     #############
end

if(prompt==8) then

// prompt
	print("an lgbtq+ pride parade is", 7, 7, 0) 
	print("marching outside of the town", 7, 14, 0)
	print("hall.", 7, 21, 0)
	//     #############################

	// left card
	print("shut down the", 7, 61,0)
	print("parade.", 7, 68,0)
	//     #############
	
	// right card
	print("leave the", 70, 61,0)
	print("parade be.", 70, 68,0)
	//     #############
end

if(prompt==9) then

// prompt
	print("there is a severe immigration", 7, 7, 0) 
	print("problem, so it is suggested", 7, 14, 0)
	print("that a large fence be built", 7, 21, 0)
	print("around the town.", 7, 28, 0)
	//     #############################

	// left card
	print("you believe", 7, 61,0)
	print("it will be", 7, 68,0)
	print("efficient;", 7, 75,0)
	print("spend the", 7, 82,0)
	print("money on it.", 7, 89,0)
	//     #############
	
	// right card
	print("you believe", 70, 61,0)
	print("it will not b", 70, 68,0)
	print("efficient;", 70, 75,0)
	print("find another", 70, 82,0)
	print("solution.",70, 89, 0)
	//     #############
end

if(prompt==10) then

// prompt
	print("you are presented with the", 7, 7, 0) 
	print("sutuation of expanding the", 7, 14, 0)
	print("local coal mine. do you", 7, 21, 0)
	print("choose to expand?", 7, 28, 0)
	//     #############################

	// left card
	print("yes. it is", 7, 61,0)
	print("worth it and", 7, 68,0)
	print("coal is a", 7, 75,0)
	print("great fuel", 7, 82,0)
	print("source.", 7, 89,0)
	//     #############
	
	// right card
	print("no. coal is a", 70, 61,0)
	print("depleting", 70, 68,0)
	print("resource that", 70, 75,0)
	print("will harm the", 70, 82,0)
	print("planet.", 70, 89, 0)
	//     #############
end

if(prompt==11) then

// prompt
	print("should your town allow people", 7, 7, 0) 
	print("to carry their firearms in", 7, 14, 0)
	print("public?", 7, 21, 0)
	//     #############################

	// left card
	print("no. it is", 7, 61,0)
	print("dangerous and", 7, 68,0)
	print("people will", 7, 75,0)
	print("have", 7, 82,0)
	print("complaints.", 7, 89,0)
	//     #############
	
	// right card
	print("yes. people", 70, 61,0)
	print("should have", 70, 68,0)
	print("the right to", 70, 75,0)
	print("protect", 70, 82,0)
	print("themselves.", 70, 89, 0)
	//     #############
end

end

function _draw()

draw_background()

if(mode==1) then
	draw_hall()
	h=0
	for h=0,15 do
		flip()
	end
	h=0
	sfx(4)
	for h=0,9 do
		cls()
		draw_background()
		draw_hall()
		h+=1
		rectfill(5, -25+h*3, 123, 18+h*3, 7)
		flip()
	end
	h=0
	sfx(4)
for h=0,10 do
	cls()
	draw_background()
	draw_hall()
	h+=1
	rectfill(5, 5, 123, 48, 7)
	rectfill(5, 92-h*3, 59, 128-h*3, 7)
	flip()
end
h=0
sfx(4)
for h=0,10 do
cls()
	draw_background()
	draw_hall()
	h+=1
	rectfill(5, 5, 123, 48, 7)
	rectfill(5, 59, 59, 95, 7)
	rectfill(68, 92-h*3, 122, 128-h*3, 7)
	flip()	
end	

prompt = ceil(rnd(10.99999)+0.00001)



// choose prompt

while(mode==1) do
print(prompt,1, 1, 0)
flip()
	
	draw_cards()
	
if(select==0) then
 cls()
 draw_hall()
 draw_cards()
	rect(4,58, 60, 96, 10)
	rect(3,57, 61, 97, 10)
end

if(select==1) then
	cls()
	draw_hall()
	draw_cards()
	rect(66, 57, 124, 97, 10)
	rect(67, 58, 123, 96, 10)
end

if(btn(‹)) then
	if(select==1) then
		sfx(2)
		select = 0
	end
end
if(btn(‘)) then
	if(select==0) then
		sfx(2)
		select = 1
	end
end

if(btn(—)) then
sfx(3)
	// left card chosen

	if(select==0) then
	
		if(prompt==1) then
			lib += 3
			con -= 3
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +3 lib.   ", 7, 68,12)
				print("   -3 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==2) then
			con -= 1
			lib += 3
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +3 lib.   ", 7, 68,12)
				print("   -1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==3) then
			con += 1
			lib -= 3
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   -3 lib.   ", 7, 68,12)
				print("   +1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==4) then
			con -= 1
			lib += 2
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +2 lib.   ", 7, 68,12)
				print("   -1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==5) then
			con -= 1
			lib += 2
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +2 lib.   ", 7, 68,12)
				print("   -1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==6) then
			con -= 2
			lib += 2
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +2 lib.   ", 7, 68,12)
				print("   -2 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==7) then
			con -= 1
			lib += 2
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +2 lib.   ", 7, 68,12)
				print("   -1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==8) then
			con += 1
			lib -= 4
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   -4 lib.   ", 7, 68,12)
				print("   +1 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==9) then
			con += 2
			lib -= 1
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   -1 lib.   ", 7, 68,12)
				print("   +2 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==10) then
			con += 2
			lib -= 1
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   -1 lib.   ", 7, 68,12)
				print("   +2 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
		if(prompt==11) then
			con -= 2
			lib += 3
			cls()
			h = 0
			while(h<50) do
				draw_hall()
				rectfill(5, 59, 59, 95, 7)
				print("   +3 lib.   ", 7, 68,12)
				print("   -2 con.   ", 7, 82,8)
				h+=1
				flip()
			end
			reset_var()
			break
		end
		
	end
	
	// right card chosen
	
	if(select==1) then
		if(prompt==1) then
		con += 3
		lib -= 3
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -3 lib.   ", 70, 68,12)
			print("   +3 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
		
	if(prompt==2) then
		lib -=3
		con +=1
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -3 lib.   ", 70, 68,12)
			print("   +1 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==3) then
		lib +=1
		con -=2
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   +1 lib.   ", 70, 68,12)
			print("   -2 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==4) then
		lib -=1
		con +=3
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -1 lib.   ", 70, 68,12)
			print("   +3 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
		
		if(prompt==5) then
		lib -=2
		con +=1
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -2 lib.   ", 70, 68,12)
			print("   +1 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==6) then
		lib -=2
		con +=3
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -2 lib.   ", 70, 68,12)
			print("   +3 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==7) then
		lib -=1
		con +=1
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -1 lib.   ", 70, 68,12)
			print("   +1 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==8) then
		lib +=1
		con +=0
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   +1 lib.   ", 70, 68,12)
			print("   +0 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==9) then
		lib +=1
		con -=2
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   +1 lib.   ", 70, 68,12)
			print("   -2 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==10) then
		lib +=2
		con -=1
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   +2 lib.   ", 70, 68,12)
			print("   -1 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
	
	if(prompt==11) then
		lib -=2
		con +=2
		cls()
		h = 0
		while(h<50) do
			draw_hall()
			rectfill(68, 59, 122, 95, 7)
			print("   -2 lib.   ", 70, 68,12)
			print("   +2 con.   ", 70, 82,8)
			h+=1
			flip()
		end
		reset_var()
		break
	end
		
	end
end


end

end

if(go==1)then

	rectfill(0,0,128,128,4)
	spr(21,19,32)
	spr(22,29,33)
	spr(23,39,32)
	spr(55,49,33)
	spr(15,69,32)
	spr(112,79,33)
	spr(55,89,32)
	spr(113,99,32)

	print("your town lasted     days.",13,52,7)
	print(day,81,52,7)
	print("press — to restart",25 ,68,7)
	
	if(btn(—)) do
		sfx(6)
		_init()
	end
	
end

if(mode==0 and go==0) then
	h=0

bposx = 0
blayer = 24
bposy = 92
	for loop3=1,16 do
		spr(blayer, bposx - bxoffset/2, bposy)
		spr(blayer+1, bposx - bxoffset/2+8, bposy)
		spr(blayer+2, bposx - bxoffset/2+16, bposy)
		spr(blayer+3, bposx - bxoffset/2+24, bposy)
		spr(blayer+4, bposx - bxoffset/2+32, bposy)
		spr(blayer+5, bposx - bxoffset/2+40, bposy)
		bposx=bposx+48
		loop3=loop3+1
	end
bposy = 64
bposx = 0 
blayer = 59
loop3 = 1
loop4 = 1

blayer = 56
bposy = 56
	for loop3=1,8 do
		spr(blayer, bposx - bxoffset, bposy)
		spr(blayer+1, bposx - bxoffset+8, bposy)
		spr(blayer+2, bposx - bxoffset+16, bposy)
		bposx=bposx+48
		loop3=loop3+1
	end
bposy = 64
bposx = 0 
blayer = 59
loop3 = 1
loop4 = 1

for loop4= 1,5 do
	for loop3=1,7 do
		spr(blayer, bposx - bxoffset, bposy)
		spr(blayer+1, bposx - bxoffset+8, bposy)
		spr(blayer+2, bposx - bxoffset+16, bposy)
		bposx=bposx+48
		loop3=loop3+1
	end
	bposx=0
	loop4+=1
	bposy+=7
	blayer+=0
end
bposy = 30
bposx = 0 
blayer = 59
loop3 = 1
loop4 = 1

for loop2= 1, 4 do
	for loop=1,20 do
		spr(layer, posx - xoffset, posy)
		spr(layer+1, posx - xoffset+8, posy)
		posx=posx+16
		loop=loop+1
	end
	posx=0
	loop2+=1
	posy+=7
	layer+=2
	

cloop = 0
spr(1, bposx+48 - bxoffset*3, 95)
spr(3, bposx+106 - bxoffset*3, 95)
spr(2, bposx+164 - bxoffset*3, 95)
spr(6, bposx+222 - bxoffset*3, 95)

end

posy= 99
posx = 0
layer = 7
loop = 1
loop2 = 1
lloop = lib
addlib = 0
cloop = con
addcon = 0
for lib = 0, lib do
	spr(85, 40, 22-addlib)
	spr(86, 48, 22-addlib)
	addlib += 1
end


for con = 0, con do
	spr(101, 72, 22-addcon)
	spr(102, 80, 22-addcon)
	addcon += 1
end




print("liberal", 8, 18, 1)
print("liberal", 8, 17, 12)

print("conser-", 93, 14, 2)
print("conser-", 93, 13, 8)
print("vative", 93, 22, 2)
print("vative", 93, 21, 8)

spr(122, posx-xoffset+284, 92)
spr(121, posx-xoffset+276, 92)
spr(120, posx-xoffset+268, 92)
spr(119, posx-xoffset+260, 92)
spr(106, posx-xoffset+284, 86)
spr(105, posx-xoffset+276, 86)
spr(104, posx-xoffset+268, 86)
spr(103, posx-xoffset+260, 86)
spr(90, posx-xoffset+284, 78)
spr(89, posx-xoffset+276, 78)
spr(88, posx-xoffset+268, 78)
spr(87, posx-xoffset+260, 78)
spr(73, posx-xoffset+276, 70)
spr(72, posx-xoffset+268, 70)

	spr(ctype, playerx, playery)
	
if(xoffset>23 and xoffset<34) then
	spr(92, playerx, playery-10)
end

if(xoffset>57 and xoffset<68) then
	spr(92, playerx, playery-10)
end

if(xoffset>91 and xoffset<105) then
	spr(92, playerx, playery-10)
end

if(xoffset>125 and xoffset<139) then
	spr(92, playerx, playery-10)
end

if(xoffset>153 and xoffset<174) then
	spr(92, playerx, playery-10)
end

spr(64,5,50)
spr(65,13,50)
spr(65,21,50)
spr(66,29,50)
spr(96,5,58)
spr(97,13,58)
spr(97,21,58)
spr(98,29,58)
print("d   ",12,55,7)
print(" ay ",12,56,7)
print(day,27,55,7)


if(bubble4==1) then

	bubble1=0
	bubble2=0
	bubble3=0
	addamount=222

end

if(bubble3==1) then

	bubble1=0
	bubble2=0
	bubble4=0
	addamount=164

end

if(bubble2==1) then

	bubble4=0
	bubble3=0
	bubble1=0
	addamount=106

end

if(bubble1==1) then
	
	bubble4=0
	bubble3=0
	bubble2=0
	addamount=48

end

if(bubbleon==1) then
	spr(184, bposx+addamount - bxoffset*3, 85)
	spr(168, bposx+addamount - bxoffset*3, 77)
	spr(168, bposx+addamount-8 - bxoffset*3, 77)
	spr(168, bposx+addamount+8 - bxoffset*3, 77)
	spr(167, bposx+addamount-16 - bxoffset*3, 77)
	spr(169, bposx+addamount+16 - bxoffset*3, 77)
	spr(151, bposx+addamount-16 - bxoffset*3, 69)
	spr(152, bposx+addamount-8 - bxoffset*3, 69)
	spr(152, bposx+addamount - bxoffset*3, 69)
	spr(152, bposx+addamount+8 - bxoffset*3, 69)
	spr(153, bposx+addamount+16 - bxoffset*3, 69)
	spr(135, bposx+addamount-16 - bxoffset*3, 61)
	spr(136, bposx+addamount-8 - bxoffset*3, 61)
	spr(136, bposx+addamount - bxoffset*3, 61)
	spr(136, bposx+addamount+8 - bxoffset*3, 61)
	spr(137, bposx+addamount+16 - bxoffset*3, 61)

	if(bubble1==1) then
		if(talk1==1) then
			print("we need",bposx+addamount-13-bxoffset*3,64,1)
			print("to help",bposx+addamount-13-bxoffset*3,70,1)
			print("poor ppl.",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk1==2) then
			print("i am anti",bposx+addamount-13-bxoffset*3,64,1)
			print("choice!",bposx+addamount-13-bxoffset*3,70,1)
			print("its cruel",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk1==3) then
			print("abortion",bposx+addamount-13-bxoffset*3,64,1)
			print("shouldn't",bposx+addamount-13-bxoffset*3,70,1)
			print("b allowed",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk1==4) then
			print("the death",bposx+addamount-13-bxoffset*3,64,1)
			print("penalty",bposx+addamount-13-bxoffset*3,70,1)
			print("is just!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk1==5) then
			print("everyone",bposx+addamount-13-bxoffset*3,64,1)
			print("can carry",bposx+addamount-13-bxoffset*3,70,1)
			print("firearms!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk1==6) then
			print("coal and",bposx+addamount-13-bxoffset*3,64,1)
			print("oil are",bposx+addamount-13-bxoffset*3,70,1)
			print("important",bposx+addamount-13-bxoffset*3,76,1)
		end
	end
	
	if(bubble2==1) then
		if(talk2==1) then
			print("we need",bposx+addamount-13-bxoffset*3,64,1)
			print("to help",bposx+addamount-13-bxoffset*3,70,1)
			print("poor ppl.",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk2==2) then
			print("i am anti",bposx+addamount-13-bxoffset*3,64,1)
			print("choice!",bposx+addamount-13-bxoffset*3,70,1)
			print("its cruel",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk2==3) then
			print("abortion",bposx+addamount-13-bxoffset*3,64,1)
			print("shouldn't",bposx+addamount-13-bxoffset*3,70,1)
			print("b allowed",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk2==4) then
			print("the death",bposx+addamount-13-bxoffset*3,64,1)
			print("penalty",bposx+addamount-13-bxoffset*3,70,1)
			print("is just!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk2==5) then
			print("everyone",bposx+addamount-13-bxoffset*3,64,1)
			print("can carry",bposx+addamount-13-bxoffset*3,70,1)
			print("firearms!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk2==6) then
			print("coal and",bposx+addamount-13-bxoffset*3,64,1)
			print("oil are",bposx+addamount-13-bxoffset*3,70,1)
			print("important",bposx+addamount-13-bxoffset*3,76,1)
		end
	end
	
	if(bubble3==1) then
		if(talk3==1) then
			print("poor ppl.",bposx+addamount-13-bxoffset*3,64,1)
			print("dont have",bposx+addamount-13-bxoffset*3,70,1)
			print("it hard.",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk3==2) then
			print("i am pro",bposx+addamount-13-bxoffset*3,64,1)
			print("choice!",bposx+addamount-13-bxoffset*3,70,1)
			print("",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk3==3) then
			print("abortion ",bposx+addamount-13-bxoffset*3,64,1)
			print("should be",bposx+addamount-13-bxoffset*3,70,1)
			print("allowed!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk3==4) then
			print("terrorism",bposx+addamount-13-bxoffset*3,64,1)
			print("needs to ",bposx+addamount-13-bxoffset*3,70,1)
			print("b stopped",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk3==5) then
			print("the death",bposx+addamount-13-bxoffset*3,64,1)
			print("penalty",bposx+addamount-13-bxoffset*3,70,1)
			print("is cruel!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk3==6) then
			print("we suport",bposx+addamount-13-bxoffset*3,64,1)
			print("lgbtq+",bposx+addamount-13-bxoffset*3,70,1)
			print("rights!",bposx+addamount-13-bxoffset*3,76,1)
		end
	end
	
	if(bubble4==1) then
		if(talk4==1) then
			print("poor ppl.",bposx+addamount-13-bxoffset*3,64,1)
			print("dont have",bposx+addamount-13-bxoffset*3,70,1)
			print("it hard.",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk4==2) then
			print("i am pro",bposx+addamount-13-bxoffset*3,64,1)
			print("choice!",bposx+addamount-13-bxoffset*3,70,1)
			print("",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk4==3) then
			print("abortion",bposx+addamount-13-bxoffset*3,64,1)
			print("should be",bposx+addamount-13-bxoffset*3,70,1)
			print("allowed!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk4==4) then
			print("terrorism",bposx+addamount-13-bxoffset*3,64,1)
			print("needs to ",bposx+addamount-13-bxoffset*3,70,1)
			print("b stopped",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk4==5) then
			print("the death",bposx+addamount-13-bxoffset*3,64,1)
			print("penalty",bposx+addamount-13-bxoffset*3,70,1)
			print("is cruel!",bposx+addamount-13-bxoffset*3,76,1)
		end
		if(talk4==6) then
			print("we suport",bposx+addamount-13-bxoffset*3,64,1)
			print("lgbtq+",bposx+addamount-13-bxoffset*3,70,1)
			print("rights!",bposx+addamount-13-bxoffset*3,76,1)
		end
	end
	

end

end

end

function game_over()
	sfx(5)
	go = 1
end
__gfx__
000000000055dd0000224400002244000055dd00002244000055dd000000000000000000bb33bbbb33333bbba999999999999999dd59944445444d1400677700
0000000000222200009999000099990000222200009999000022220055555555555555553344333355533bb3994a99999499994941d491541d49444406777770
0070070000544500005ff500905ff50f40544504005ff50000544500666666666666666644999444444333b399aaa9999a99999a444444d44444445467770677
0007700000244400009fff00089fff800d2444d0009fff00002444001111115111111115999999999994433449994a499aa449aa545445445444445467700067
00077000488888849ddddddf0088880000dddd000088880000dddd00d67dddddd7667ddd99999999999994494499a4a949944999654451445544555567700067
00700700008eee0000dccc00008eee0000dccc00088eee800ddcccd0555551115555111599999a449999999944999a99449949491554514445445d6567770677
0000000000222200001111000022220000111100f022220f40111104aaaaabbbbbaaaaaaa44999aaaa9994999d94999d4dd94449d14554545555511506777770
000000000020080000100d000020080000100d000020080000100d00babbaaab3bbbbbabaaa9aa999aa99aa99d44494d44dd9549555555555555d55500677700
dccccccd000ba0001111111dc66c666c1111111100677700000670006770007700000000000000000000555555550000000000000000000088dddddddddddd88
cccccdcc0333baa01dddddd6cc66666611111111067777700006700067770777000000000000555555551d1d1d1d555555550000000000009988dcdddddd8899
cdcccccc03333ba01d111dd6666c6c66111111116770000000677700677777770000555555551d1d1d1d161616161d1d1d1d55555555000099998dddddd89999
cccdcccc333b3bba1d1006d66666666cd1d1d1d167006777006707006776767755551d1d1d1d1616161655555555161616161d1d1d1d5555aa9998cddd8999aa
cccccdcc33bb3bba1d1006d66c6666661d1d1d1d6700677706770770677006771d1d1616161655555555d1dd1dd155555555161616161d1daaaa998cd899aaaa
dccccccc33333bba1dd666d666666666dddddddd677006770677777067700677161655555555dd1dd1dd1d61d61dd1dd1dd155555555161677aa998cd899aa77
cccccccc033bbba01dddddd6666666c6dddddddd06777770677006776770067755551dd1dd1d61d61d61d61d61d61d61d61dd1dd1dd15555777aa998899aa777
cccccccc00000000d666666666666666dddddddd0067770067700677677006771dd1d61d61d61d61d61d61d61d61d61d61d61d61661dd1dd777aa998899aa777
00999900009999000099990000999900009999000099990000999900009999000099990000999900009999000099990000999900009999000099990000999900
0095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f5000095f500
009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00009fff00
0dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd00dddddd0
0ddd66d00ddd66d00ddd66d00ddd66d00ddd66d00ddd66d00ddd66d00ddd66d0d0dd66d0d0dd66d0d0dd66d0d0dd66d0d0dd66d0d0dd66d0d0dd66d0d0dd66d0
09fd669009fd669009fd669009fd669009fd669009fd669009fd669009fd669090dd660990dd660990dd660990dd660990dd660990dd660990dd660990dd6609
00115500001155000011550000115500001155000011550000115500001155000111555001115550011155500111555001115550011155500111555001115550
00115500001155000011550000115500001155000011550000115500001155000110055001100550011005500110055001100550011005500110055001100550
ccccccccc6ccc6c666666666ccccccccddddddddcdddddcddddddddd677777770000000000000000000000005d67777667777776666666d5899aa777777aa998
cccccccccccccccc66666666ccccccccddddddddddcddddddddddddd677777770000000000000000000000005d71111771111117611116d5899aa777777aa998
cccccccc6ccc6cc666666666ccccccccdddddddddddddddcddddddcd677700000000000000000000000000005d71cd1771ccdd1761cd16d5c899aa7777aa998d
cccccccccc6ccccc66666666cccc6cccddddddddcdddcddddddddddd677777000000000000000000000000005d71cd1771ccdd1761cd16d5d899aaaaaaaa998c
cccccccc6cc6c66c66666666ccccccccdddddddddddcccdcddcddddd677777000055555555555555555555005d71cd1771ccdd1761cd16d5cc8999aaaa9998dc
cccccccc6cc66ccc66666666c6ccccccddddddddddcddcccdddddddd67770000051d16d116d1d1611d6d1d505d65115665111156651156d5cdc8999999998ccc
cccccccc666cc6c666666666ccccc6c6ddddddddcccccccdddddcddd677777775555555555555555555555555d65555665555556655556d5cccd88999988cccd
ccccccccc66c66cc666666666cc6ccccddddddddcdccdccccddddddc677777775d6dd66dd6dd666dd66dd6d55d6dddd66dddddd66dddd6d5dccccc8888cccdcc
d55555555555555555555551d1111111111111150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d1111111111111111111115fd5555555555555100000000000000000000000000000004d1000000000000000000000000000000000000000000000000000000
7f5454545454545454545415f71414141414145100000000000000000000000000000004d1dd8800000000000000000000000000000000000000000000000000
7f4545454545454545454515f74141414141415100000000000000000000000000000004d1dd7700000000000000000000000000000000000000000000000000
7f4444444444444444445415f7141414141414510000000000000000000000000000000476dd8800000000000000000000000000000000000000000000000000
7f4444444444444444444515f7414141414141510000000000000000000000000000000482777700000000000000000000000000000000000000000000000000
7f4444444444444444445415f7141414141414510000000000000000000000000000000400888800000000000000000000000000000000000000000000000000
7f4444444444444444444515f7414141414141510000000000000000000000000000000400000000000000000000000000000000000000000000000000000000
7f4444444444444444445415f7141414141414510000000000000000000000000000000400000000000000000000000000077000000000000000000000000000
7f4444444444444444444515f74141414141415100000000000000000000000000d6666d66666d0000000000000000000075d700000000000000000000000000
7f4444444444444444445415f714141414141451000000000000000000000000ddd6777667776ddd000000000000000007555d70000000000000000000000000
7f4444444444444444444515f741414141414151000000000000000000000000d6ddddd1111ddd6d0000000000000000755555d7000000000000000000000000
7f4444444444444444445415f714141414141451000000000000000000000000d6d6666dddd66d6d00000000000000007775d777000000000000000000000000
7f4444444444444444444515f741414141414151000000000000000000000006666677777667666660000000000000000075d700000000000000000000000000
7f4444444444444444445415f714141414141451000000000000000000000777777777777777777777700000000000000075d700000000000000000000000000
7f4444444444444444444515f74141414141415100ddccccccccdd00000666666666666666666666666660000000000000777700000000000000000000000000
7f4444444444444444445415f71414141414145100000000000000000000001d5551d555555d1555d10000000000000000000000000000000000000000000000
7f4444444444444444444515f7414141414141510000000000000000000000d6555d65555556d5556d0000000000000000000000000000000000000000000000
7f4444444444444444445415f7141414141414510000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
7f4444444444444444444515f7414141414141510000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
7f4444444444444444445415f7141414141414510000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
7f4444444444444444444515f7414141414141510000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
7fffffffffffffffffffffd5f7777777777777d10000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
f7777777777777777777777d7ffffffffffffffd0022888888882200000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
67700077677777700000000000000000000000000000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
67700077677777770000000000000000000000000000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
06770770677006770000000000000000000000000000000000000000000000675d5675dddd5765d5760000000000000000000000000000000000000000000000
06770770677067770000000000000000000000000000000000000000000000675556755555576555760000000000000000000000000000000000000000000000
00677700677777700000000000000000000000000000000000000000000666116661166666611666116660000000000000000000000000000000000000000000
0067770067777700000000000000000000000000000000000000000000677dd7777dd777777dd7777dd776000000000000000000000000000000000000000000
00067000677067700000000000000000000000000000000000000000066611666611666666661166661166600000000000000000000000000000000000000000
00067000677006770000000000000000000000000000000000000000677dd77777dd77777777dd77777dd7760000000000000000000000000000000000000000
00000000000005555555555555500000225522524494f9444494f944000006666666666666600000000000000000000000000000000000000000000000000000
00000000000555555555555555555000552552254494f9444494f944000666667777777777777000000000000000000000000000000000000000000000000000
00000000005555dddddddddddd5555004494f9444494f9444494f944006667777777777777777700000000000000000000000000000000000000000000000000
000000000555dddddddddddddddd55504494f9444494f9444494f944066677777777777777777770000000000000000000000000000000000000000000000000
00000000055dcdcdcddcdcdcdcdcd5504494f9444494f9444494f944066777777777777777777770000000000000000000000000000000000000000000000000
00000000555cccdccccdcccccdccc5554494f9444494f9445499f944667777777777777777777777000000000000000000000000000000000000000000000000
0000000055ccdcccdcccccccccccdc554494f9444494f94409900444667777777777777777777777000000000000000000000000000000000000000000000000
0000000055cccccccccccddcdccccc554494f9444494f94400000000667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbbbbbbbbbbbbbbbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
00000000553bbbb3bbb3bbbb3bbbbb5555cccccccccccccccccccc55667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbb3bb3bbbbb3bbb3b3b55556cccccccc6cccccccc6655667777777777777777777777000000000000000000000000000000000000000000000000
0000000055bbbb3bbbbbbbbbb333335555b6c6c6cccccc6ccc6ccb55667777777777777777777777000000000000000000000000000000000000000000000000
00000000553b3bbbbb3b3bbb3333335555b6c66c6c6c6ccc66bbbb55066777777777777777777770000000000000000000000000000000000000000000000000
000000005533b3b3b3b3b3b33333335555bbbbbbbbbb6666bbbbbb55066677777777777777777770000000000000000000000000000000000000000000000000
0000000055333333333333333333335555bbbbbbbbbbb66bbbbbbb55006667777777777777777700000000000000000000000000000000000000000000000000
0000000055333333333333333333335555bbbbbbbbbbbbbbbbbbbb55000666667777777777777000000000000000000000000000000000000000000000000000
0000000055333333333333333333335555bbbbbbbbbbbbbbbbbbbb55000006666666666666600000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000066666000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000067777000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000006770000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000006770000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000006770000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355553333333333333333333355000000000000600000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355555555555555555555555555000000000000600000000000000000000000000000000000000000000000000000000000
00000000553333333333333333333355555555555555555555555555000000000000600000000000000000000000000000000000000000000000000000000000
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
55555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5aaaaaaa555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
afffffffaaaaaaaa5555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff555555ffffffffaaaaa55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5566666655555555fffffa5555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666166666666666555fffaaaaaaa555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111c111111116666665555f55fffaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccddccdc111166666665565555ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccdcccccdc1111111116666655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccdddddddcc1111166000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ccccccccccccccccccccccccccddd11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccddd4ccccccccccccccccccccdd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccddccc4444ccccccccc444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccddd44ccc4dddcccccdcccccccc4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd444444ccdddcccc44cccccccc44c44000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444ccccccccc444ccccddddddcccddc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccc444ccccccddddddccdddccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccc4444444cccccccddcc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccc44cccccc44000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccccccdcccdcccccccc444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4041414141414141414141414141414200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151434451514344515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151535451515354515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151636451516364515151515200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061616161616161616161616161616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36363636363636363636363636361f1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
35353535353535353535353535353e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323232323232323232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3232323232323232323232323232323200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000003738373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000e0100961008610096100e0101230013600180001b1001060700200007001020700000007000240702400024070240023300233002330024300233002330023300233002330021300003000000000000
00020000036500765008250092500b2500d250102501225015250192501d250232502b55039550332000020000200002000020000600002000020000100002000020000200002000020000200002000020000200
000700001435018350153000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002660021210202201e6301b640186501665013650116500e6500a650072500325000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001610026200362003550045500455005550065500755008550095500a5500b5500c5500d5500e5500f550105501255013550155501655018550195501a5501c5501e5501f55021550226202462025610
001e00000b350103501635014300123500a350073500b3500145001400014500a4000145001450044000145005400054000630007300093000b3000c3000e300103001230013300153001730018300193001a300
00060000223501d250233501e250233501e250233501e250233500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000e0501065011650106500e0501230013600180001b1001060700200007001020700000007000240702400024070240023300233002330024300233002330023300233002330021300003000000000000
00020000202101c61019220176201622016620152201562016220156201522016620192201d610202100050000500005000070000100001000010000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
