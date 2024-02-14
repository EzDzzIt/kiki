pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function start_game()
	cls(0)
	--game state
	gstate=1
	--init player
	pl={}
	new_actor(pl,0)
	--projectiles array
	proj={}
	--enemies array
	en={}
	--explosions array
	ex={}
	--map objects array
	obj={}
	--globals
	t=1 --counts frames
	tmst=time() --time when level starts
	tmcur=0
	pl_speed=0.9 --speed upgrade
	kb=90 --invis frames
	score=0
		--dark blue transparent
	palt(0,false)
	palt(1,true)
end

function update_game()
	--projectiles
	proj_update()
	--enemies
	en_update()
	--player
	pl_update()
	--explosions
	ex_update()
	--level control
	update_game_logic()
	
	--counter an time
	t+=1
	if t>60 then
		t=1
	end
	tmcur = time()-tmst
end

function update_title()
	if btnp()!=0 then
		start_game()
	end
end

function update_gameover()
	if btnp()!=0 then
		gstate=0
	end
end

function _init()
	cls(0)
	--game state
	gstate=0
end

function _update60()
	if gstate==1 then
		update_game()
	elseif gstate==2 then
		update_gameover()
	elseif gstate==0 then
		update_title()
	end
end


-->8
--drawing
function draw_game()
	cls(0)
	--draw background
	map(0,0,0,0,16,16)
	--draw map objects
	for i=1,#obj do
		--pass
	end
	--draw projectiles
	for i=1,#proj do
		spr(proj[i].spr,proj[i].x,proj[i].y)
	end
	--draw enemies and enemies dying
	for i=1,#en do
		spr(en[i].spr,en[i].x,en[i].y,1,1,en[i].flip)
	end
	--draw player
 spr(pl.spr,pl.x,pl.y,1,1,pl.flip)
	--draw explosions
	for i=1,#ex do
		circfill(ex[i].x,ex[i].y,ex[i].rad,ex[i].colr)
	end
	--draw score
	rectfill(0,0,128,10,0)
	print("player hp: " .. pl.hp .."   score: " .. score,0,1,7)
	--debug
	_debug()
end

function draw_title()
	cls(0)
	print("⬅️░ˇ░⬅️ 🅾️♪░")
	print("◆➡️░★★ █♪▤ ⌂░▤ ⧗🅾️ 🐱🅾️♪⧗☉♪⬆️░")
end

function draw_gameover()
	cls(0)
	print("●█😐░ 🅾️ˇ░➡️")
	print("◆➡️░★★ █♪▤ ⌂░▤ ⧗🅾️ 🐱🅾️♪⧗☉♪⬆️░")
	print("✽☉♪█⬅️ ★🐱🅾️➡️░: " .. score)
end

function _draw()
	if gstate==1 then
		draw_game()
	elseif gstate==2 then
		draw_gameover()
	elseif gstate==0 then
		draw_title()
	end
end
-->8
--tools
function new_actor(act,custom)
	act.x=64
	act.y=64
	act.xsp=0
	act.ysp=0
	act.spd=1 --speed mod
	act.spr=1
	act.flip=false --sprflip
	act.ani=1 --animation timer for actor
	act.hp=3
	if custom==0 then --player char
	 act.dir=4 --dir is 0-7 clockwise from 12o'clock
		act.dirbuf=-1
		act.atktime=0
		act.knock={0,0,0,false} --dx,dy,timer
	end
	
end

function new_proj()
	local pro={}
	pro.x=pl.x
	pro.y=pl.y
	pro.flip=false --sprflip
	pro.bspd=2.5
	pro.dmg=1
	local sp=1*pro.bspd
	local diag=0.714*pro.bspd
	if pl.dir==0 then
		pro.xsp=0
		pro.ysp=-sp
		pro.spr=24
	elseif pl.dir==1 then
		pro.xsp=diag
		pro.ysp=-diag
		pro.spr=22
	elseif pl.dir==2 then
		pro.xsp=sp
		pro.ysp=0
		pro.spr=21
	elseif pl.dir==3 then
		pro.xsp=diag
		pro.ysp=diag
		pro.spr=23
	elseif pl.dir==4 then
		pro.xsp=0
		pro.ysp=sp
		pro.spr=24
	elseif pl.dir==5 then
		pro.xsp=-diag
		pro.ysp=diag
		pro.spr=22
		pro.flip=true
	elseif pl.dir==6 then
		pro.xsp=-sp
		pro.ysp=0
		pro.spr=21
	elseif pl.dir==7 then
		pro.xsp=-diag
		pro.ysp=-diag
		pro.spr=23
		pro.flip=true
	end
	add(proj,pro)
