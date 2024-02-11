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
	new_actor(pl)
	--projectiles array
	projectiles={}
	--enemies array
	en={}
	--globals
	t=1 --counts frames
	tmst=time() --time when level starts
	tmcur=0
	pl_speed=1 --speed upgrade
		--dark blue transparent
	palt(0,false)
	palt(1,true)
end

function update_game()
	--update order?
	--player
	pl_update()
	--projectiles
	if #projectiles != 0 then
		proj_update()
	end
	--collisions
	chk_col()
	--enemies
	en_update()
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

function _init()
	cls(0)
	--game state
	gstate=0
end

function _update60()
	if gstate==1 then
		update_game()
	elseif gstate==2 then
		--pass; gameover state will go here
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
	--draw projectiles
	for i=1,#projectiles do
		spr(projectiles[i].spr,projectiles[i].x,projectiles[i].y)
	end
	--draw enemies
	for i=1,#en do
		spr(en[i].spr,en[i].x,en[i].y,1,1,en[i].flip)
	end
	--draw player
	spr(pl.spr,pl.x,pl.y,1,1,pl.flip)
	--debug
	_debug()
end

function draw_title()
	cls(0)
	print("∧░⬅️🐱🅾️😐░")
end

function draw_gameover()
	cls(0)
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
function new_actor(act)
	act.x=64
	act.y=64
	act.xsp=0
	act.ysp=0
	act.spr=1
	act.dir=4 --dir is 0-7 clockwise from 12o'clock
	act.dirbuf=0
	act.atktime=0
	act.flip=false --sprflip
	act.ani=1 --animation timer for actor
end

function new_proj()
	local pro={}
	pro.x=pl.x
	pro.y=pl.y
	pro.flip=false --sprflip
	pro.bspd=2.5
	local sp=1*pro.bspd
	local diag=0.714*pro.bspd
	if pl.dir==0 then
		pro.xsp=0
		pro.ysp=-sp
		pro.spr=23
	elseif pl.dir==1 then
		pro.xsp=diag
		pro.ysp=-diag
		pro.spr=21
	elseif pl.dir==2 then
		pro.xsp=sp
		pro.ysp=0
		pro.spr=20
	elseif pl.dir==3 then
		pro.xsp=diag
		pro.ysp=diag
		pro.spr=22
	elseif pl.dir==4 then
		pro.xsp=0
		pro.ysp=sp
		pro.spr=23
	elseif pl.dir==5 then
		pro.xsp=-diag
		pro.ysp=diag
		pro.spr=21
		pro.flip=true
	elseif pl.dir==6 then
		pro.xsp=-sp
		pro.ysp=0
		pro.spr=20
	elseif pl.dir==7 then
		pro.xsp=-diag
		pro.ysp=-diag
		pro.spr=22
		pro.flip=true
	end
	add(projectiles,pro)
end

--update and resolve projectiles
function proj_update()
	for i=#projectiles,1,-1 do
	--looping reverse
		local pro = projectiles[i]
		pro.x+=pro.xsp
		pro.x=flr(pro.x)+0.5--correction for diag
		pro.y+=pro.ysp
		pro.y=flr(pro.y)+0.5
		--delete projectiles offscreen
		if pro.x > 128 or pro.x < 0 then
			deli(projectiles,i)
		end
		if pro.y > 128 or pro.y < 0 then
			deli(projectiles,i)
		end
	end
end
-->8
--player behavior
function pl_update()
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
	
	animate_pl(btm)
	
	--apply spped, correct diag
	pl.y+=pl.ysp
	pl.y=flr(pl.y)+0.5
	pl.x+=pl.xsp
	pl.x=flr(pl.x)+0.5
	
	--check for attack input
	if bta==0b100000 then
		if pl.atktime%13==0 then --limit proj amount
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
	
end

