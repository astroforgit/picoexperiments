pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--space tavern poker
--by @aplundell
--v1.3

options={}
options.highvizcards=false
options.sounds=true

--data
card_colors={ {13,6},{8,14},{0,5},{3,11}}
rank_abbr={"a","2","3","4","5","6","7","8","9","10","j","q","k"}
hand_name={"high card","pair","two pair", "three of a kind", "straight", "flush", "full house", "four of a kind", "straight flush", "royal flush" }
royal_straight=0x100f
ace_low_straight=0x1f

snd_deal=2
snd_pass=3
snd_fold=8
snd_coin=5
snd_win=9
snd_bust=7

qsprt=129
tensprt=128

backs=134

app_state=0 
hand_state=0
next_state=-1
state_fade=-1


deal_delay=11
bet_delay=25
bets_this_round=0

return_to_main_pending=false

part_stagger=2
part_speed=7
-- card data
-- c.r		: 1-13  a-k
-- c.s  : 1-4
-- drop,diamond,spade,planet
board={}

player={}
pros={ {},{},{} }
players={player,pros[1],pros[2],pros[3]}


prox={10,52,94}
dealer_token_pos={ {118,90},{5,6},{45,6},{84,6} } 

tut_seen_key=0

dealer=1
better=2

deck={}

rules={}


pot={}

--popup message
pm={}
pm.visible=false
pm.inst=""
pm.y=-100


bubble_timer={0,0,0}
bubble_msg={1,1,1}

function _init()
	cartdata("spacetavern5__aplundell__v001")
	
	play_count=dget(0) + 1
	dset(0,play_count)
	
	if(play_count<=1) then
		reset_player()
	else
		load_player()
	end	
	
	player_set_functions(player)

 build_keys()
	
	menuitem(3,"reset data", function()
	dialog(" are you sure you want to \n    delete all of your\n     cash and ships?",
		function()
			reset_player()
			fade_to_state(0)
		end,
		nil)
	
	end)
	
	sndfunc= function() 
		local s="sound: off"
		if(options.sounds)s="sound: on"
		menuitem(1,s, function() options.sounds= not options.sounds;sndfunc() end )
	end
	sndfunc()
	hvfunc= function() 
		local s="hi-vis cards:off"
		if(options.highvizcards)s="hi-vis cards: on"
		menuitem(2,s, function() options.highvizcards= not options.highvizcards;hvfunc() end )
	end
	hvfunc()
	
	set_app_state(0)	
end