end

function new_explosion(x,y,rad,colr)
	local _ex={}
	_ex.x=x
	_ex.y=y
	_ex.rad=rad
	_ex.colr=colr
	_ex.spr=1
	_ex.counter=10
	add(ex,_ex)
end

--update and resolve projectiles
function proj_update()
	for i=#proj,1,-1 do
	--looping reverse
		local pro = proj[i]
		--apply speed
		pro.x+=pro.xsp
		pro.y+=pro.ysp
		pro.x=flr(pro.x)+0.5--correction for diag
		pro.y=flr(pro.y)+0.5
		--check collisions with en
		for j=1,#en do
			if chk_col(pro,en[j]) then
				en[j].hp-=pro.dmg
				new_explosion(pro.x+3,pro.y+3,2,12)
				del(proj,pro)
			end
		end
		--delete projectiles offscreen
		if pro.x > 128 or pro.x < 0 then
			deli(proj,i)
		end
		if pro.y > 128 or pro.y < 0 then
			deli(proj,i)
		end
	end
end

--update and resolve explosions
function ex_update()
	if #ex>0 then
		for i=#ex,1,-1 do
		--looping reverse
			if ex[i].counter<=0 then
				del(ex,ex[i])
			else
				ex[i].counter-=1
			end
		end
	end
end

--collide function
function chk_col(a,b)
	if a.x>b.x+7 then return false end
	if a.x+7<b.x then return false end
	if a.y>b.y+7 then return false	end
	if a.y+7<b.y then return false end
	return true
end
-->8
--player behavior
function pl_update()
	--make sure we are not dead
	if pl.hp<=0 then
		--todo
		gstate=2--gameover
		return
	end
	--get current button pressed
	local bt = btn()
	--modify the bitfield to exclude attack buttons
	local btm = bt&0b001111
	local bta = bt&0b110000
	--speed vars
	local sp=1*pl_speed
	local diag=0.714*pl_speed
	--locomotion cases
	if btm==0b0100 or btm==0b0111 then --dir0
		pl.ysp=-sp
		pl.xsp=0
		pl.dir=0
	elseif btm==0b0110 then --dir1
		pl.ysp=-diag
		pl.xsp=diag
		pl.dir=1
	elseif btm==0b0010 then --dir2
		pl.xsp=sp
		pl.ysp=0
		pl.dir=2	
	elseif btm==0b1010 then --dir3
		pl.ysp=diag
		pl.xsp=diag
		pl.dir=3		
	elseif btm==0b1000 or btm==0b1011 then --dir4
		pl.ysp=sp
		pl.xsp=0	
		pl.dir=4
	elseif btm==0b1001 then --dir5
		pl.ysp=diag
		pl.xsp=-diag
		pl.dir=5
	elseif	btm==0b0001 then --dir6
		pl.xsp=-sp
		pl.ysp=0
		pl.dir=6
	elseif btm==0b0101 then --dir7
		pl.ysp=-diag
		pl.xsp=-diag
		pl.dir=7
	else
		pl.ysp=0
		pl.xsp=0
	end
	
	--apply knockback and invincibility
	if pl.knock[4] then
		local kb=3
		if pl.knock[1]>0 then
			pl.xsp+=kb
		else
			pl.xsp-=kb
		end
		if pl.knock[2]>0 then
			pl.ysp+=kb
		else
			pl.ysp-=kb
		end
		pl.knock[4]=false --run this code one time
	elseif pl.knock[3]>0 then
		pl.knock[3]-=1 --decrement invis
	else
		pl.knock[3]=0 --ensure 0?
	end
	
	--apply speed
	pl.y+=pl.ysp
	pl.x+=pl.xsp
		--correct diag
	pl.y=flr(pl.y)+0.5
	pl.x=flr(pl.x)+0.5
	--map collision check
	if fget(mget((pl.x+4)/8,(pl.y+7)/8),0) then
		pl.y-=pl.ysp
		pl.x-=pl.xsp
	end
		
	--check for attack input
	if bta==0b100000 and pl.knock[3]<=30 then
		if pl.atktime%19==0 then --limit proj amount
			new_proj()
			--play proj sound
			sfx(0)
		else
		 pl.atktime+=1
		end
		pl.atktime+=1
	else
		pl.atktime=0
	end
	
	animate_pl(btm)
	