function animate_pl(bt)
	--first, check for direction change
	if pl.dir!=pl.dirbuf then
		pl.ani=1 --reset timer when dir change
	end
	--action?
	if bt|0b000000==0 then
		pl.ani=1 --reset animation timer
	else
		pl.ani+=1
	end
	--set sprite base if dir changes
	if pl.dir!=pl.dirbuf then
		pl.flip=false --saving tokems
		if pl.dir==0 then
			pl.spr=17
		elseif pl.dir==1 then
			pl.spr=4
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
			pl.spr=4
			pl.flip=true
		end
	end
	
	if pl.ani%60==0 then
		pl.spr-=2
	elseif pl.ani%40==0 then
		pl.spr+=1
	elseif pl.ani%20==0 then
		pl.spr+=1
	end
	
	--animation check
	if pl.ani>=60 then
		pl.ani=1
	end
	
	--end with updating the direction buffer
	pl.dirbuf=pl.dir
end


-->8
--game logic
function update_game_logic()
		--add new enemies
	if tmcur%5==0 then
		local _en={}
		new_actor(_en)
		_en.spr=25
		add(en,_en)
	end
end
-->8
--enemy behavior&collide
function en_update()
	for i=1,#en do
		en[i].x+=1
	end
end

--enemy collide
function chk_col()
	
end
-->8
--debug
function _debug()
	print(pl.ani)
	print(tmcur)
end
__gfx__
00000000110000111100001111000011110001111100011111000111333333333333a3a300000000000000000000000000000000000000000000000000000000
000000001077760110777601107776011077001110770011107700113b333b333b33babb00000000000000000000000000000000000000000000000000000000
007007001f0ff0f11f0ff0f11f0ff0f11000760110007601100076013333333333b3a3ab00000000000000000000000000000000000000000000000000000000
0007700010ffff0110ffff0110ffff01118000111180001111800011333333333333333b00000000000000000000000000000000000000000000000000000000
00077000770770777707707777077077100777f110077711100777f13333333333e3e33300000000000000000000000000000000000000000000000000000000
00700700f877768ff867778ff877768f1077771100777f1110777711333b3333333e333300000000000000000000000000000000000000000000000000000000
0000000008888881f88888800888888f10888811118888111088881133b33333b3ebe33b00000000000000000000000000000000000000000000000000000000
0000000016818861168818611681886111886611188668111188661133333b33333bb33300000000000000000000000000000000000000000000000000000000
11111111110000111100001111000011111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107706011077060110770601111111111111111111111111111111111111111111777711111111111111111100000000000000000000000000000000
17777111108008011080080110800801177771111111771111771111111771111111111111707071117777111111111100000000000000000000000000000000
17686711170000711700007117000071176867111118671111768111117671111111111111677771117070711111111100000000000000000000000000000000
11777711777607777776077777706777117777111176811111186711117871111111111111670711117777711111111100000000000000000000000000000000
11111111f877608ff870768ff806678f111111111177111111117711117671111111111177777111116707111111111100000000000000000000000000000000
11111111188888811888888ff8888881111111111111111111111111117711111111111116671111776771111111111100000000000000000000000000000000
11111111168818611681886116881861111111111111111111111111111111111111111111111111167711111111111100000000000000000000000000000000
11111111110000111100001111000011111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107777011077770110777701111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
111111111000f0f11000f0f11000f0f111171111111111111111c1c1111111111111111111111111111111111111111100000000000000000000000000000000
1111111118000ff118000ff118000ff111c7c11111171c1111177771111111111111111111111111111111111111111100000000000000000000000000000000
1111111110770711107707111077071111171111111171c11111c1c1111111111111111111111111111111111111111100000000000000000000000000000000
11111111108877f101887f11108877f111c7c111111c171111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111118888111188881111888811111111111111c11111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111188866111186681118668811111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111110000111100001111000011111c7c11111c111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107776011077760110777601111171111171c11111111111111111111111111111111111111111111111111100000000000000000000000000000000
1111111110f0f01110f0f01110f0f011111c7c111c17111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111180fff01180fff01180fff011111711111c1711111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111107077111070771110707711111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
1111111110f777f11ff777f110f777f1111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111118888111188881111888811111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
11111111186886611168886118688661111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
__map__
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070807070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070808070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070708070807070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070808070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0708070707070707070707070708070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070708070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707080707070707070707070807070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070007070707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070700070707070707000007070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070000000000000707070707000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000024050250502505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002023026230232300020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
