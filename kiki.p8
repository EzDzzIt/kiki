pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
	cls(0)
	--init player
	pl={}
	_new_actor(pl)
	--globals
	t=1
end

function _update60()
	local bt=btn()--grab which buttons are curently pressed
	_get_input(bt)
	_animate_player(bt)
	--counter
	t+=1
	if t>60 then
		t=1
	end
end

-->8
--drawing
function _draw()
	cls(0)
	spr(pl.spr,pl.x,pl.y,1,1,pl.flip)
	_debug()
end
-->8
--tools
function _new_actor(act)
	act.x=64
	act.y=64
	act.spr=1
	act.dir=4 --dir is 0-7 clockwise from 12o'clock
	act.flip=false
end

function _get_input(bt)
	if bt==4 then
		pl.y-=1
		pl.dir=0
	elseif bt==8 then
		pl.y+=1
		pl.dir=4
	elseif bt==2 then
		pl.x+=1
		pl.dir=2
	elseif bt==1 then
		pl.x-=1
		pl.dir=6
	end
end

function _animate_player(bt)

	if pl.dir==0 then
		pl.spr=17
		if bt==8 then
			pl.spr+=1
		end
	elseif pl.dir==4 then
		pl.spr=1
		pl.flip=false
	elseif pl.dir==2 then
		pl.spr=33
		pl.flip=false
	elseif pl.dir==6 then
		pl.spr=33
		pl.flip=true
	end
end
-->8
--debug
function _debug()
	print(btn())
end
__gfx__
00000000005555000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056676500566765005667650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007005f0ff0f55f0ff0f55f0ff0f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700005ffff5005ffff5005ffff50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000757677577576775775767757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700f877678ff877678ff877678f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008888880f88888800888888f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000068088600688086006808860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056656500566565005665650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000558558555585585555855855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077557700775577007755770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777657777776577777765777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f877658ff877658ff877658f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800888888ff8888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000068808600680886006880860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056666600566666005666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555f50f5555f50f5555f50f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008555ff008555ff008555ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000557777005577770055777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008877f000887700008877f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000088880000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088866000086680008886600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056666600566666005666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055f0f0555550f0555550f055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000085fff50085fff50085fff50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000577ff000577ff000577ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f777f000f777f000f777f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f8880000f8880000f88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000086886600868866008688660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