end

function animate_pl(bt)
	--set sprite base if dir changes
	if pl.dir!=pl.dirbuf or pl.ani>=39 or pl.knock[3]==1 then
		pl.flip=false --saving tokems
		pl.ani=0 --reset animation time
		if pl.dir==0 then
			pl.spr=17
		elseif pl.dir==1 then
			pl.spr=5
		elseif pl.dir==2 then
			pl.spr=33
		elseif pl.dir==3 then
			pl.spr=49
		elseif pl.dir==4 then
			pl.spr=1
		elseif pl.dir==5 then
			pl.spr=49
			pl.flip=true
		elseif pl.dir==6 then
			pl.spr=33
			pl.flip=true
		elseif pl.dir==7 then
			pl.spr=5
			pl.flip=true
		end
		
		--put kb sprite back if needed
		if pl.knock[3]>1 then
			pl.spr=32
		end
	end
		--if damage taken, that takes priority
	if pl.knock[3]==kb then
		pl.spr=32
	end
	if pl.ani==26 then
		if pl.knock[3]==0 then
			if pl.atktime>0 then
				pl.spr-=3
				pl.ani+=1
			else
				pl.spr+=1
				pl.ani+=1
			end
		else
			pl.spr=16
			pl.ani+=1
		end
	elseif pl.ani==13 then
		if pl.knock[3]==0 then
			if pl.atktime>0 then
				pl.spr+=3
				pl.ani+=1
			else
				pl.spr+=1
				pl.ani+=1
			end
		else
			pl.spr=32
			pl.ani+=1
		end
		--keep moving the ani timer if needed
	elseif bt!=0 or pl.knock[3]>0 or pl.atktime>0 then
		pl.ani+=1
	end
	--end with updating the direction buffer
	pl.dirbuf=pl.dir
end


-->8
--game logic
function update_game_logic()
		--add new enemies
	if tmcur%10==0 then
		local _en={}
		new_actor(_en,1)
		_en.spr=25
		_en.x=rnd(128)
		_en.y=rnd(128)
		add(en,_en)
	end
end
-->8
--enemy behavior
function en_update()
	--looping backwards
	for i=#en,1,-1 do
		if t%5==0 then
			local trigarr=trig(pl.x,pl.y,en[i].x,en[i].y)
			en[i].x+=(trigarr[1])
			en[i].y+=(trigarr[2])
			en[i].x=flr(en[i].x)+0.5
			en[i].y=flr(en[i].y)+0.5
		end
		--see if they got to the player
		--but only if not knocked back
		if pl.knock[3]==0 then
			if chk_col(en[i],pl) then
				sfx(1)
				pl.hp-=1
				--set knockback data
				pl.knock={pl.x-en[i].x,pl.y-en[i].y,kb,true}
			end
		end
		--check if enemy is dead and explode
		if en[i].hp<=0 then
			new_explosion(en[i].x+3,en[i].y+3,4,7)
			del(en,en[i])
			score+=100
			sfx(1)
		end
	end
end

function trig(x2,y2,x1,y1)
	local trigarr={}
	trigarr[1]=cos(atan2(x2-x1,y2-y1))
	trigarr[2]=sin(atan2(x2-x1,y2-y1))
	return trigarr
end


-->8
--debug
--todo sliding map col
--todo add melee
--todo add spread shot, speed boost, health+

function _debug()
	print(pl.knock[3],0,12)
	print(pl.ani)
	print(pl.atktime)