function _update()
	if(pm.visible) then
		if(btnp(4))then
		 pm.visible=false
		 if(pm.is_dialog and pm.sel and pm.y_func !=nil ) pm.y_func()
		 if(pm.is_dialog and not pm.sel and pm.n_func!=nil) pm.n_func()
		 if(pm.betship) then 
		 	k=my_keys[pm.keynum]
		 	player.inven[k.id]-=1
				pm.betship=false		 	
		 	build_keys()
				add(pot.items,k.id)
				player.keyin=true
		 	next_better()
		 end
		end
		if(btnp(0)) then pm.sel=true; pm.keynum -=1 end
		if(btnp(1)) then pm.sel=false; pm.keynum += 1 end
		pm.keynum=min(#my_keys,max(1,pm.keynum))
		return
	end

	--fade
 if(next_state>=0) then
 	state_fade+=1
 	if(state_fade>8) set_app_state(next_state)
 	return
	elseif(state_fade>=0) then
		state_fade-=1
		return
	end


	if(app_state==0) update_main()
	if(app_state==10) update_table()
	if(app_state==20) update_inven()
	
	--add entropy to rand.
	game_tick+=1
	for ii=0,5 do
		if(btnp(ii))	srand( rnd(32767) * game_tick+ii)
	end	
end
function _draw()
	reset_pal()
	if(app_state==0) draw_main()
 if(app_state==10) draw_table()
 if(app_state==20) draw_inven()
 
 draw_popup()
 
 if(state_fade>=0) fade(state_fade)
end

function fade_to_state(x)
	next_state=x
	state_fade=0
end

function set_app_state(x)
	if(x==0)start_main()
	if(x==10)start_table()
	if(x==20)start_inven()
	
	hilighted_hand=nil
	save_player()	
	app_state=x
	next_state=-1
end
function draw_popup()
	reset_pal();palt(14,true);
	local cx=64
	local cy=64+pm.y
	local w=14
	local h=5
	map(1,17,cx-(4*w),cy-(4*h) ,w,h)
	print(pm.msg,cx+5-(4*w), cy+8-(4*h), 11)
	print(pm.inst,cx-4+4*w-4*#(pm.inst) ,cy-9+(4*h),0)
	if(pm.is_dialog)then
		cy+=8
		spr(174,cx+pm.x-8,cy,2,1)
	
		spr(142,cx-32-8,cy,2,1)
		spr(158,cx+32-8,cy,2,1)
		
		local target=32
		if(pm.sel)target=-32
		local d=target-pm.x
		pm.x += d/3.5
		if(abs(d)<4) pm.x=target
	end
	if(pm.betship)then
			draw_key_big(my_keys[pm.keynum],22,pm.y+48)
			print("ã       ë",13,pm.y+63,11)
	end
	
	if(pm.visible) then
		pm.y -= pm.y/3.5
		if(abs(pm.y)<4) pm.y=0
	else
		pm.y += min(-5,pm.y/3.5)
		pm.y = max(-100,pm.y)
	end
end

function popup(str)
	pm.visible=true
	pm.msg=str
	pm.is_dialog=false
	pm.inst="press é to continue "
	pm.betship=false
end
function dialog(str, y_func, n_func, dflt)
	popup(str)
	pm.inst=""
	pm.is_dialog=true
	pm.y_func=y_func
	pm.n_func=n_func
	pm.sel=dflt
	pm.x=0
end
function ship_dlg()
	popup("           choose a ship\n           to bet.")
	pm.inst=""
	pm.betship=true
	pm.keynum=1
end
function start_table()
	dealer=flr(1+rnd(4))
	set_phase(0)
end

hilighted_hand=nil
time_since_winner_blink=0
show_menu=false
function draw_table()
	palt(14,true)
	cls(0)
	
	--frames
	palt(0,false)
	map(1,5,8,50,14,4)
	map(0,1,0,12,16,3)
 if(show_menu) map(1,10,4,94,7,4)

	draw_stars()

	hilighted_hand=nil

	--blink timer
	if(player.eval!=nil) then
		if(current_hi_winner==nil)	current_hi_winner=0
		if(time_since_winner_blink>15) then
			current_hi_winner = (current_hi_winner+1)%4
			time_since_winner_blink=0
		end	
		for ii=0,3 do
			current_hi_winner = (current_hi_winner+ii)%4
			local p = nil
			if(current_hi_winner==0) then p=player else p=pros[current_hi_winner] end
			if(p.lose==0 ) then
				hilighted_hand=p.eval.best_hand
				break
			end
		end
	end
	time_since_winner_blink+=1
	

	
	--board
	for ii=1,#board do
			draw_card(board[ii], 18+16*ii,58)
	end
	
	--player's  hand
	if(player.folded==false) then
		for ii=1,#player.hand do
				draw_big_card(player.hand[ii], 38+26*ii,90)
		end
	end
	
	if(player.totalbet>0) printctr("($"..player.totalbet..")", 90, 83,13) 	
	
	draw_pot()
	
	printctr("$"..player:cash_str(), 32,88,6) 
	
	if(show_menu) draw_menu()
	
	
	if(hand_state>=9 and player.lose==0)then
		printctr(hand_name[flr(player.eval.hand)], 80, 122,11-player.lose*3) 	
	end

 --enemy
 for ii=1,3 do
 	if(inhand(pros[ii]))then
 		for jj=1,#(pros[ii].hand) do
	 		draw_card(pros[ii].hand[jj], prox[ii]+8*(jj-1), 16, hand_state!=9)
	  end 
 	end 

	 local yoff=(ii==2) and 1 or 0
	 local c=7
	 
	 if(isbusted(pros[ii])) then
	 	c=5
	 else
			printctr( "$"..pros[ii]:cash_str(), prox[ii]+12, 6+yoff, 6)
			--bet so far
			if(pros[ii].totalbet>0)printctr("($"..pros[ii].totalbet..")", prox[ii]+12, 42,13) 	
		end	
	 
		printctr( pros[ii].name, prox[ii] +12+ 0 * (ii), 0+yoff, c)
		
		draw_bubble(ii)

		if(hand_state>=9)then
			if(pros[ii].lose==0)then
				printctr(hand_name[flr(pros[ii].eval.hand)], prox[ii]+12, 36,11-pros[ii].lose*3) 	
			end
		end
	
	end

	--dealer
	palt(14,true)
	spr(24, dealer_token_pos[dealer][1],dealer_token_pos[dealer][2])

	draw_parts()
end


fxstars={}
function draw_stars()
	if(#fxstars<1) then
		for ii=1,50 do
			s={}
			s.x=rnd(128); s.y=rnd(128)
			s.dx=rnd(2); s.dy=s.dx
			add(fxstars,s)
		end
	end
	
	foreach(fxstars, function(s)
		local col=6
		local c=pget(flr(s.x),flr(s.y))
		if(c==1) col=13
		if(c==2) col=14
		if(c <= 20)then
			pset(flr(s.x),flr(s.y),col)
			s.x=(s.x+s.dx)%130 --intentionally
			s.y=(s.y+s.dy)%160 --not 128
		end
	end)
end

menu={}
menu.selected=1
menu.step=0.05
menu.bar=0.5
menu.bet=42
menu.minbet=0
menu.maxbet=50
menu.canbet=true
menu.betship=false

function draw_menu()
	local x=12
	local y=97
	
	palt();palt(14,true)

 map(2,9,x,y,5,1)
	spr(27,x-2 + menu.bar * 40,y+2)
 print("ã        ë", x-4,y+6,6)  	
	
	local betword="raise"
	if(menu.bar==0) betword="call"
	if(menu.betship) betword="bet ship"
	if(menu.selected==1) then	
		print("è"..betword, x,y+12,7)
	else
		local c = 6
		if(not menu.canbet) c=5
		print("  "..betword, x,y+12,c)
	end
	local password="pass"
	if(menu.minbet>0) password="fold"
	if(menu.selected==2) then
		print("è"..password, x, y+18,7)
	else
		print("  "..password, x, y+18,6)
	end
		
	printctr("$"..menu.bet,x+20,y+6,6) 
end
function update_menu()
	if(menu.canbet and not menu.betship)then
		if(btn(0)) menu.bar -= menu.step
		if(btn(1)) menu.bar += menu.step
	end
	menu.bar = min(1, max(0, menu.bar))
	menu.bet = menu.minbet
	menu.bet +=flr( menu.bar * (menu.maxbet-menu.minbet) )
	
	if(btn(2)) menu.selected=1
	if(btn(3)) menu.selected=2
	if(btn(0)or btn(1)) menu.selected=1
	
 if(not menu.canbet) menu.selected=2
 if(menu.bet==0) menu.selected=2

 if(btnp(4)) then
 	if(menu.selected==1) then
 		--bet
 		if(menu.canbet) then
 			if(menu.betship) then
 				bet_my_ship()
	 		elseif(menu.bet<=0) then pass(player)
	 		else place_bet(player, menu.bet) end
	 	end
 	else
 		--dont bet
 		if(menu.minbet<=0) then pass(player)
 		else fold(player) end
 	end
 end
end

function bet_my_ship()
	ship_dlg()
end

function is_hilighted(c)
	if(hilighted_hand==nil) return false
	for ii=1,#hilighted_hand do
		if(hilighted_hand[ii].s == c.s and hilighted_hand[ii].r == c.r ) then
			return true
		end
	end
	return false
end	

function draw_card(c,x,y, hide)
	if(hide==nil)hide=false
 reset_pal(); palt(14,true)
	
	if(is_hilighted(c)) pal(7,15)
	
	if(hide)then
		spr(backs,x,y,2,2)	
	else
		spr(44,x,y,2,2)
		palt(7,true);
		suit_color(c.s)
		if(options.highvizcards) then
			--hivis
		spr(15+c.s,x+8,y+2)
			if(c.r!=10 and c.r!=12)print(rank_abbr[c.r],x+4,y+6,card_colors[c.s][1])
			if(c.r==10)spr(tensprt,x+4,y+6)
			if(c.r==12)spr(qsprt,x+4,y+6)
		else
			--"realistic"
			spr(15+c.s,x+3,y+2)
			spr(2+(c.r-2)%13,x+3,y+1)
			spr(63+c.r,x+8,y+6) --pips
		end
	end
	reset_pal()
end
function draw_big_card(c,x,y)
	reset_pal();palt(14,true)
	
	if(is_hilighted(c)) pal(7,15)
	
	spr(77,x,y,3,4)
	spr(19+c.s, x+2, y+10)
	suit_color(c.s)
	if(c.r==12)then
		spr(qsprt,x+4,y+3)
	else
		print(rank_abbr[c.r], x+4,y+3,0)
	end
	reset_pal()
end
function suit_color(s)
	pal(0,card_colors[s][1])
	pal(5,card_colors[s][2])
end

function draw_pot()
	local s=32

	local c=pot.display_cash
	palt();palt(0,true)
	
	--one token for variety
	if(c>=1) then
		local x=pot.rand%16
		local y=flr(pot.rand/100)%15
		s=25+ flr(pot.rand/32)%4
		spr(s,16+x,56+y)
	end
	if(c>rules.sblind) then
		s=32 + 2*flr(4*c/(rules.max_bet*5))  
		s=min(s,42)
		spr(s,16,56,2,2,0==pot.rand%2, 0==((flr(pot.rand/10)%2)))
	end
	
	for i=1,#pot.items do
		draw_key_small(all_keys[pot.items[i]],12,48+i*8)
	end
	
	printctr("$"..pot:cash_safe(), 24,73,12)
end


function draw_bubble(bot)
	if( bubble_timer[bot] <= 0 ) return
	local x = prox[bot] + 8
	local y = 28
	local m = 115+2*bubble_msg[bot]
	if(5==bubble_msg[bot])m=165
	palt(14,true)
	palt(0, false)
	spr(83,x,y,2,2)
	spr(m, x,5+y,2,1) 
	
	bubble_timer[bot]-=1
end
function show_bubble(bot,msg)
	if(bot<0) return
	bubble_timer[bot]=45
	bubble_msg[bot]=msg
end
function bubbles_done()
	return( bubble_timer[1]+bubble_timer[2]+bubble_timer[3] == 0 )
end


function rnd_card()
	return card(cel(rnd(13)),cel(rnd(4)))
end
function sim_one(p)
	local missing_boaad = 5-#board
	local sim_board={}
	for ii=1,missing_boaad do
		add(sim_board,rnd_card())
	end
	
	local their_hand={rnd_card(),rnd_card()}
	local my_eval = eval( tblmrg(p.hand, sim_board))
	local their_eval = eval(tblmrg(their_hand, sim_board))
	
 local result = compare_hand_evals(my_eval,their_eval)	
	if( result <= 0 ) return true
	return false
end

function tblmrg(a,b)
	local out={}
	for v in all(a) do add(out,v) end
	for v in all(b) do add(out,v) end
	return out
end
function reset_sim()
	for ii=1, #pros do
		pros[ii].ai_trials = 0
		pros[ii].ai_victories=0
	end
end

function mv_card_from_set(oldhand,newhand, r,s, count)
	if(r!=nil and r>13) then r -= 13
	elseif(r!=nil and r<1) then r+=13 end
	for c in all(oldhand) do
		if(count<1) break
		if( (r==nil or c.r == r) and
		    (s==nil or c.s == s) ) then
				add(newhand, c)
				del(oldhand, c)
				count-=1
			end
	end
end

function do_sims()
	for ii = 1,#pros do
		if( pros[ii] != nil and #pros[ii].hand>=2) then
			if( pros[ii].folded == false and pros[ii].ai_trials<30000 ) then
				pros[ii].ai_trials += 1 
				if( sim_one(pros[ii]) ) pros[ii].ai_victories += 1
			end
		end
	end
end

function non_folded_players()
	local out = 0
	foreach(pros, function(p) if(not inhand(p)) then out+=1; end end)
	if( player.folded == false ) out+=1
	return out
end
function non_busted_players()
	local out=4
	foreach(pros, function(p) if(isbusted(p)) then out-=1; end end)	
	return out
end
function get_confidence(p)
	if( p.ai_trials <=0 ) return 0
	return (p.ai_victories / p.ai_trials) ^ (non_busted_players()-1)
	--why non-busted and not non-folded?
	--montey hall problem.
	--cards dont get better when
	--someone folds.
end


function mask_to_high_card(mask)
	if( mask == 0) return 0
	--ace = 1
	if( band(mask, 0x1000 )!=0 ) return 1
	--king = 13
	if( band(mask, 0x0001 )!=0 ) return 13
	--else bitshift and recurse
	return mask_to_high_card(mask/2) - 1
end
	
function card(r,s)
	local c={}
	c.r=max(min(r,13),1); 
	c.s=max(min(s,4),1);
	return c
end

function build_deck()
	local ii=1
	for ss=1,4 do
	 for rr=1,13 do
	 	deck[ii] = card(rr,ss)
	 	ii+=1
	 end
	end
end
function deal()
	n=1+flr(rnd(#deck))
	local c=deck[n]
	del(deck,c)
	mysfx(snd_deal)
	cards_dealt+=1
	return c
end

function eval(h)
 out = 1 --nothing hand
	local scount={0,0,0,0}
	local sbits={0,0,0,0}
	local low_ace = false
	local unused_cards={}
	local used_cards={}
	
	local func =
	 function(c)
		scount[c.s]+=1		
		local bit = shl(1,13-c.r)
		sbits[c.s]= bor(sbits[c.s],bit)
		add(unused_cards,c)
	end
	foreach(h,func)
	foreach(board,func)
	
	--local util
	local ace=0x1000
	local highest_rank = 
		function(mask, ignore)
			if(ignore==nil) ignore=0
			local tmp = bxor(mask,ignore)
			if(band(tmp,ace)==ace) return ace
			return band(tmp,-tmp)
		end
	local use_rank =
		function(rmask,count) 
			mv_card_from_set(unused_cards,used_cards, mask_to_high_card(rmask), nil, count)
		end
	local use_card =
		function(r,s, count)
			mv_card_from_set(unused_cards,used_cards, r, s, count)
		end
	local use_straight = 
		function(hi, suit)
			local h=mask_to_high_card(hi)
			for ii = 0,4 do
				use_card(h-ii, suit,1)
			end
		end
	
	local single=0
	local pair=0
	local triple=0
	local four=0
	
	for ss=1,4 do
		four=bor(four,band(triple,sbits[ss]))
		triple=bor(triple,band(pair,sbits[ss]))
		pair=bor(pair,band(single,sbits[ss]))
		single=bor(single,sbits[ss])
	end
	
	local high_card=0
	local scnd_card=nil
	local flush_suit = nil
	
	-- pair 2
		-- two pair - 3	
	if(pair ~= 0)then
	 out=2
	 
	 high_card=highest_rank(pair)
	 scnd_card=highest_rank(pair,high_card)
	 
	 if( scnd_card ~=0 ) then 
			out=3
		end
	end

	
	-- three of a kind 4
	if(triple ~= 0) then
	 out=4
	 high_card=highest_rank(triple)
 end

	-- straight=5
	local has_straight=false
	if( band(royal_straight,single)==royal_straight) then
		out=5
		has_straight=true
		high_card=ace
	else
		local tmp=single
		 local shift=1
		for ii=1,3 do
		 shift*=band(tmp,-tmp)
			tmp=tmp/band(tmp,-tmp)
			if(tmp<=1) break
			if(ace_low_straight==band(tmp,ace_low_straight)) then
				out=5
				has_straight=true
				
				high_card=shift
				
				--check for straight flush
				for ii=1,4 do
					local strt=ace_low_straight*max(shift,1)
					if( band(sbits[ii],strt)==strt ) then
						out=9
						high_card=shift
						flush_suit=ii
						break
					end
				end
				if(out==9) break;
				
			end
			tmp=bxor(tmp,1)
		end
		
	end
	
	--royal flush - 10	
	if(out == 9) then
			if( high_card==0 ) out=10
	end
	
	
	--flush 6
	if( out<9 ) then
		for ii=1,4 do
		 if(scount[ii]>=5) then
		  out=6
		  high_card=highest_rank(sbits[ii])
		  flush_suit=ii
		 end 
		end
	
		--fullhouse 7	
		if( triple~=0 ) then
			if( bxor(triple,pair) ~= 0 ) then 
				out=7
				high_card=highest_rank(triple)
				scnd_card=highest_rank(pair, high_card)
			end
 	end
 
		--four of a kind 8 
		if(four ~= 0) then
		 out = 8
		 high_card=highest_rank(four)
		end
	end

 --handle low aces
	if( has_straight ) then
		if( ace_low_straight==band(single,ace_low_straight)) then
			low_ace=true
		end
	end
	
	if( low_ace == false ) then
		if( high_card==4096 ) hich_card=0
		if( scnd_card==4096 ) scnd_card=0
	end
	
	if( out == 9 or out== 10 ) then
			use_straight(high_card,flush_suit)
	elseif( out == 8 ) then --4kind
		use_rank(high_card,4)
	elseif( out == 7 ) then --fhouse
		use_rank(scnd_card,2)
		use_rank(high_card,3)		
	elseif( out == 6 ) then --flush
			use_card(nil, flush_suit, 5)
	elseif( out == 5 ) then --straight
			use_straight(high_card)
	elseif (out == 4 ) then --3kind
		 use_rank(high_card,3)
	elseif( out == 3 ) then --2pair
		use_rank(scnd_card,2)
		use_rank(high_card,2)
	elseif( out == 2 ) then --pair
			use_rank(high_card,2) 
	end
	
	results={}
	results.hand=out
	results.high_card=high_card
	if(scnd_card==nil or scnd_card==0) scnd_card=high_card
	results.scnd_card=scnd_card

	results.used_cards={}
	foreach(used_cards, function(c) add(results.used_cards,c) end )
	
	results.best_hand={}
	foreach(used_cards, function(c) add(results.best_hand,c) end )

 --fill the rest with the best unused cards
 local tmpset=high_cards(unused_cards,5-#used_cards)
	foreach(tmpset, function(c)add(results.best_hand,c) end )
	
	--make a mask
	foreach(results.best_hand, function(c)		
		local bit = shl(1,13-c.r)
		results.mask= bor(results.mask,bit)
	end)
	
	return results
end

function high_cards(set, count)
	local keepers={}
	local isbigger = 
		function(a,b)
			if(a.r==b.r) return false
			if(a.r==1) return true
			if(b.r==1) return false
			return (a.r>b.r)
		end
	for ii=1,count do
		local high=nil
		for c in all(set) do
			if(high==nil) high=c
			if(isbigger(c,high))high=c
		end
		if(high!=nil) then
			del(set,high)
			add(keepers,high)
		end
	end 
	return keepers
end


function find_winner()
 for ii=1,4 do
 	players[ii].lose=0
 end
 
 local p={}
 if(inhand(player)) p[1]=player
 for ii=1,#pros do
 	if(inhand(pros[ii]))add(p, pros[ii])
 end
 
 if(#p >1) then
	 for a=1,#p-1 do
	 	for b=a,#p do
	 		local result=compare_hand_evals(p[a].eval,p[b].eval)
	 		if( result > 0 ) p[a].lose=1
	 		if( result < 0 ) p[b].lose=1
	 	end
	 end
	end

 --quiters don't win
 for a=1,#players do
 	if(not inhand(players[a]) ) players[a].lose+=1000
	end
	
end

--return -1 if a wins
--return 1 if b wins
function compare_hand_evals(a,b)
	ace=0x1000
	
	if(a.hand ~= b.hand) then
		if(a.hand > b.hand) return -1
		if(a.hand < b.hand) return 1
	end
	
	if(a.high_card~=b.high_card) then
		if(a.high_card==ace) return -1
		if(b.high_card==ace) return 1
		if(a.high_card<b.high_card) then
			return -1
		else
			return 1
		end
	end
	
	if(a.scnd_card~=b.scnd_card) then
		if(a.scnd_card==ace) return -1
		if(b.scnd_card==ace) return 1
		if(a.scnd_card<b.scnd_card) then
			return -1
		else
			return 1
		end
	end

 	
	--compare hands and kickers
	if(#(a.used_cards) < 5) then
		local amask=a.mask
		local bmask=b.mask
		if(hasace(amask) and not hasace(bmask) ) return -1
		if(hasace(bmask) and not hasace(amask) ) return 1
		for ii=0,13 do
			if( band(amask,1) > band(bmask,1) ) return -1
			if( band(amask,1) < band(bmask,1) ) return 1
			amask=shr(amask,1)
			bmask=shr(bmask,1)
		end 
	end
	
	--tie
	return 0
end
function hasace(mask)
	if(band(mask,0x1000)==0x1000) return true
	return false
end


deal_timer=0
cards_dealt=0
function update_dealer()
	if(parts_done()==false) return

	deal_timer += 1

	if(hand_state==0) then
		if(bubbles_done()==false)return
		build_deck()
		cards_dealt=0
		
		board={}

		anteup()
		
		for p in all(players) do
			p.hand={}
			p.eval={}
			p.lose=0
			if(p:cash_safe()<rules.bblind)bust(p)
		end
		reset_sim()
		deal_timer=0
		set_phase(1)
	end
	
	if(hand_state==1) then
		local x = flr(deal_timer/deal_delay)
		if(x >= cards_dealt) then	
			local p = left(players[dealer])
			for ii=1,x do
				p=left(p)
			end
			if( #p.hand < 2 ) then
			 add(p.hand, deal())
			else
				set_phase(2)
			end	
		end	
	end
	
	if(hand_state==3)then
		local x = flr(deal_timer/deal_delay)
		if(x>3) then
			set_phase(4)
		elseif(x>0 and board[x]==nil)then
			board[x]=deal()
		end
	end


	
	if(hand_state==5)then
		if(deal_timer>deal_delay) then
			if(board[4]==nil) then
				board[4]=deal()
			end
			set_phase(6)
		end
	end
	
	if(hand_state==7)then
		if(deal_timer>deal_delay) then
			if(board[5]==nil)then
				board[5]=deal()
			end
			set_phase(8)
		end
	end
		
end



function next_better()
	show_menu=false
	menu.bar=0 
	local p
	for ii=1,3 do
		better = better + 1
		if(better>#players) better=1
		p = players[better]
		if(inhand(p)) break
	end
	
	if(p.roundbet==round_highbet or p.keyin) then
		if(p.lastaction!="") then
			set_phase(hand_state+1)	
		end
	end
end

function place_bet(p,x)
	paytopot(p,x)
	p.roundbet+=x
	
	if(p.roundbet>round_highbet) round_highbet=p.roundbet
	p.lastaction="bet"
	
	bets_this_round+=1
	
	next_better()
end

function bet_key(p, knum)
	p.keyin=true
	if(knum==nil)knum=#p.inven
	local k = p.inven[knum]
	del(p.inven,k)
	add(pot.items,k)

	if(tut_seen_key==0) popup("  this gambler is broke, \n so he has bet his ship!\n")
	tut_seen_key=1

	local coord=playerxy(p)
	add_part(-k, coord[1],coord[2], 16,56)
	
end
function fold(p)
	p.folded=true
	p.lose=1
	p.lastaction="fold"
	show_bubble(p.botid,1)
	mysfx(snd_fold)
	local pcount=0
	for ii=1,#players do
		if(inhand(players[ii])) pcount+=1
	end
	if(pcount<=1) then
		show_menu=false
		set_phase(9)
	else
		next_better()
	end

	if(p==player) then
		if(return_to_main_pending) then
			return_to_main_pending=false
			fade_to_state(0)
		end
	end
	
end

function pass(p)
	p.lastaction="pass"
	show_bubble(p.botid,0)
	mysfx(snd_pass)
	next_better()
end

round_highbet = 0
betting_wait=bet_delay
function update_betting()
	local p = players[better]

	if(not inhand(p)) then
		next_better()
		return
	end
	
	--delay a moment
	if(parts_done()==false) return
	if( p!=player ) then 
		betting_wait=betting_wait-1
		if(betting_wait>0) return
	end
	betting_wait=bet_delay
	
	--determine min_bet
	local min_bet=round_highbet-p.roundbet
	min_bet=max(0,min_bet)
	
	--key in? you're all set.
		if(p.keyin) then
			place_bet(p,0)
			return
		end
	
	--human bet
	if(p==player) then
		menu.bet=min(p:cash_safe(),min_bet)
		menu.canbet=(menu.bet>=min_bet)
		if(not menu.canbet and #my_keys>0)then
			menu.canbet=true
			menu.betship=true
		else
			menu.betship=false
		end
		menu.minbet=min_bet
		menu.maxbet=cash_min(p.cash,rules.max_bet+min_bet)
		show_menu=true
	else
	--ai
		local refbet= max(min_bet,rules.sblind)
		local estpot= max(pot:cash_safe(),rules.bblind * 5)
		local po = refbet/(refbet+estpot)
		local conf=get_confidence(p)
		conf *= 0.80^flr(bets_this_round/2.75)
		local ror= conf/po
		
		if(hand_state<5) ror*=p.brain.pfo
		
		local meme=nil
		for bb=1, #(p.brain.t) do
			meme=p.brain.t[bb]
			if(ror<meme[1]) break
		end

		local r=rnd(1.0)
		if(r < meme[2]) then
			--fold (or check)
			if(min_bet > 0 ) then fold(p) 
			else pass(p) end
		elseif(r < meme[3] or (player.keyin and non_folded_players() <=2 )) then
			--call (or check)
			if(min_bet>p:cash_safe())then
				fold(p)
			elseif(min_bet > 0 ) then
				place_bet(p,min_bet) 
				show_bubble(p.botid,3)
			else
				pass(p)
			end
		else
			--raise / bet
			local amount=rules.max_bet / 2
			amount=min(amount,-1+p:cash_safe()-min_bet)
	
			if(amount<0)then
				--bet ship if we've got one
				if(#p.inven>0) then
					bet_key(p)
					place_bet(p,p:cash_safe())
					return
				else
					fold(p)
				end
			else
				place_bet(p,min_bet+amount)
				
				if(min_bet<=0) then
						show_bubble(p.botid,4)
				else
						show_bubble(p.botid,2)
				end
			end
		end		
	end
end

function distribute_loot()
	local w={}
	for ii=1,#players do
		if(players[ii].lose==0) then
			add(w,players[ii])
		end
	end
	local share=cel(pot.cash/#w)
	for ii=1,#w do
		share=min(share,pot.cash)
		w[ii].cash+=share
		pot.cash-=share
		
		coord=playerxy(w[ii])
		local ps=share/rules.bblind
		ps*=100
		for ii=1,min(ps,20) do
			add_part(25+flr(rnd(4)), 16+flr(rnd(16)),56+flr(rnd(16)),coord[1],coord[2])
		end
	end
	ii=1
	while(#pot.items>0) do
		if(#pot.items>0 ) then
			kk=pot.items[#pot.items]
			if(w[ii]==player)then
			 player.inven[kk]+=1
			else
				add(w[ii].inven,kk)
			end
			del(pot.items,kk)
			
			coord=playerxy(w[ii])
			add_part(-kk, 16,56,coord[1],coord[2])

		end
		ii+=1
		if(ii>#w)ii=1
	end
end

function paytopot(p,n)
	if(n<1) return
	pot.cash+=n/100
	p:adjust_cash(-n)
	p.totalbet+=n
	
	local coord=playerxy(p)
	for ii=1,n,rules.bblind do
		add_part(25+flr(rnd(4)), coord[1],coord[2], 16+flr(rnd(16)),56+flr(rnd(16)))
	end
end
function anteup()
	local d = players[dealer]
	for ii=1,4 do
		local p=players[ii]
		if(not isbusted(p))then
			local x=0
			if(p==left(d) and p~=d) then
				x+=rules.sblind
			elseif(p==left(left(d)) and p~=d) then
				x+=rules.bblind
			end
			if(players[ii]:can_afford(x)) then
				place_bet(p,x)
			else
				bust(p)
			end
		end
	end
end
function inhand(p)
	return not (isbusted(p) or p.folded)
end
function isbusted(p)
	if (p==player)  return false
	if (p.keyin)  return false
	if (p:cash_safe() < 1)  return true
	return false
end
function bust(p)
	if(isbusted(p))return
	p.cash=-p.cash
	if(p!=player) show_bubble(p.botid,5)  
 mysfx(snd_bust)
end

function left(p)
	local x=0
	for ii=1,4 do
		if(players[ii]==p) x=ii+1
	end
	if(x>4) x-=4
	if(isbusted(players[x])) return left(players[x])
	return players[x]
end

function set_phase(x)
	weathcheck()
	save_player()
	
	local clear_bets=(x<1 or x>2)
	
	if(non_busted_players()<2) x = 10
	 
	if(clear_bets) then
	 bets_this_round=0
	 round_highbet=0
	end
 for ii=1,#players do
 	local p=players[ii]
 	if(clear_bets) p.roundbet=0
 	p.lastaction=""
 	
 	if(x==0) then
 		p.totalbet=0
 		p.folded=false
 		p.lose=0
 		p.hand={}
 		p.keyin=false
 	end
 end
 
	reset_sim()
	deal_timer = 0

	if(x==0)then
		dealer+=1 if(dealer>4)dealer=1
		while(isbusted(players[dealer])) do
			dealer+=1 if(dealer>4)dealer=1
		end
		
		pot.cash=0.001
		pot.display_cash=0
		pot.items={}
		pot.rand=flr(rnd(10000))
		
		if(player:cash_safe()<rules.bblind) then
		 popup("      you are busted! \n   you may need to sell\n  your ship to continue.")
			fade_to_state(0)
		end
	end
	
	--if(x==2) --hand dealt	
	--if(x==3) --flop dealing
	--if(x==5) --turn	
	--if(x==7) --river

	if(x==9)then --find winner
		for pp=1,3 do
		 pros[pp].eval=eval(pros[pp].hand)
		end
		player.eval=eval(player.hand)
	 find_winner()
	end

	if(x==10) then --hand over
		distribute_loot()		
			
		if(non_busted_players()<2) then
		 mysfx(snd_win) 
			popup("  congrats. you are the \n    last player standing.")
		end
		
		if(return_to_main_pending or non_busted_players()<2) then
			return_to_main_pending=false
			fade_to_state(0)
		else
			set_phase(0)
		end
		return
	end

	--bet starts left of dealer
	better=dealer+3 if(better>4)better-=4
	
	betting_wait=bet_delay
	menu.selected=1
	
	hand_state=x
end
function run_ai()
	for ii=1,5 do do_sims(); end
end

game_tick=1
function update_table()
	if(btnp(4) and hand_state==9)then
		set_phase(10)
	end
	
	if(btnp(5))then
		dialog(
			" are you sure you want to\n     leave the table?",
			function()
			 if(hand_state<9 and player.folded==false) then
					return_to_main_pending=true
					popup(" you will leave the table \n     after this hand.")
				else
					fade_to_state(0)
				end
			end,
			nil,
			false) 
	end

	if(hand_state==2 or hand_state==4 or hand_state==6 or hand_state==8) then
		update_betting()
	end
	
	if(show_menu) update_menu()
	update_dealer()
	run_ai()	
end

function makebot(cash)
	p={}
	player_set_functions(p)
 p.hand={}

 p.cash=cash
 p.cash *= (1+rnd(0.1))
 local r = flr(rnd(#gambler_names))
 p.name=gambler_names[1+r%#gambler_names]
 p.brain=gambler_brains[1+r%#gambler_brains]
 p.totalbet=0
 p.roundbet=0
	p.keyin=false
	p.inven={}
	return p
end

lvl_wealth={5.00,50.00,1000.00}
lvl_blind={10,50,100}
lvl_max={50,500,1000}
lvl_buyin={.10,25.00,1000.00}
lvl_keys={{2,3,4,5,6,7},{8,9,10,11,12,13},{14,15,16,17,18,19}}
lvl_back={46,132,134}
function init_table(lvl)
	for i=1,3 do
		pros[i]=makebot(lvl_wealth[lvl])
		pros[i].botid=i
		if(rnd(2)<1)pros[i].inven[1] = lvl_keys[lvl][1+flr(rnd(#lvl_keys[lvl]))]
	end
 backs=lvl_back[lvl]
 players={player,pros[1],pros[2],pros[3]}

	rules.max_bet=lvl_max[lvl]
	rules.sblind=flr(lvl_blind[lvl]/2)
	rules.bblind=lvl_blind[lvl]
	rules.buyin=lvl_buyin[lvl]
	
	player.eval=nil
	ai_cr = cocreate( function() while(true) do do_sims(); end end )

 build_keys()
end

-- main menuê
function start_main()
	main_sel=0
	main_count=0
	menu_tick=0
 part_q={}
 part_list={}
end
function update_main()
 if(btnp(2))main_sel-=1
 if(btnp(3))main_sel+=1
 if(btnp(4))then --é
 	if(main_sel<=2) then
	 	init_table(main_sel+1)
	 	if(player.cash>=(rules.buyin)) then
	 		fade_to_state(10)
	 	else
	 		popup("  you need more cash to \n      play this table.")
	 	end
 	end
 	if(main_sel==3)fade_to_state(20)
	end
 main_sel%=4
 menu_tick+=1
end
function draw_main()
	local fake_hand = { card(13,3),card(13,1), card(1,2),card(1,4),card(1,3) }
	if(main_count>20000)main_count=128
	main_count+=1
	cls(0)
	draw_stars()
	pal(7,3)
	spr(176,28,7,9,1)
	pal(7,11)
	spr(160,48,16,4,1)
	if(false)print("frontier poker on the \n   final frontier!", 24,88,7)
	if(true) then
	
	local x=8

	mi={"low stakes table", "mid stakes table", "high stakes table", "inventory"}
	for ii=0,3 do
		local y=84+8*ii
		print(mi[ii+1],x,y,main_sel==ii and 11 or 3 )
		if(ii==main_sel) print("è",x-8,y,11)
	end

	print("cash:\n \nships:", 85,90,3)
	print("\n  $"..player:cash_str().. "\n\n  "..ship_count(), 85,90,11)

	reset_pal()
	credit_text={"  @aplundell","  octodon.social/@aplundell", "  andy@andylundell.com"}
	credit=play_count%3
	if(-500+ menu_tick + 0.1*abs(menu_tick * sin(game_tick/3)) > 100 ) then
		print(credit_text[credit+1],2,123,11)
		spr(136+credit,0,120)
	end
	
	--(glitch)
	local yy=flr(rnd(128))
	for xx=1,128 do
		local c=pget(xx,yy)
		if(c==3)pset(xx,yy,11)
		if(c==11)pset(xx,yy,3)
	end

 end
	
	for ii=1,5 do
		if(ii*9>main_count)break
		draw_big_card(fake_hand[ii], 23+10*ii,20+4*ii)	
	end
	
end

-- inventoryê
function build_keys()
	all_keys={}
	my_keys={}
	local p1={ {7,6}, {6,13} }
	local p2={ {11,3}, {8,2}, {10,9}, {12,13},{14,2},{12,1} }
	local v={
		100,305,400,399,
		450,450,475,499,
		500,780,900,999,
		1000,2000,5000,12000,
		-40, -100,-1000,-2000}
	
	for ii=1,#v do
		local k={}
		k.value = v[ii]
		k.ship = ii%#ship_sprite
		k.pall={}
		k.pall[1]=p1[1+ii%#p1][1];
		k.pall[2]=p1[1+ii%#p1][2];
		k.pall[3]=p2[1+ii%#p2][1];
		k.pall[4]=p2[1+ii%#p2][2];
		k.id = ii
		all_keys[ii]=k
	end
	
	--starter ship
	all_keys[1].ship=-238
	all_keys[1].pall={7,6,15,15}
	
	--space tavern station
	local x=#all_keys
	all_keys[x].ship=-236
	all_keys[x].pall={6,13,6,13}
	
	for ii=1,20 do
		for pp=1,player.inven[ii] do
				add(my_keys,all_keys[ii])
		end
	end
end

function start_inven()
	build_keys()
end

inven_scroll = 0
inven_scroll_target=0
inven_sel=1
function update_inven()
	if(btnp(5)) fade_to_state(0) 
	if(btnp(0)) inven_sel-=1
	if(btnp(1)) inven_sel+=1
	if(btnp(2)) inven_sel-=4
	if(btnp(3)) inven_sel+=4
	inven_sel=min(#my_keys,max(1,inven_sel)) 

	if(btnp(4) and #my_keys>0) then 
		local k=my_keys[inven_sel]
		if(player.cash<20000 and k.id < #all_keys) then
			dialog(" are you sure you want to \n     sell this ship?	", 
			function()
				if(k.value>0)player:adjust_cash(k.value)
				if(k.value<0)player.cash+=abs(k.value)*10
				player.inven[k.id]-=1
				save_player()
				start_inven()
			end, nil)
		else
			popup(" unfortunetly, you could\nfind nobody willing to buy \n   your ship. try later.")
		end
	end
end

sel_c=11
function draw_select(x,y)
	local sx=x-1
	local sy=y-1
	rect(sx,sy,sx+25,sy+33,sel_c)
	if(sel_c==11)then sel_c=3
	else sel_c=11 end
end
function draw_inven()
	cls(0)
	draw_stars()

	for i=0,#my_keys-1 do
		local x=2 + 30 * (i%4) 
		local y=10 + inven_scroll + 35 * flr(i/4)
		draw_key_big(my_keys[i+1],x,y)
		if(i+1==inven_sel) then
			draw_select(x,y)
			if(y<13) inven_scroll_target=inven_scroll-(12-y)
			if(y>80) inven_scroll_target=inven_scroll-(80-y)
		end
	end
	
	inven_scroll-=0.5*(inven_scroll_target-inven_scroll)
	
	rectfill(0,120,128,128,0)
	print("press é to sell, ó to exit", 8, 121, 11)
	
	rectfill(0,0,128,8,0)
	print("your spaceship keys:",8, 2, 11 )
end


-- draw utilsê
function playerxy(p)
	local c={64,128}
	if(p.botid>0) then
		c[1]=prox[p.botid]+16
		c[2]=16
	end
	return c
end
function card_color(cost)
	if(cost==100) return {6,5}	
	local c=450
	if(cost <0) return {9,10}
	if(cost <=c*1) return {12,13}
	if(cost <=c*2) return {11,3}
	if(cost <=c*3) return {8,14}
	return {4,5}
end

ship_sprite={195,197,199,201,203,205,227,229,231,233}
function draw_key_big(k,x,y)
	local p=card_color(k.value)
	reset_pal()
	palt(14,true)
		pal(13,p[1])
		pal(6,p[2])
	spr(192,x,y,3,4)	
	
 reset_pal();palt(14,true)
	pal(11,k.pall[1])
	pal( 3,k.pall[2])
	pal( 8,k.pall[3])
	pal( 2,k.pall[4])  
	local s = ship_sprite[1+k.ship%#ship_sprite]
	if(k.ship<0) s=-k.ship 
	
	spr(s,x+4,y+7,2,2)
	
	draw_tiny_num(k.value,x+1,y+26,true)
	
	reset_pal()
end
function draw_key_small(k,x,y)
	local p=card_color(k.value)
	reset_pal()
	palt(14,true)
	pal(13,p[1])
	pal(6,p[2])
	pal(11,k.pall[1])
	pal( 3,k.pall[2])
	spr(144,x,y)	

	reset_pal()
end

function draw_tiny_num(n,x,y,iscash)
	palt(7,true)
	if(iscash) then
		spr(30,x,y-1)
		x+=4
	end
	local m=abs(n)
	if(n>9999 or n<-999)	m /= 1000
	local len =#(""..m)
	for ii=len,1,-1 do
		spr(0+m%10,x+4*(ii-1),y)
		m = flr(m/10)
	end
	if(n>9999) spr(13,x+4*len ,y)
	if(n<-999) spr(31,x+4*len,y)
	if(n<0 and n> -999) spr(13,x+4*len,y)
	palt(7,false)
end

-- particles
part_q={}
part_list={}	
part_timer=0
function parts_done()
	if(#part_q==0 and #part_list==0) return true
	return false
end
function add_part(s,x1,y1,x2,y2)
	local p={}
	p.s=s
	p.x1=x1
	p.y1=y1
	p.x2=x2
	p.y2=y2
	p.dx=x2-x1
	p.dy=y2-y1
	p.dist = function(self) local dx=(self.x2-self.x1); local dy=(self.y2-self.y1); return sqrt(dx*dx+dy*dy) end
	local l = p:dist()
	p.dx /= l
	p.dy /= l
	add(part_q,p)
end
function draw_parts()
	if(#part_q>0) then
		part_timer -=1
		if(part_timer<=0) then
			add(part_list,part_q[1])
			del(part_q, part_q[1])
			part_timer=part_stagger
			mysfx(snd_coin)
		end
	else 
		part_timer=0
	end
	
	foreach(part_list, function(p)
		reset_pal()
		palt( 0,true)
		palt(14,true)
			if(p:dist()<0.5+part_speed) then
				del(part_list,p)
				pot.display_cash=pot:cash_safe()
				return
			end
			p.x1 += p.dx*part_speed
			p.y1 += p.dy*part_speed
			
			if(p.s>=0) then
				spr(p.s,p.x1,p.y1)
			else
				draw_key_small(all_keys[-p.s],p.x1,p.y1)
			end				
		end)
end

-- data utilsê
keys_start=10
function init_player()
 player.botid=-1
 player_set_functions(player)
end
function load_player()
	init_player()
	player.cash=dget(1)
	tut_seen_key=dget(5)
	player.inven={}
	for ii=1,20 do
		player.inven[ii]=dget(ii+keys_start)
	end
end
function save_player()
	dset(1,player.cash)
	dset(5,tut_seen_key)
	for ii=1,20 do
		local x=player.inven[ii]
		if(x==nil)x=0
		dset(ii+keys_start, x)
	end
end
function reset_player()
	init_player()
	p_sc(player,500)
	player.inven={}
	player.inven[1]=1
	for ii=2,20 do
		player.inven[ii]=0
	end
	tut_seen_key=0
	save_player()
end
function ship_count()
	local out=0
	for ii=1,#player.inven do
		out+=player.inven[ii]
	end
	return out
end
function weathcheck()
	if player.cash>25000 then
	 popup("  you now have $"..player:cash_str()..".\n  you decide to purchase \n   space tavern station\n      for $2 million.")
	 player.cash-=20000
	 player.inven[20]+=1
	end
end

-- player utilsê
function player_set_functions(p)
	p.adjust_cash=p_cc
	p.cash_str=p_cs
	p.set_cash=p_sc
	p.can_afford=p_ca
	p.cash_safe=p_safe
end
function p_cc(p,delta)
	p.cash += (delta/100)
end
function p_cs(p)
	if(p.cash<0)return "0"
	local w=flr(abs(p.cash))
	local f=flr(abs((p.cash-w)*100))
	local out=""
	if(w>0) out=out..w
	if(w>0 and f < 10 ) out=out.."0"
	out=out..f
	return out
end
function p_sc(p,x)
	local w=flr(x/100)
	local f=flr(x-(w*100))
	p.cash=w+(f/100)
end
function cash_min(c,x)
	return flr(0.1 + min(x/100,c)*100)
end
function p_safe(p)
	if(p.cash<0) return 0
	local w=flr(abs(p.cash))
	local f=flr(abs((p.cash-w)*100))
	return flr(0.1+min(200,w)*100+f)
end
function p_ca(p,x)
	return (x/100)<=p.cash
end
pot.cash_safe=p_safe
-- utilsê
function mysfx(x)
	if(options.sounds) sfx(x,x%4)
end
function reset_pal()
	pal()
	palt(0,false)
end

function cel(x)
	return -flr(-x)
end
function printctr(str,x,y,col)
	local wid=4 * #str
	local lft=x-wid/2
	lft=max(0,min(lft,128-wid))
	print(str,lft,y,col)
end

function fade(i)
	memcpy(0x5f10,64*(40+i)+32,16)
end

gambler_names=
{
	"bob","ugly tom","fred","zorblax","space joe","frank","bot x7-jr2","crazy vinny","ed","boglin","zep","jelpi","king andy","liz","zoe"
}
--brainz
--threshold,fold,call,raise
--pre-flop-optimism (pfo)
gambler_brains=
{
 { --cautious
 	t=
 	{
 		{0.7,.95,.00},
 		{0.8,.70,.25},
 		{3.9,.01,.80},
 		{0.0,.01,.30}
 	},
 	pfo=1.25
 },
 {--smart
 	t=
 	{
 		{0.8,.95,.00},
 		{1.0,.80,.15},
 		{1.3,.05,.65},
 		{0.0,.01,.50}
 	},
 	pfo=1.5
 },
 {
 	t=
 	{--predictable
 		{0.8,.95,.00},
 		{1.0,.80,.17},
 		{2.3,.00,.80},
 		{0.0,.00,.10}
 	},
 	pfo=1.66
 },
  {
 	t=
 	{--crazy
		 {0.8,.95,.00},
 		{1.0,.85,.15},
 		{1.3,.05,.55},
 		{0.0,.00,.30}
 	},
 	pfo=2.0
 },
}
__gfx__
77077777700777777000777770007777707077777000777770007777700077777050777770057777007707777000777777077777707077777707777700070707
70707777770777777750777777007777700077777057777770777777777077777707777770507777707070777707777770707777700777777070777770770077
70707777770777777057777777707777777077777750777770507777770777777070777777707777707070777707777770507777700777777000777770770077
77077777700077777000777770007777777077777000777770007777770777777707777777007777000707777007777777007777707077777070777700770707
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777eeecceeeeee00eeeeee00eeeeeee999ee6776eee0cc000000bb000000880000006600000757077777505777777777777
77777777777777777777777777777777eeecceeeee0880eeee0000eeeebbbe9e670576eec99c0000b99b00008998000069960000770077777007777775000577
77777777777777777777777777777777eecccceee088880ee000000eebbbb99e770757eec99c0000b99b00008998000069960000700777777700777770707077
77777777777777777777777777777777eec6ccee0888888050000005ebbb99ee770757ee0cc000000bb000000880000006600000707577777505777770707077
77c77777778777777757777777797777ec66ccce08888880000000009bb99bee670576ee00000000000000000000000000000000777777777777777777777777
76c67777788877777505777773477777ec6ccccee088880e000000009e99beeee6776eee00000000000000000000000000000000777777777777777777777777
7ccc7777788877777000777779377777ecccccceee0880ee500ee005999eeeeeeeeeeeee00000000000000000000000000000000777777777777777777777777
76c67777778777777707777797777777eecccceeeee00eeeeee00eeeeeeeeeeeeeeeeeee00000000000000000000000000000000777777777777777777777777
000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000000ee0000000000000eee000000000000ee
00000000000000000000000000cc00000000000000cc00000000000000cc00000000000000cc00000000899800cc0000ee0777777777770eee066666666660ee
000cc00000000000000cc0000c99c000000cc0000c99c000000cc0bb0c99c000000cc0bb0c99c000000c89980c99cbb0ee0777777777770eee06d5d5d5d560ee
00c99c000000000000c99c000c99c00000c99c000c99c00000c99b99bc99c00000c99b99bc99c00000c99889bc99b99bee0777777777770eee065d5d5d5d60ee
00c99c000000000000c99c0000cc000000c99c000bbc000000c99b99bbbc000000c99b99bbbc000000c99b988bbcb99bee0777777777770eee06d56666d560ee
000cc00000000000000cc000000000000088c000b99b00000088c0bbb99b00000088c0bbb99b00000088cc89989b0bb0ee0777777777770eee065d66665d60ee
0000000000000000000000088000000008998008b99b000008998008b99b000008998008b99b88000899c989989b8800ee0777777777770eee06d56116d560ee
00000000000000000000008998000000089980899bb00000089980899bb00000089980899bb899800899c9988bb89980ee0777777777770eee065d65d65d60ee
0000000000000000000000899800000000880089980000000088b089980000000088b0cc980899800088bccc98089980ee0777777777770eee06d56d56d560ee
0000000000bb00000000000880bb00000000000880bb000000b99b0880bb000008899c99c0bb880008899c99c0bb8cc0ee0777777777770eee065d61165d60ee
000000000b99b000000000000b99b000000000000b99b00000b99b000b99b00089989c99cb99b00089989c99cb99c99cee0777777777770eee06d56666d560ee
000000000b99b000000008800b99b000000008800b99b000000bb8800b99b0008998b8cc0b99b0008998b8cc0b99c99cee0777777777770eee065d66665d60ee
0000000000bb00000000899800bb00000000899800bcc0000000899866bcc0000889c99866bcc0000889c99bb6bcccc0ee0777777777770eee06d5d5d5d560ee
000000000000000000008998000000000000899800c99c000000899699699c000c99c99699699c000c99c9b99bc99c00ee0777777777770eee065d5d5d5d60ee
000000000000000000000880000000000000088000c99c000000088699699c0000cc088699699c0000cc08b99bc99c00ee0777777777770eee066666666660ee
0000000000000000000000000000000000000000000cc00000000000660cc00000000000660cc0000000000bb60cc000ee0000000000000eee000000000000ee
77777777777777777707777707770777077707770777077707770777077707770777077707770777770777777909a77769097777e0000000000000000000000e
7777777777077777777777777777777777777777777777777707777777077777777777777707777770f0777770f0977760f07777077777777777777777777770
77777777777777777777777777777777777777777777777777777777777777770777077707770777750577777505977765057777077777777777777777777770
77077777777777777707777777777777770777770777077707770777077707777707777777777777555557775555577755555777077777777777777777777770
77777777777777777777777777777777777777777777777777777777777777770777077707770777750577779505777775056777077777777777777777777770
7777777777077777777777777777777777777777777777777777777777077777777777777707777770f0777790f0777770f06777077777777777777777777770
7777777777777777770777770777077707770777077707770777077707770777077707770777077777077777a909777779096777077777777777777777777770
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777077777777777777777777770
eee000000000000000000eeeeeeeeeeee55eeeeeeeeeee55eeeeeeeeeeeeeeee00102030405060608090a0b0c0d0e0f0eeeeeeee077777777777777777777770
ee07777777777777777770eeeeeeeeeee575eeeeeeeee5775eeeeeeeeeeeeeee001020304050d060809090b0c050e060eeeeeeee077777777777777777777770
e0766666666666666666660eeeeeeeeee5775eeeeee55e55eeeeeeeeeeeeeeee001020302010d0d020404030305040d0eeeeeeee077777777777777777777770
0765000000000000000056505555555555775555ee5775eeeeeeeeeeeeeeeeee00101010201050d02040403030502050eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775ee577555555eeeeeeeeeeeee00001010101050502040503010102050eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775eee555777775eeeeeeeeeeee00000000000050502050500010102050eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775e5577777777755eeeeeeeeee00000000000010100000000010101010eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775577777777777775eeeeeeeee00000000000000000000000000000000eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775577777777777775eeeeeeeee00000000000000000000000000000000eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775e577777777777775eeeeeeee00000000000000000000000000000000eeeeeeee077777777777777777777770
0760111111111111111106505777777777777775e577777777777775eeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
07601111111111111111065057777777777777755777777777777775eeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
07601111111111111111065057777777777777755777777777777775eeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
0760111111111111111106505555555555555555e577777777777775eeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
076011111111111111110650eeeeeeeeeeeeeeeeee5777555577775eeeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
076011111111111111110650eeeeeeeeeeeeeeeeeee555eeee5555eeeeeeeeeec0000000000000000000000000000000eeeeeeee077777777777777777777770
07601111111111111111065057777777777777755777777777777775577777777777777557777777777777755777777777777775077777777777777777777770
07601111111111111111065057777777777777755777777777777775577777777777777557777777777777755777777777777775077777777777777777777770
07601111111111111111065057007000750750755700770770770075007700070700700557007000707707755770077007000775077777777777777777777770
07601111111111111111065057057070707707755707707070770705070707070707705557077070707707755770077057707775077777777777777777777770
07650000000000000000565057007000770770755700707070770705007700070770707557077000707707755770707077707775077777777777777777777770
e0566666666666666666650e57077070705705755707770770070075070707070700700557007070700700755770077007707775077777777777777777777770
ee05555555555555555550ee57777777777777755777777777777775577777777777777557777777777777755777777777777775077777777777777777777770
eee000000000000000000eee57777777777777755777777777777775577777777777777557777777777777755777777777777775e0000000000000000000000e
0ee0eeeee00eeeee0000000000ccc000ee000000000000eeee000000000000ee0000000003bbbbb00000000000000000ee9999eeeeeeeeeeeeeeeeeeeeeeeeee
0e0e0eee0ee0eeee777777770ccccc00ee065656656560eeee0ddcdddcddd0eeb0003bb03bbb777b0000000000000000e999ee9e2e2e2e2eeeeeeeeeeeeeeeee
0e0e0eee0ee0eeee57777775c5c0c5c0ee065656656560eeee0ccdcccdccc0eebb30bbbbbdb7b7b7bbbbbbbb00000000999eeeeee2e2e2e2eeebebebbbebbeee
0e0e0eee0e05eeee75777757c5c5c5c0ee065656656560eeee0cdddcdddcd0ee3bbbbbb0bbb7b7b70bbbbbb000000000999eeeee22222222eeebebeb3eebeeee
0ee0eeeee050eeee77577577c0c5c0c0ee065656656560eeee0dcccdcccdc0ee0bbbbb30bb3bbbb0b0bbbb0b00000000999eeeee22222222eeeebeebeeeebeee
eeeeeeeeeeeeeeee767557670ccccc00ee065656656560eeee0ddcdddcddd0ee00bbbb00bb000000bb0bb0bb00000000999eeee922222222eeeebeebbbebbeee
eeeeeeeeeeeeeeee6777777600ccc000ee065656656560eeee0ccdcccdccc0eebbbbb3003b30b000b3b00b3b00000000e999ee9e22222222eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee0000000000000000ee065665566560eeee0cdddcdddcd0ee03b300000bbb00003bbbbbb300000000ee9999ee22222222eeeeeeeeeeeeeeee
099eeeee01ccccc00000000000000000ee065665566560eeee0dcccdcccdc0ee01ccccc0eee000000000000000000eee7777777722222222eeeeeeeeeeeeeeee
0660eeee1ccccccc00000000c0001cc0ee065656656560eeee0ddcdddcddd0ee1ccc777cee07777777777777777770ee7777777722222222eeeeeeeeeeeeeeee
06660eeecc5ccccc0e888880cc10ccccee065656656560eeee0ccdcccdccc0eecdc7c7c7e0766666666666666666660e7777777722222222eeeebeebeebeeeee
0ddd0eeecccccccce88788881cccccc0ee065656656560eeee0cdddcdddcd0eeccc7c7c70765000000000000000056507777777722222222eeeebbebebebeeee
0d3d0eeecc1cccc0888778880ccccc10ee065656656560eeee0dcccdcccdc0eecc1cccc00760333333333333333306507a9a777722222222eeeebebbebebeeee
0ddd0eeecc0000008887888200cccc00ee065656656560eeee0ddcdddcddd0eecc00000007603333333333333333065079777777e2e2e2e2eeeebeebeebeeeee
00000eeeccc1100008888820ccccc100ee065656656560eeee0ccdcccdccc0ee1c10c000076033333333333333330650797977772e2e2e2eeeeeeeeeeeeeeeee
eeeeeeee0ccccc000000000001c10000ee000000000000eeee000000000000ee0ccc00000760333333333333333306507a9a7777eeeeeeeeeeeeeeeeeeeeeeee
777777077777707000700777770777700000000057777777777777755777777777777775076033333333333333330650e33e33ee22222222eebbbbbbbbbbbbee
70000707000770700070070000070070000000005aa77a7a7aa7aaa55777777777777775076033333333333333330650333b333e22222222eb000000000000be
7000070700077070007007000007007000008000900aa0a0a50a00095700770750707075076033333333333333330650333b333e22222222b00000000000000b
7777770700007077777707777707777700097600900aa0a0a0a7a0a55707070707700775076033333333333333330650ebb3bbee22222222b00000000000000b
7700000700007077000707700007700700a777e090a0a0a07a0aa0a55700770770700775076033333333333333330650333b333e22222222b00000000000000b
77000007000070770007077000077007000b7d00900aa000a05aa0a55707070705707075076033333333333333330650333b333e22222222b00000000000000b
770000077777707700070777770770070000c0005aa77aaa7aa77a755777777777777775076033333333333333330650e33e33ee22222222eb000000000000be
000000000000000000000000000000000000000057777777777777755777777777777775076033333333333333330650eeeeeeee22222222eebbbbbbbbbbbbee
77777077777700777700777777077777000077777007777007700707777707777007777707603333333333333333065077777777eeeeeeeeee000000000000ee
70007070000700700700700007070000000007000007007007700707000007007007000707603333333333333333065077777777eeeeeeeee0aaaaaaaaaaaa0e
70000070000700700700700000070000000007000007007007700707000007007007000707603333333333333333065077777777eeeeeeee0aaa0aa0aa0aaaa0
77777077777700700700770000077777000007700007007007700707777707777707700707603333333333333333065077777777666666660aaa00a0a0a0aaa0
00077077000007777770770000077000000007700077777700707707700007700707700707650000000000000000565073b37777555555550aaa0a00a0a0aaa0
700770770000077000707700070770000000077000770007007077077000077007077007e0566666666666666666650e7b3b7777eeeeeeee0aaa0aa0aa0aaaa0
777770770000077000707777770777770000077000770007007777077777077007077007ee05555555555555555550ee73b37777eeeeeeeee0aaaaaaaaaaaa0e
000000000000000000000000000000000000000000000000000000000000000000000000eee000000000000000000eee77b77777eeeeeeeeee000000000000ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbeeeeeeeeeeeeee33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555eeeeeeeeeeeeee
0000a90a90a90a90a90eeeeeeeeeeeeeeebbbbbeeeeeeebbbbeeeeeeeeeeee3bb3eeeeeeeeeeeee33eeeeeeeeeee55555555eeeeeeeee5bb335eeeeeeeeeeeee
0dd09909909909909900eeeeeeeeeeeebbbbbb3eeeeeebbbbb3eeeeeeeeeee3cc3eeeeeeeeeeee3bb3eeeeeeeee566c7cc665eeeeeee5bb7c335eeeeeeeeeeee
0ddddddddddddddddddd0eeeeeeeeeebb11bbb3eeeeebbbb3b33eeeeeeeeee3cc3eeeeeeeeeee3bbbb3eeeeeee5666cccc6665eeeeee5bcccc35eeeeeeeeeeee
0dddddddddddddddddddd0eeeeeeeebbb1bbb33eeeeebbb33b33eeeeeeeeee3cc3eeeeeeee5ee3b66b3ee5eeee55555cc55555eeeeee533cc335eeeeeeeeeeee
0ddddddddddddddddddddd0eeeeeeebbbbbb033eeeeeebbbb33eeeeeeeeeee3cc3eeeeeeee5e3b66ccb3e5eeeee00e5665e00eeeeeeee533335eeeeeeeeeeeee
0dd0000000000000000dddd0eeeeebbbbbb003eeeeeeee3333eeeeeeeeeeee3bb3eeeeeeee538b6cccb835eeee0bb028820bb0eeeeeeee5555eeeeeeeeeeeeee
0dd01111111111111110ddd0e888bbbbbb3333eeee88eeebbeee88eeeeeeee3bb3eeeeeeee388b3333b883eeee0b3028820b30eeee22ee5bb5ee22eeeeeeeeee
0dd011111111111111110dd0e888bbbbb3333eeeee82eeeb3eee82eeee5ee3bbbb3ee5eee3388b3333b8833eee033028820330eee2882e5335e2882eeeeeeeee
0dd011111111111111110dd0e888bb8b3333eeeeee82eeeb3eee82eeee5e3bbbbbb3e5eee3388bbbbbb8833eeee00e5665e00eeee588555bb555885eeeeeeeee
0dd011111111111111110dd0ee88b8b333eeeeeeee829ebbb3e982eeee338bbbbbb833eee3388bbbbbb8833eee0bb028820bb0eee57755533555775eeeeeeeee
0dd011111111111111110dd0eeee83333eeeeeeeee8299bbb39982eee3828bbbbbb8283ee3383bb33bb3833eee0b3028820b30eee5765e5bb5e5765eeeeeeeee
0dd011111111111111110dd0eee8e2222eeeeeeeee82e9bb339e82eee3828bbbbbb8283ee333e33ee33e333eee033028820330eee5765ee55ee5765eeeeeeeee
0dd011111111111111110dd0eeeee2222eeeeeeeee82ee3333ee82eee3828b3333b8283ee33ee99ee99ee33eeee00e5665e00eeee5665eeeeee5665eeeeeeeee
0dd011111111111111110dd0eeeeee222eeeeeeeee22eeeeeeee22eee38283eeee38283ee3eeeeeeeeeeee3eeeeeee5555eeeeeee5665eeeeee5665eeeeeeeee
0dd011111111111111110dd0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee333eeeeee333eeeeeeeeeeeeeeeeeeeeeeeee99eeeeeeeee55eeeeeeee55eeeeeeeeee
0dd011111111111111110dd0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555eeeeeeeeeeeeeeeeeeebaabeeeeeeeeeeeeeeeeeeeeee
0dd011111111111111110dd0eeee6eeeeee5eeeeeeeeeee33eeeeeeeeeeeeeeeeeeeeeeeeeee56cccc65eeeeeeeeeeeeeeeebbbbbbbbeeeeeeeeeeeeeeeeeeee
0dd011111111111111110dd0eee66eeeeee55eeeeeeeee3bb3eeeeeeeeeeeeeeeeeeeeeeeeee56cccc65eeeeeeeeeeeeeeebbb3b33bbbeeeeeeeeeeeeeeeeeee
0dd011111111111111110dd0eee66eeeeee55eeeeeeee237c32eeeeee9eeeee00eeeee9eeeee5dddddd5eeeeeeeeeeeeeebbb3eb3e3bbbeeeeeeeeebbeeeeeee
0dd011111111111111110dd0ee6b6eeeeee5b5eeeeee223cc322eeeee0eeee0b30eeee0eeeeeee5555eeeeeeeeeeeeeeebbb3eeb3ee3bbbeeeeeeebbbbeeeeee
0dd011111111111111110dd0ee6b6e9ee9e5b5eeeeee223bb322eeeee0eeee0b30eeee0eeee33ee6dee33eeeeeeeeeeeebb3eee55eeebbbeeeeeeebccbeeeeee
0dd011111111111111110dd0ee6b6edeede5b5eeeeeeeeebbeeeeeeee00ee0b7c30ee00eee3b3358253b33eeeeeeeeeebb3eee5bb5eeebb3eeeeebbcc33eeeee
0dd000000000000000000dd0e6666edeede5555eee0eeeebbeeee0eee0b0e0b7c30e030eee3b3356d53b33eeeeeeeeeeabbbb5b77b5bbb3aeeeeebbbb33eeeee
0dddddddddddddddddddddd0e6886dddddd5885eee5eeeebbeeee5eee0b800bcc300230eee3b33e82e3b33eeeeeeeeeeab3335b77b533b3aeeeebbb55333eeee
0dddddddddddddddddddddd0e6666dd77dd5555eee5e22333322e5eee0b88bbb3332230eee3b33e6de3b33eeeeeeeeeebb3eee5bb5eeeb33eeeebb566533eeee
0dddddddddddddddddddddd0e6886d7cccd5885eee52823bb32825eee0b88bbb3332230eee3b33e82e3b33eeeeeeeeeeebb3eee55eeebb3eeee4bb5665334eee
0dddddddddddddddddddddd0e6666dddddd5555eee28823bb32882eeee088bbb333220eeee3b3356d53b33eeeeeeeeeeebbb3eeb3eebb33eeee4444554444eee
0dddddddddddddddddddddd0ee666d5dd5d555eee288823bb328882eeee08bb003320eeeee3b3358253b33eeeeeeeeeeeebbbbeb3ebb33eeeeee44444444eeee
0dddddddddddddddddddddd0eee66dddddd55eeee288823bb328882eeeee000ee000eeeeeee33ee55ee33eeeeeeeeeeeeee3bbbbbbb33eeeeeeeeeeeeeeeeeee
0dddddddddddddddddddddd0eeeeeed99deeeeeee22222e99e22222eeeeeeeeeeeeeeeeeeeeeeee99eeeeeeeeeeeeeeeeeee33333333eeeeeeeeeeeeeeeeeeee
e00000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3aa3eeeeeeeeeeeeeeeeeeeeee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
adadadadadadadadadadadadadadadad00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a45051515151515151515151515152a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf6061616161616161616161616162a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf6061616161616161616161616162a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf7071717171717171717171717172a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfcfbdbdbdbdbdcfcf5051515152a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf50515151515152cf606161616262a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf60616161616162cf6061616162a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf60616161616162cf6061616162a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf70717171717172cf7071717172a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cfcfcfcfcfcfcfcfcfcfcfcfcfcfa4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9292838383838383838383838393828200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92999a9a9a9a9a9a9a9a9a9a9a9a9b8200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92a9aaaaaaaaaaaaaaaaaaaaaaaaab8200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92a9aaaaaaaaaaaaaaaaaaaaaaaaab8200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92a9aaaaaaaaaaaaaaaaaaaaaaaaab8200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
92b9bababababababababababababb8200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9393939393939393939393939393828200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000066700a6701167019670216702a6702f6700b07008070040700207003000020002f0002e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000967009610096200862008620076100861013630030001870017700167001570014700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000764007610076100761007610076100764000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001a76018740012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e71024720247002774000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000300003f000300303f020012003a0203a020232002320024200300303f020012003a0203a0200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003604026560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b52017520125300d54009550065600357001570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b0000147700a7300a7500b70000000187001770017700177000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000018130181301813000000171001c1301c1301c1301c7001c1001f1301f1301f1301a1001c1002415224162241722417224172241722417224172241722417224172241722417224172241722417224172
010500000c1300c1300c1300d1002a0001d1301d13000000000002913029130000000000034130351203414034120351403513035150000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001800318000180031800318003180031800318003180031800318003180031800318003180031800318003180031800318003180031800318003180031800318003180031800318003180031800318003
001000001d0311d0311d0311d0001d0001d0311d0001d031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 00 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
