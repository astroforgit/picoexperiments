pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- zelda battler
-- by fabuloup

-- initialisation du heros
link={}
link.x=16
link.y=16
link.speed=2
link.direction=1 -- orientation du personnage (0-haut 1-bas 2-gauche 3-droite)
link.walkstep=0  -- pour l'animation de marche 
link.attack=0    -- permet de savoir si le personnage attack (tuer des ennemis et afficher l'épée)
link.life=12
link.maxlife=12  -- peut etre changé si bonus qui augmente la vie
link.rupees=0    -- les rubis

-- on initialise des infos sur la carte
-- pour le deplacement de camera principalement
carte={}
carte.x=0
carte.y=0
carte.largeur=0
carte.hauteur=0

wave=0 -- numero de la vague de monstre
maxrnd=10000 -- nombre maximum pour la seed
seed=0 -- la seed sert a générer les mêmes vagues de monstre
-- même après être retourner sur le menu
-- elle change a chaque redemarrage de la cartouche

lasthit=0  -- dernière fois que link a été touché par un ennemis
lastkill=0 -- dernière fois que link a touché un ennemis, une herbe ou un bonus
pausemodel=0 -- utile pour l'ia du cracheur
-- permet de le faire se reposer pendant un certain temp

hiscore=0 -- plus haut score
score=0   -- score de la partie en cours

-- initialisation des bonus
bonus={}
maxbonus=10
for k=0,maxbonus do
	bonus[k]={}
	bonus[k].x=0
	bonus[k].y=0
	bonus[k].naissance=0 -- date a laquelle un bonus apparait
	bonus[k].model=0     -- type de bonus (coeur, rubis, ...)
end

t=0 -- variable qui s'incrémente à chaque boucle de _draw

maxennemi=30
-- initialisation des ennemis
ennemis={}
for k=0,maxennemi do
	ennemis[k]={}
	ennemis[k].x=0
	ennemis[k].y=0
	ennemis[k].dir=0     -- orientation de l'ennemi
	ennemis[k].life=0
	ennemis[k].model=0   -- type d'ennemi (chauve-souris, slime, cracheur)
	ennemis[k].lasttir=0 -- pour l'ennemi cracheur, dernière fois qu'il a tiré.
end

-- initialisation des boulets du cracheur
bullet={}
maxbullet=30
for k=0,maxbullet do
	bullet[k]={}
	bullet[k].x=0
	bullet[k].y=0
	bullet[k].dir=0
	bullet[k].active=false
	bullet[k].invert=0 -- savoir si le boulet a déjà fais une fois demi-tour
end

-- initialisation des particules du menu
particle={}
maxparticle=40
listmodel={72,73,74,148} -- numero des sprites des particules
for k=0,maxparticle do
	particle[k]={}
	particle[k].x=rnd()*128
	particle[k].y=rnd()*128
	particle[k].speed=rnd()*2+1
	particle[k].model=listmodel[flr(rnd()*(#listmodel-1))+1]
end

mode=1

function _init()
	cartdata("fabuloup_zeldabattler_1") -- pour sauvegarder le hiscore
	menuitem(2, "restart arena", function() retourarene() end) -- redemarre l'arene
	menuitem(3, "return to menu", function() retourmenu() end) -- retourne au menu du jeu
	hiscore=dget(0) -- on récupere le hiscore précèdent
	while mget(carte.largeur,0)!=0 do
		carte.largeur+=1  -- on récupère la largeur de la map
	end
	while mget(0,carte.hauteur)!=0 do
		carte.hauteur+=1  -- on récupère la hauteur de la map
	end
	seed=rnd(maxrnd) -- on calcul la seed
	music() -- on demarre la super musique
end

function retourmenu()
	mode=1
end

function retourarene()
	link.x=16
	link.y=16
	link.speed=2
	link.direction=1
	link.walkstep=0
	link.attack=0
	link.life=12
	link.maxlife=12
	link.rupees=0
	for k=0,maxennemi do
		ennemis[k].life=0
		ennemis[k].model=0
	end
	for k=0,maxbonus do
		bonus[k].x=0
		bonus[k].y=0
		bonus[k].naissance=0
		bonus[k].model=0
	end
	mode=2
end

function menu()
	cls(1)
	if btn(4) or btn(5) then
		retourarene()
	end
	for k=0,maxparticle do -- on dessine les particules du menu
		if particle[k].y>130 then
			particle[k].x=rnd()*128
			particle[k].y=-4
			particle[k].speed=rnd()*2+1
			particle[k].model=listmodel[flr(rnd()*(#listmodel-1))+1]
		end
		particle[k].y+=particle[k].speed
		spr(particle[k].model,particle[k].x,particle[k].y)
	end
	spr(89,64-5*4,20,2,2)    -- la lettre z est un sprite
	print("elda",64-1*4+1,31,8)
	print("battler",64-4*4,38,9)
	print("press z/c to play",64-8*4,60,12)
	print("z/c",64-2*4,60,8)
	print("hiscore : "..hiscore,70,120,12)
	print("seed:"..seed,0,120,12)
end

function appartient(objet,list_complete) -- pour savoir si un objet existe dans une liste
	for v in all(list_complete) do
		if v==objet then
			return true
		end
	end
	return false
end

function drawzelda() -- dessine le heros
	local steptime=10 -- frequence a laquelle les jambes du heros bouge
	if link.attack==0 then
		if link.direction==0 then
			spr(1+2*flr((link.walkstep%steptime)/(steptime/2)),link.x-carte.x,link.y-carte.y,2,2)
		end
		if link.direction==1 then
			spr(33+2*flr((link.walkstep%steptime)/(steptime/2)),link.x-carte.x,link.y-carte.y,2,2)
		end
		if link.direction==2 then
			spr(5+2*flr((link.walkstep%steptime)/(steptime/2)),link.x-carte.x,link.y-carte.y,2,2)
		end
		if link.direction==3 then
			spr(37+2*flr((link.walkstep%steptime)/(steptime/2)),link.x-carte.x,link.y-carte.y,2,2)
		end
	else
		if link.direction==0 then
			spr(9,link.x-carte.x,link.y-carte.y,2,2)
			if link.attack>2 then
				spr(64,link.x-carte.x,link.y-carte.y-16,2,2)
			else
				spr(96,link.x-carte.x,link.y-carte.y-16,2,2)
			end
		end
		if link.direction==1 then
			spr(41,link.x-carte.x,link.y-carte.y,2,2)
			if link.attack>2 then
				spr(66,link.x-carte.x,link.y-carte.y+16,2,2)
			else
				spr(98,link.x-carte.x,link.y-carte.y+16,2,2)
			end
		end
		if link.direction==2 then
			spr(11,link.x-carte.x,link.y-carte.y,2,2)
			if link.attack>2 then
				spr(68,link.x-carte.x-16,link.y-carte.y,2,2)
			else
				spr(100,link.x-carte.x-16,link.y-carte.y,2,2)
			end
		end
		if link.direction==3 then
			spr(43,link.x-carte.x,link.y-carte.y,2,2)
			if link.attack>2 then
				spr(70,link.x-carte.x+16,link.y-carte.y,2,2)
			else
				spr(102,link.x-carte.x+16,link.y-carte.y,2,2)
			end
		end
	end
end

function drawhud()
	for k=0,link.maxlife-1 do -- on dessine les coeurs quartier par quartier
		if link.life-k>0 then
			spr(194+k%2+flr((k%4)/2)*16,(k%2)*8+flr(k/4)*17,flr((k%4)/2)*8) -- quartier rouge
		else
			spr(192+k%2+flr((k%4)/2)*16,(k%2)*8+flr(k/4)*17,flr((k%4)/2)*8) -- quartier gris
		end
	end
	
	rectfill(0,118,128,128,15)
	print("vague : "..wave,5,120,8)
	print("rubis : ",50,120,8)
	print(link.rupees,50+8*4,120,11)
end

function drawennemi()
	for k=0,maxennemi do
		if ennemis[k].life>0 then
			if ennemis[k].model==0 then --chauve-souris
				spr(196+flr((t%20)/10)*2,ennemis[k].x-carte.x,ennemis[k].y-carte.y,2,2)
			elseif ennemis[k].model==1 then --slime
				spr(224+flr((t%30)/15)*2,ennemis[k].x-carte.x,ennemis[k].y-carte.y,2,2)
			elseif ennemis[k].model==2 then --cracheur
				spr(229+ennemis[k].dir*2,ennemis[k].x-carte.x,ennemis[k].y-carte.y,2,2)
			else -- si erreur dans model on dessine glitchennemi
				spr(228,ennemis[k].x-carte.x,ennemis[k].y-carte.y,2,2)
			end
		end
	end
end

function collision(x,y) -- detecte si il y a collision a un certain point
                        -- x et y en coordonné map ex: x=(link.x/8)
	local listsolid={131,132,133,147,148,149,163,164,165,134,135,150,151}
	for bloc in all(listsolid) do
		if mget(x,y)==bloc then
			return true
		end
	end
	return false
end

function restoregrass() -- on refait pousser l'herbe en dehors de la caméra
	for k=0,carte.hauteur do
		for j=0,carte.largeur do
			if (k*8<carte.y-20 or k*8>carte.y+128+20) or (j*8<carte.x-20 or j*8>carte.x+128+20) then
				if mget(j,k)==136 then
					mset(j,k,134)
					mset(j+1,k,135)
					mset(j,k+1,150)
					mset(j+1,k+1,151)
				end
			end
		end
	end
end

function killennemis(x,y) -- savoir si un ennemi se trouve dans le rayon de l'épée
						  -- un ennemi vaut 10 pts de score
	local range=10
	for k=0,maxennemi do
		if ennemis[k].life>0 and t-lastkill>10 then
			if x>ennemis[k].x and x<ennemis[k].x+16 and y>ennemis[k].y and y<ennemis[k].y+16 then
				ennemis[k].life-=10
				if ennemis[k].life<=0 then
					sfx(-1)
					sfx(11)
					score+=10
					if score>hiscore then
						hiscore=score
						dset(0,hiscore)
					end
				end
				if ennemis[k].life<=0  and rnd()*100<30 then
					createbonus(ennemis[k].x+4,ennemis[k].y+4)
				end
				lastkill=t
			end
		end
	end
end

function controlwave() -- quand tous les ennemis sont morts
					   -- cette fonction génére la vague suivante
	local countalive=0
	for k=0,maxennemi do
		if ennemis[k].life>0 then
			countalive+=1
		end
	end
	
	if countalive==0 then
		wave+=1
		local nbdepart=flr((seed/maxrnd)*3)
		local maxennemis=((seed/maxrnd)*((wave%100)/100))*(20-nbdepart)
		for k=0,maxennemi do
			if k<maxennemis+nbdepart then
				if wave>0 and wave%5==0 and ennemis[k].model<2 then
					ennemis[k].model+=1
				end
				ennemis[k].life=10*(ennemis[k].model+1)
				repeat
					ennemis[k].x=flr((rnd(carte.largeur-3)+1)*8)
					ennemis[k].y=flr((rnd(carte.hauteur-3)+1)*8)
				until (ennemis[k].x>link.x-16*2 and ennemis[k].x<link.x+16+16*2) or (ennemis[k].y>link.y-16*2 and ennemis[k].y<link.y+16+16*2)
			end
		end
	end
end

function moveennemis() -- gère les ia des ennemis
	local speed=0
	for k=0,maxennemi do
		if ennemis[k].life>0 then
			if ennemis[k].model==0 then  -- suit le personnage
				speed=0.5
				if ennemis[k].x>8 and ennemis[k].x<carte.largeur*8 and (ennemis[k].x>link.x+4 or ennemis[k].x<link.x-4) then
					ennemis[k].x+=(flr((link.x-ennemis[k].x)/abs(link.x-ennemis[k].x)))*(speed)
				end
				if ennemis[k].x>8 and ennemis[k].x<carte.largeur*8 and (ennemis[k].y>link.y+4 or ennemis[k].y<link.y-4) then
					ennemis[k].y+=(flr((link.y-ennemis[k].y)/abs(link.y-ennemis[k].y)))*(speed)+(speed*1.7)*cos(ennemis[k].x/10)
				end
			elseif ennemis[k].model==1 then -- comme avant mais synchroniser avec l'animation de bond
				speed=8
				if (t+15)%30==0 then
					if ennemis[k].x>8 and ennemis[k].x<carte.largeur*8 and (ennemis[k].x>link.x+4 or ennemis[k].x<link.x-4) then
						ennemis[k].x+=(flr((link.x-ennemis[k].x)/abs(link.x-ennemis[k].x)))*(speed)
					end
					if ennemis[k].x>8 and ennemis[k].x<carte.largeur*8 and (ennemis[k].y>link.y+4 or ennemis[k].y<link.y-4) then
						ennemis[k].y+=(flr((link.y-ennemis[k].y)/abs(link.y-ennemis[k].y)))*(speed)+(speed*1.7)*cos(ennemis[k].x/10)
					end
				end
			elseif ennemis[k].model==2 then -- tourne, avance et se repose de façon aléatoire
											-- si link se situe dans la ligne de mire, le cracheur se retourne
											-- et tir un boulet dans sa direction
				speed=0.5
				if t%60==0 then
					if rnd(100)<30 then
						ennemis[k].dir+=flr(rnd()*4)-1
						ennemis[k].dir=ennemis[k].dir%4
					end
				end
				local timetoshoot=30
				-- l'ennemi essaie de détecter link
				if link.x>ennemis[k].x-4 and link.x<ennemis[k].x+12 then
					if link.y<ennemis[k].y then
						ennemis[k].dir=0
						if t-ennemis[k].lasttir>timetoshoot then
							ennemis[k].lasttir=t
							for kb=0,maxbullet do
								if bullet[kb].active==false then
									bullet[kb].x=ennemis[k].x+4
									bullet[kb].y=ennemis[k].y-8
									bullet[kb].dir=0
									bullet[kb].active=true
									break
								end
							end
						end
					else
						ennemis[k].dir=1
						if t-ennemis[k].lasttir>timetoshoot then
							ennemis[k].lasttir=t
							for kb=0,maxbullet do
								if bullet[kb].active==false then
									bullet[kb].x=ennemis[k].x+4
									bullet[kb].y=ennemis[k].y+16
									bullet[kb].dir=1
									bullet[kb].active=true
									break
								end
							end
						end
					end
				end
				if link.y>ennemis[k].y-4 and link.y<ennemis[k].y+12 then
					if link.x<ennemis[k].x then
						ennemis[k].dir=2
						if t-ennemis[k].lasttir>timetoshoot then
							ennemis[k].lasttir=t
							for kb=0,maxbullet do
								if bullet[kb].active==false then
									bullet[kb].x=ennemis[k].x-8
									bullet[kb].y=ennemis[k].y+4
									bullet[kb].dir=2
									bullet[kb].active=true
									break
								end
							end
						end
					else
						ennemis[k].dir=3
						if t-ennemis[k].lasttir>timetoshoot then
							ennemis[k].lasttir=t
							for kb=0,maxbullet do
								if bullet[kb].active==false then
									bullet[kb].x=ennemis[k].x+16
									bullet[kb].y=ennemis[k].y+4
									bullet[kb].dir=3
									bullet[kb].active=true
									break
								end
							end
						end
					end
				end
				if t-pausemodel>0 then -- l'ennemi ne bouge plus (se repose)
					if rnd(100)<80 then
						if ennemis[k].dir==0 and collision(flr((ennemis[k].x)/8),flr((ennemis[k].y-1)/8))==false and collision(flr((ennemis[k].x+15)/8),flr((ennemis[k].y-1)/8))==false then
							ennemis[k].y-=speed
						elseif ennemis[k].dir==1 and collision(flr((ennemis[k].x)/8),flr((ennemis[k].y+16)/8))==false and collision(flr((ennemis[k].x+15)/8),flr((ennemis[k].y+16)/8))==false then
							ennemis[k].y+=speed
						elseif ennemis[k].dir==2 and collision(flr((ennemis[k].x-1)/8),flr((ennemis[k].y)/8))==false and collision(flr((ennemis[k].x-1)/8),flr((ennemis[k].y+15)/8))==false then
							ennemis[k].x-=speed
						elseif ennemis[k].dir==3 and collision(flr((ennemis[k].x+16)/8),flr((ennemis[k].y)/8))==false and collision(flr((ennemis[k].x+16)/8),flr((ennemis[k].y+15)/8))==false then
							ennemis[k].x+=speed
						end
					else
						if t-pausemodel>60 then
							pausemodel=t+rnd(60)+30
						end
					end
				end
			end
		end
	end
end

function getswordpos() -- donne la coordonné haut gauche du sprite de l'épée
	local xsword=0
	local ysword=0
	if link.attack==0 then
		xsword=link.x
		ysword=link.y
	else
		if link.direction==0 then
			xsword=link.x
			ysword=link.y-16
		elseif link.direction==1 then
			xsword=link.x
			ysword=link.y+16
		elseif link.direction==2 then
			xsword=link.x-16
			ysword=link.y
		elseif link.direction==3 then
			xsword=link.x+16
			ysword=link.y
		end
	end
	return {xsword,ysword}
end

function move_bullet() -- déplace les boulets
	local bullet_speed=2
	for k=0,maxbullet do
		if bullet[k].active==true then
			if bullet[k].dir==0 then
				bullet[k].y-=bullet_speed
			elseif bullet[k].dir==1 then
				bullet[k].y+=bullet_speed
			elseif bullet[k].dir==2 then
				bullet[k].x-=bullet_speed
			elseif bullet[k].dir==3 then
				bullet[k].x+=bullet_speed
			end
			for kb=0,maxbullet do
				if bullet[kb].active==true and k!=kb and bullet[k].x+4>bullet[kb].x and bullet[k].x+4<bullet[kb].x+8 and bullet[k].y+4>bullet[kb].y and bullet[k].y+4<bullet[kb].y+8 then
					bullet[kb].active=false
					bullet[k].active=false
				end
			end
		end
		local swordpos=getswordpos() -- si un boulet touche l'épée il est renvoyé dans l'autre sens
		if bullet[k].x+4>swordpos[1] and bullet[k].x+4<swordpos[1]+16 and bullet[k].y+4>swordpos[2] and bullet[k].y+4<swordpos[2]+16 and link.attack==1 and bullet[k].invert==0 and t-lasthit>5 then
			if bullet[k].dir==0 then
				bullet[k].dir=1
			elseif bullet[k].dir==1 then
				bullet[k].dir=0
			elseif bullet[k].dir==2 then
				bullet[k].dir=3
			elseif bullet[k].dir==3 then
				bullet[k].dir=2
			end
			bullet[k].invert=1
			lasthit=t
		end
		-- si 2 boulet se touche, il se détruise
		if collision(flr((bullet[k].x+4)/8),flr((bullet[k].y-1)/8))==false and collision(flr((bullet[k].x+4)/8),flr((bullet[k].y+8)/8))==false and collision(flr((bullet[k].x-1)/8),flr((bullet[k].y+4)/8))==false and collision(flr((bullet[k].x+8)/8),flr((bullet[k].y+4)/8))==false then
		
		else
			bullet[k].active=false
		end
	end
end

function linkdeath() -- regarde si link touche un ennemi
					 -- lui enleve de la vie
					 -- et vérifie si il est mort
	if t-lasthit>5 then
		for k=0,maxennemi do
			if link.x+8>ennemis[k].x-2 and link.x+8<ennemis[k].x+18 and link.y+8>ennemis[k].y-2 and link.y+8<ennemis[k].y+18 and ennemis[k].life>0 then
				link.life-=1
				sfx(15)
				lasthit=t
				break
			end
		end
		for k=0,maxbullet do
			if link.x+8>bullet[k].x-2 and link.x+8<bullet[k].x+10 and link.y+8>bullet[k].y-2 and link.y+8<bullet[k].y+10 and bullet[k].active==true then
				bullet[k].active=false
				link.life-=1
				sfx(15)
				lasthit=t
				break
			end
		end
		
		if link.life<=0 then
			mode=1
			t=0
			wave=0
			link.x=16
			link.y=16
			link.speed=2
			link.direction=1
			link.walkstep=0
			link.attack=0
			link.life=link.maxlife
			for k=0,maxennemi do
				ennemis[k].life=0
				ennemis[k].model=0
			end
		end
	end
end

function createbonus(x,y) -- génére un nouveau bonus
	for k=0,maxbonus do
		if bonus[k].model==0 then
			bonus[k].x=x
			bonus[k].y=y
			bonus[k].naissance=t -- lui donne la date actuelle
			bonus[k].model=1+flr(rnd()*2)
			break
		end
	end
end

function draw_bullet() -- dessine les boulet de canon actif
	local compteuralive=0
	for k=0,maxbullet do
		if bullet[k].active==true then
			spr(244,bullet[k].x-carte.x,bullet[k].y-carte.y)
			compteuralive+=1
		else
			bullet[k].invert=0
		end
	end
end

function applybonus(model) -- applique un bonus suivant sont type (coeur, rubis, ...)
	if model==1 then
		sfx(14)
		link.rupees+=1
		score+=1
		if score>hiscore then
			hiscore=score
			dset(0,hiscore)
		end
	elseif model==2 then
		sfx(13)
		link.life+=1
	end
	if link.life>link.maxlife then
		link.life=link.maxlife
	end
end

function draw_bonus() -- dessine les bonus au sol
	for k=0,maxbonus do
		if bonus[k].model>0 then
			-- les bonus disparaissent après un certain temp (date de naissance)
			if bonus[k].naissance>0 and t-bonus[k].naissance<300 and bonus[k].model>0 then
				spr(73+bonus[k].model-1,bonus[k].x-carte.x, bonus[k].y-carte.y)
			else
				bonus[k].model=0
			end
		end
	end
end

function collectbonus(x,y) -- regarde si link a collecté un bonus
	for k=0,maxbonus do
		if x>bonus[k].x-2 and x<bonus[k].x+10 and y>bonus[k].y-2 and y<bonus[k].y+10 and bonus[k].model>0 then
			applybonus(bonus[k].model)
			bonus[k].model=0
			if link.attack==1 then
				lastkill=t
			end
		end
	end
end

function appartientcoord(listecomplete,objet) -- savoir si des coordonné sont déjà dans une liste
	for v in all(list_complete) do
		if v[1]==objet[1] and v[2]==objet[2] then
			return true
		end
	end
	return false
end

function cutcase() -- regarde les cases dans lesquelle l'épée peut couper quelque chose
	local numcase=0
	local posx=0
	local posy=0
	local lastpos={}
	local coinx=0
	local coiny=0
	local listecase={}
	if link.direction==0 then
		coinx=link.x
		coiny=link.y-16
	elseif link.direction==1 then
		coinx=link.x
		coiny=link.y+16
	elseif link.direction==2 then
		coinx=link.x-16
		coiny=link.y
	elseif link.direction==3 then
		coinx=link.x+16
		coiny=link.y
	end
	for k=0,15,5 do
		for j=0,15,5 do
			posx=flr((coinx+j)/8)
			posy=flr((coiny+k)/8)
			if t-lastkill>10 then
				collectbonus(coinx+j,coiny+k)
			end
			if k%2==0 then
				killennemis(coinx+j,coiny+k)
			end
			if appartientcoord(lastpos,{posx,posy})==false then
				numcase=mget(posx,posy)
				add(listecase,{numcase,posx,posy})
			end
			add(lastpos,{posx,posy})
		end
	end
	return listecase
end

function link_movement() -- deplacement de link et attaque
	if btn(0) or btn(1) or btn(2) or btn(3) then
		link.walkstep+=1
	end
	if btn(2) then
		if collision(flr(link.x/8),flr((link.y-link.speed+8)/8))==false and collision(flr((link.x+15)/8),flr((link.y-link.speed+8)/8))==false then
			link.y-=link.speed
		end
		link.direction=0
	end
	if btn(3) then
		if collision(flr(link.x/8),flr((link.y+link.speed+16)/8))==false and collision(flr((link.x+15)/8),flr((link.y+link.speed+15)/8))==false then
			link.y+=link.speed
		end
		link.direction=1
	end
	if btn(0) then
		if collision(flr((link.x-link.speed)/8),flr((link.y+8)/8))==false and collision(flr((link.x-link.speed)/8),flr((link.y+15)/8))==false then
			link.x-=link.speed
		end
		link.direction=2
	end
	if btn(1) then
		if collision(flr((link.x+link.speed+16)/8),flr((link.y+8)/8))==false and collision(flr((link.x-link.speed+15)/8),flr((link.y+15)/8))==false then
			link.x+=link.speed
		end
		link.direction=3
	end
	
	if btn(4) then
		link.attack+=1
		if link.attack==1 then
			sfx(12)
		end
	end
	if btn(4)==false then
		link.attack=0
		lastkill=0
	end
	
	if link.attack>0 then
		local corrx=0
		local corry=0
		local replacetile=0
		local casetocut=cutcase()
		for vcase in all(casetocut) do
			if vcase[1]==134 then
				corrx=vcase[2]
				corry=vcase[3]
				replacetile=1
				break
			elseif vcase[1]==135 then
				corrx=(vcase[2]-1)
				corry=vcase[3]
				replacetile=1
				break
			elseif vcase[1]==150 then
				corrx=vcase[2]
				corry=(vcase[3]-1)
				replacetile=1
				break
			elseif vcase[1]==151 then
				corrx=(vcase[2]-1)
				corry=(vcase[3]-1)
				replacetile=1
				break
			end
		end
		
		if replacetile==1 then -- on détruit l'herbe coupée
			sfx(-1)
			sfx(10)
			mset(corrx,corry,136)
			mset(corrx+1,corry,137)
			mset(corrx,corry+1,152)
			mset(corrx+1,corry+1,153)
			lastkill=t
			if rnd()*100<30 then
				createbonus(corrx*8+4,corry*8+4)
			end
		end
	end
	
	collectbonus(link.x,link.y)
	collectbonus(link.x+15,link.y)
	collectbonus(link.x,link.y+15)
	collectbonus(link.x+15,link.y+15)
	collectbonus(link.x+8,link.y+8)
	
	if link.x<carte.x+32 and carte.x-link.speed>=0 then
		carte.x-=link.speed
	end
	if link.y<carte.y+32 and carte.y-link.speed>=0 then
		carte.y-=link.speed
	end
	if link.x>carte.x+128-32-16 and carte.x+link.speed<=(carte.largeur-16)*8 then
		carte.x+=link.speed
	end
	if link.y>carte.y+128-32-16 and carte.y+link.speed<=(carte.hauteur-15)*8 then
		carte.y+=link.speed
	end
end

function _update()
	if mode==1 then
	
	end
	if mode==2 then
		restoregrass()
		move_bullet()
		link_movement()
		controlwave()
		moveennemis()
		linkdeath()
	end
end

function _draw()
	if mode==1 then
		menu()
	end
	if mode==2 then
		cls()
		map(flr(carte.x/8)-1,flr(carte.y/8)-1,-(carte.x%8)-8,-(carte.y%8)-8,18,18)
		draw_bullet()
		draw_bonus()
		drawennemi()
		drawzelda()
		drawhud()
	end
	if t>30000 then
		t=0
	end
	t+=1
end
__gfx__
00000000000000555000000000000005550000000000005555500000000000000000000000000000555550000000000000000000000000000000000000000000
0000000000000555550000000000005555500000000055b7bbb50000000005555550000000000055577575000000055555500000000000000000000000000000
00700700000005777750000000000577775000000005775b77bb500005055b77bbb55000000005b77577550005055b777bb55500000000000000000000000000
00077000000557555575500000055755557550000055b775bb5bb500055775bb77bbb50000005b77bb577550055775bb777bbb50000000000000000000000000
00077000005f55b77b55f500005f55b77b55f50005555b7755f5bb50055b775bb5bbb5000055577b555b7550055b775bb5bbbb50000000000000000000000000
00700700005f5bb77bb5f500005f5bb77bb5f5000000555b5ef5bb500055b7755f5bb50005bb5bbb5f55b5550055b7755f5bb500000000000000000000000000
00000000005f5b5b7bb5f500005f5bb7b5b5f5000055f5f55ff5b500000555b5ef5b500005bbb5bb5ff55555005555b5ef5b5000000000000000000000000000
00000000005e55bb7bb5e500005e5bb7bb55e500005ff5ff5ff55000055f5f55ff5b5000005bbbbb5ff5f500055f5f55ff5b5000000000000000000000000000
00000000000555bbbb555000000555bbbb5550000005efff5fe5000005ff5ff5ff5500000005bbbb5ef5f50005ff5ff5ff550000000000000000000000000000
000000000005b5bbb5b5b500005b5b5bbb5b500000005eee5e550000005efff5fe5000000000555bb5e55500005efff5fe500000000000000000000000000000
00000000005fb5bb5bb5b500005b5bb5bb5bf5000000555555b5000000055555555000000055bb555555b5000555555555500000000000000000000000000000
00000000005f5b55bb7b55000055b7bb55b5f50000005b5ff5bb500000005ff5bb55000005ffbb5bbb7b55005ff5bbb5b7b55000000000000000000000000000
000000000005b77777bb50000005bb77777b50000000575ff5bb500000005ff5bb5f500005ffb5b777bb55505ff5bb577bb5f500000000000000000000000000
0000000000055bbbbb555000000555bbbbb5500000005b55555550000005555bb55f50000055555bbbb5ff500555555bbb55f500000000000000000000000000
000000000005555555ff55000055ff55555550000000555ffff50000005ffff555ff50000005fff5555ff5500005fff5555ff500000000000000000000000000
00000000000055555555500000055555555500000005555555555000005555555555550000055555555555000055555555555550000000000000000000000000
00000000000000555550000000000555550000000000055555000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005b77bb5000000005bb77b50000000005bbb7b550000000005555550000000000005555500000000055555500000000000000000000000000000
00000000000055b55bbb55000055bbb55b5500000005bb77b577500000055bbb77b5505000000055b7bb500000555bb777b55050000000000000000000000000
000000000005f557777b5f5005f5b777755f5000005bb5bb577b5500005bbb77bb5775500000555b77b5550005bbb777bb577550000000000000000000000000
000000000005f57555575f5005f57555575f500005bb5f5577b55550005bbb5bb577b5500005f5bb77bb5f5005bbbb5bb577b550000000000000000000000000
000000000005f55555555f5005f55555555f500005bb5fe5b5550000005bb5f5577b55000005f555b5555f50005bb5f5577b5500000000000000000000000000
000000000005ee555555ee5005ee555555ee5000005b5ff55f5f55000005b5fe5b5550000005f57777775f500005b5fe5b555500000000000000000000000000
0000000000005ff5ff5ff500005ff5ff5ff5000000055ff5ff5ff5000005b5ff55f5f5500055ee555555ee500005b5ff55f5f550000000000000000000000000
0000000000005ef5ff5fe500005ef5ff5fe5000000005ef5fffe5000000055ff5ff5ff5005ff5fe5555ef500000055ff5ff5ff50000000000000000000000000
000000000005b5effffe5b5005b5effffe5b5000000055e5eee50000000005ef5fffe500005f5ef5ff5fe500000005ef5fffe500000000000000000000000000
00000000005fb55555555b5005b55555555bf50000005b55555500000000055555555000000555effffe50000000055555555550000000000000000000000000
00000000005f55bbbb5ffb5005bff5bbbb55f5000005bb5ff5b50000000055bb5ff5000000005b555555b50000055b7b5bbb5ff5000000000000000000000000
0000000000055b77775ff500005ff57777b550000005bb5ff57500000005f5bb5ff50000000555b7bb5bb500005f5bb775bb5ff5000000000000000000000000
0000000000005555bbb5500000055bbb555500000005555555b500000005f55bb55550000005bb5b77555500005f55bbb5555550000000000000000000000000
0000000000055b77555555000055555577b5500000005ffff55500000005ff555ffff50000005555bb5ff500005ff5555fff5000000000000000000000000000
00000000000055555555500000055555555500000005555555555000005555555555550000000005555ff5500555555555555500000000000000000000000000
00000000000550000000000000555500000000000000000000000000000000000005500000005555000000000000000000000000000000000000000000000000
000000000057750000000000005bb50000000000000000000000000000000000005bb50000057775055005500000000000000000000000000000000000000000
00000000005775000000000005b77b5000000000000000000000000000000000053b7b5000577775588558850000000000000000000000000000000000000000
00000000005775000000000005b77b5000000000000000000000000000000000053b7b5005773bb5589889850000000000000000000000000000000000000000
0000000000577500000000000555555000000000000000000000000000000000053b7b505773bb50589999850000000000000000000000000000000000000000
0000000000577500000000000057750000000000000000000000000000000000053bbb50533bb500058998500000000000000000000000000000000000000000
000000000057750000000000005775000000000000000000000000000000000000533500533b5000005885000000000000000000000000000000000000000000
00000000005775000000000000577500000000000000000000000000000000000005500055550000000550000000000000000000000000000000000000000000
00000000005775000000000000577500000000000000000000000000000000000000000000777777777777720000000000000000000000000000000000000000
00000000005775000000000000577500000000000005550000555000000000000000000007888888888888200000000000000000000000000000000000000000
00000000005775000000000000577500055555555555bb5555bb5555555555500000000007888888888888200000000000000000000000000000000000000000
0000000005555550000000000057750057777777777577b55b775777777777750000000072222222882782000000000000000000000000000000000000000000
0000000005b77b50000000000057750057777777777577b55b775777777777750000000000000007827820000000000000000000000000000000000000000000
0000000005b77b500000000000577500055555555555bb5555bb5555555555500000000000000007877820000000000000000000000000000000000000000000
00000000005bb5000000000000577500000000000005550000555000000000000000000000000078888200000000000000000000000000000000000000000000
00000000005555000000000000055000000000000000000000000000000000000000000000000788782000000000000000000000000000000000000000000000
00000000000000000575000000055550000000000000000000000000000000000000000000000787882000000000000000000000000000000000000000000000
000000000055555505750000005ccc55000000000055555555555500000000000000000000007888820000000000000000000000000000000000000000000000
000000005577777705750000000577c5000000005577777777777755000000000000000000078278200000000000000000000000000000000000000000000000
000055057777755505775000005c57c5000055057777755555577777505500000000000000078778200000000000000000000000000000000000000000000000
0005775777755000057750000577c5c5000577577775500000055777757750000000000000782788277777720000000000000000000000000000000000000000
00057775755000000577750057775050000577757550000000000557577750000000000007888888888888200000000000000000000000000000000000000000
00005777500000000057750577750000000057775000000000000005777500000000000007888888888888200000000000000000000000000000000000000000
00057577750000000057775777500000000575777500000000000057775750000000000072222222222222000000000000000000000000000000000000000000
00577757775000000005757775000000005777577750000000000577757775000000000000000000000000000000000000000000000000000000000000000000
00577505777500000000577750000000005775057775000000005777505775000000000000000000000000000000000000000000000000000000000000000000
05777500577750500005777575500000057775005777505005057775005777500000000000000000000000000000000000000000000000000000000000000000
057750000577c5c50005775777755000057750000577c5c55c5c7750000577500000000000000000000000000000000000000000000000000000000000000000
05775000005c57c5000055057777755505775000005c57c55c75c500000577500000000000000000000000000000000000000000000000000000000000000000
05750000000577c5000000005577777705750000000577c55c775000000057500000000000000000000000000000000000000000000000000000000000000000
05750000005ccc55000000000055555505750000005ccc5555ccc500000057500000000000000000000000000000000000000000000000000000000000000000
05750000000555500000000000000000057500000005555005555000000057500000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffff1111111111111111fffffffffffffffffffffffffffffffffffff999999ff999999f00000000000000000000000000000000
fffb3bb33bb33bb33bb3bfffff111dddddddddddddd111fffffffff55fffffffffffffffffffffff999999999999999900000000000000000000000000000000
ff33b33bb33bb33bb33b33fff11ddd111111111111ddd11ff55fff5bb5fff55fffffffffffffffff999949999999499900000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bff1dd1111111111111111dd1ff5b5f5bbbb5f5b5fffffffffffffffff949999999499999900000000000000000000000000000000
f3bbbb3bbbbbbbbbb3bbbb3f11d149994499994499941d11f5bb55b55b55bb5fffffffffffffffff999999999999999900000000000000000000000000000000
fb3bbbb3bbbbbbbb3bbbb3bf1dd199449944449944991dd1f5b3b55bb55b3b5fffffffffffffffff99999f9999999f9900000000000000000000000000000000
fb3bb333bbbbbbbb333bb3bf1d11945444444444454911d1f5bb3b5bb5b3bb5fffffffffffffffff999999999999999900000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d11944555555555544911d1ff5bb35bb53bb5fffffffffffffffffff999999ff999999f00000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d114945fff55fff549411d1fff5555335555ffffffffffffffffffff999999ff999999f00000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bf1d114945555bb555549411d1ff5bb355553bb5ffffffffffffffffff999999999999999900000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bf1d11944553533535544911d1f5bb3b5b3533bb5fffffffffffffffff999949999999499900000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d1194455b3333b5544911d1f5bbb5bb3b5bbb5fffffffffffffffff949999999499999900000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d119445f5b5535f544911d1f55555bbbb55555fffffffffffffffff999999999999999900000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bf1d1194455b3b33b5544911d1fffff5bbbb5fffffffffffffffffffff99999f9999999f9900000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bf1d114945f55bb55f549411d1ffffff5555ffffffffffffffffffffff999999999999999900000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d114945fff55fff549411d1fffffffffffffffffffffffffffffffff999999ff999999f00000000000000000000000000000000
f3bbbbbbbbbbbbbbbbbbbb3f1d11944555555555544911d1bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
fb3bbb3bbbbbbbbbb3bbb3bf1d11945444444444454911d1bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
fb3bbbb3bbbbbbbb3bbbb3bf1dd199449944449944991dd1bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
f3bbb333bbbbbbbb333bbb3f11d149994499994499941d11bbbbbbb33bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
fb3bbbbbbbbbbbbbbbbbb3bff1dd1111111111111111dd1fbbbbb33bb33bbbbb0000000000000000000000000000000000000000000000000000000000000000
ff33b33bb33bb33bb33b33fff11ddd111111111111ddd11fbbbb33bbbb33bbbb0000000000000000000000000000000000000000000000000000000000000000
fffb3bb33bb33bb33bb3bfffff111dddddddddddddd111ffbbbb3bb33bb3bbbb0000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffff1111111111111111ffffbbb3bb3333bb3bbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbb3bb3333bb3bbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbb3bb33bb3bbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbb33bbbb33bbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbb33bb33bbbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbb33bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055500005550000005550000555000000000000000000000000050050000000000000000000000000000000000000000000000000000000000000000000000
00577750057775000057775005777500000000000000000000000050050000000000000000000000000000000000000000000000000000000000000000000000
05755575575557500575557557555750000500000000500000000550055000000000000000000000000000000000000000000000000000000000000000000000
57555557755555755758885775888575005500500500550000000555555000000000000000000000000000000000000000000000000000000000000000000000
57555555555555755758888558888575005550500505550000005575575500000000000000000000000000000000000000000000000000000000000000000000
57555555555555755758888888888575055555555555555000005575575500000000000000000000000000000000000000000000000000000000000000000000
57555555555555755758888888888575055557755775555000005555555500000000000000000000000000000000000000000000000000000000000000000000
05755555555557500575888888885750555555755755555500005505505500000000000000000000000000000000000000000000000000000000000000000000
00575555555575000057588888857500555005555550055500005500005500000000000000000000000000000000000000000000000000000000000000000000
00057555555750000005758888575000500000055000000500005000000500000000000000000000000000000000000000000000000000000000000000000000
00005755557500000000575885750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000575575000000000057557500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000057750000000000005775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005500000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005555000000000000000000000000000000000005555550000000000000000000000000000000000000000000000000000000000000
0000000000000000000005bbbb500000005555000005555555555000000058888885000000055500555500000000555500555000000000000000000000000000
000000000000000000005bb77bb50000058877500005887777885000055588877888555000058855fff8550000558fff55885000000000000000000000000000
000000000000000000005bb77bb5000058888785000055555555000058858877778858850550558f55f8785005878f55f8550550000000000000000000000000
000000000000000000005bbbbbb500005818881500000587785000005558888778888555058505f55f877785587778f55f505850000000000000000000000000
000005555550000000005b1bb1b500005818881500005588885500000058ff8888ff8500057558ffff877785587778ffff855750000000000000000000000000
00005bbbbbb5000000005b1bb1b500005888888555558ffffff855550558f5ffff5f8550057578ffff887885588788ffff875750000000000000000000000000
0005bbb77bbb500000005b1bb1b500000555555058558f5ff5f855855858f55ff55f8585057578f55ff8888558888ff55f875750000000000000000000000000
005bbb7777bbb50000005b1bb1b50000055555505858f55ff55f858558558f5ff5f85585057578ff55f8888558888f55ff875750000000000000000000000000
005bbbb77bbbb50000005b1bb1b50000599559950558f5ffff5f855055558ffffff855550575888ff5f8888558888f5ff8885750000000000000000000000000
005bbbbbbbbbb50000005bbbbbb50000595ff5950058ff8888ff8500000055888855000005855588fff8885005888fff88555850000000000000000000000000
005bbb1bb1bbb50000005bbbbbb50000595ff5955558888778888555000005877850000005855555885555500555558855555850000000000000000000000000
005bbb1bb1bbb50000055bbbbbb55000595ff5955885887777885885000055555555000005505577555775500557755577550550000000000000000000000000
0055bbbbbbbb550000055bbbbbb55000559559550555888778885550000588777788500000005885555588500588555558850000000000000000000000000000
00055bbbbbb55000000555bbbb555000599999950000588888850000000555555555500000058855555558855885555555885000000000000000000000000000
00005555555500000000555555550000055555500000055555500000000000000000000000055500000005555550000000555000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8384848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9380818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181829500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191a6a1a1a1a1a1a1a1a1a1a1a1a1a791919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191928687868786878687868786879091919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191929697969796979697969796979091919191919191919191919191919191919191919191919191919191919191929500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191928687868786878687868786879091919191919191919191a6a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a29500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191929697969796979697969796979091919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191928687868786878687868786879091919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191929697969796979697969796979091919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191b6818181818181818181818181b791919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9390919191919191919191919191919191919191919191919191919191928a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
93a0a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a28a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a9500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01100000320343303433030350343703437030370303200132034320303203032030320303203033001330013703437034390343a0343c0343903435001350013503430034300303003030030300303003037001
0110000030034320343503433034320343003432034370042b0342b0342b0302b0302b0302b0302b030000042b0342a0342b0342d0342e0343003432034320343203432034320343203400004000040000400004
011000003203430034320343a0343903437034370303703037030370303203432034320342e00437034380340000000000390343c0343c0303c03000000000003c0343e0343f034350343f0343e0343e0303e030
011000000e0230e0200e0200e020130231302013020130200e0230e0200e0200e0200e0230e0200e0200e02013023130201302013020150231502015020150200c0230c0200c0200c0200c0230c0200c0200c020
011000000000000000000000f0300000000000000001b03000000000000000000000000000000000000030540305403054020500000000000000000e030110300000000000000000000000000000000e0340e034
011000000e03007030000000000000000070340703407034070340000000000070340703407034070340000000000000000703407034070340703407030000000000007030070300000005030000000303000000
011000000000000000030300000007030090300203000000000000000001034010340103408030000000000000000080300000000030030300000000000000000000008034080340803402030020300000000000
011000002b0302b03000000000002633026330263302633000000000002b3352b3352d3302f330303303233032330323303233000000000003233532335333303533037330373303733037330000000000000000
011000003733537335353303333035330000000000033330323303233032330323300000000000323303333032330303303033030334323303333033330333303333032330303302e330000002e3303033032300
01100000323303233032330323300000000000303302e3302d3302f33031330313303133031330000000000034330343303433030000323303233032330000001c3351c3351c3352603026033320333203000000
01100000182132b2132b2132b2131f203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
011000000c2131d2131d2132b21300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001861321211296030060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011000003002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000240223b0223b0140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000260131a113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 04 43 44
00 01 05 43 44
00 02 06 43 44
00 07 42 43 44
00 08 42 43 44
02 09 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