end
__gfx__
00000000110000111100001111000011119999111100011111000111110001111199911111111111111111111111111100000000000000000000000000000000
00000000107776011077760110777601197776911077001110770011107700111977991111111111111111111111111100000000000000000000000000000000
007007001f0ff0f11f0ff0f11f0ff0f11f0ff0f11000760110007601100076011999769111111111111111111111111100000000000000000000000000000000
0007700010ffff0110ffff0110ffff0119ffff911180001111800011118000111189991f11111111111111111111111100000000000000000000000000000000
0007700077077077770770777707707777977971100770f110077011100770f1199779f111111111111111111111111100000000000000000000000000000000
00700700f877768ff867768ff877768ff87777f11077771101777f11107777111977771111111111111111111111111100000000000000000000000000000000
0000000008888881f88888800888888f98888f811088881111888811108888111988881111111111111111111111111100000000000000000000000000000000
00000000168188611688186116818861168188611188861118886811118688111186681111111111111111111111111100000000000000000000000000000000
11000011110000111100001111000011119999111111111111111111111111111111111111777711111111111111111100000000000000000000000000000000
10777601107706011077060110770601197796911111111111111111111111111111111111707071117777111111111100000000000000000000000000000000
1f0880f1108008011080080110800801198998911777711111117711117711111117711111677771117070711111111100000000000000000000000000000000
f0cffc0f1700007117000071170000711799997f1768671111186711117681111176711111670711117777711111111100000000000000000000000000000000
77c77c77777607777776077777706777177967711177771111768111111867111178711177777111116707111111111100000000000000000000000000000000
17c77c81f877608ff870678ff806778f189677811111111111771111111177111176711116671111776771111111111100000000000000000000000000000000
08cccc81188888811888888ff8888881188888811111111111111111111111111177111111111111167711111111111100000000000000000000000000000000
cccccccc168818611681886116881861168818611111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11000011110000111100001111000011119999111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
10777601107777011077770110777701197777911111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
1f0880f11000f0f11000f0f11000f0f11999f0f1111111111111c1c1111111111111111111111111111111111111111100000000000000000000000000000000
f0cffc0f18000ff118000ff118000ff118999ff111171c1111177771111111111111111111111111111111111111111100000000000000000000000000000000
7777777710770711107707111077071119779711111171c11111c1c1111111111111111111111111111111111111111100000000000000000000000000000000
18777781108877f101887f11108877f11988777f111c171111111111111111111111111111111111111111111111111100000000000000000000000000000000
08888881118888111188881111888811118888111111c11111111111111111111111111111111111111111111111111100000000000000000000000000000000
c68cc86c188866111186681111668811118668111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111110000111100001111000011119999111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107776011077760110777601197776911111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
1111111110f0f01110f0f01110f0f01119f0f0111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111180fff01180fff01180fff01189fff911111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107077111070771110707711197977111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
1111111110f777f11ff777f110f777f119f777f11111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111118888111188881111888811118f881f1111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111186886611168886118668611186686111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16000061333333333333333553333333333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16666661333333333333330555333333333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16111161333333333333005555533333333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16666661333333335555555555553333333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16111161333333355555555555555533333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16666661333333555500000550555555333333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16000061333355555000000550005555533333331111111111111111111111111111111100000000000000000000000000000000
3333333344444444cccccccc16666661333555550000000550000055553333331111111111111111111111111111111100000000000000000000000000000000
3333a3a3fff44444ccc7cccc00000000355555000000000550000005555333330000000000000000000000000000000000000000000000000000000000000000
33333abbf44444f4ccc7cccc00000000555550000000000555000000555553330000000000000000000000000000000000000000000000000000000000000000
3333a3ab4f6f4444c7cccccc00000000555500000000000555000000055555330000000000000000000000000000000000000000000000000000000000000000
333333334f444444cccccc7c00000000055550000000000055000000000555550000000000000000000000000000000000000000000000000000000000000000
33e3e3334f4444f4cccccccc00000000005555555000000055000000000055550000000000000000000000000000000000000000000000000000000000000000
333e3333444ff6f4ccc7cccc00000000000555555555550055000000000000050000000000000000000000000000000000000000000000000000000000000000
33ebe3334f4f464fcccccc7c00000000330000055555555555005555555555550000000000000000000000000000000000000000000000000000000000000000
333bb333444444ff7cccccc700000000330000000000555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000330000000000000005555500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333001115111111100001155511155550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333055555555555500005555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333055555555555500005555555555000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333055555555510000000055555550000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333005555555000000000000055550050000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333001555500555000000000000050050000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333005555005555000005555500000050000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333000000555555500005555555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333000005555555500005555555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333300005555555000005555000003330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333330005555155000005553333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333330000000000000033333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333333300000000000033333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333333333300000000333333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333333333330000000333333333330000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010101010000000000000000000001000101010100000000000000000000000001010101000000000000000000000000010101010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4250504040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5242504040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5242505040404040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5242525240504040404040404040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5042525243525050505050505040404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505243524252525242525252404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040505050505050505252424252404040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040405050505052524040404040404040404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404044454647404040405042424040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404054555657404040404042424242404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404064656667404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404074757677404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707074040074040404040404040070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070040404007070740404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070700070707070740400007070707070000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070000000000000707070707000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000005050070500c05015050260500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001005000200130500020010050002000020013050002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000000000000
__music__
00 00424344

