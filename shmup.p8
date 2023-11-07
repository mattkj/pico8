pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
 cls(0)
 mode="start"
 blinkt=1
 countdownt=90
 
 stars={}
 
 for i=1,100 do
  local star={}
 	star.x=flr(rnd(128))
 	star.y=flr(rnd(128))
 	star.spd=rnd(1.5)+.5
 	add(stars,star)
 end
 
end

function _update()
 blinkt +=1
 countdownt -=1

 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="level" then
  update_level()
 elseif mode=="over" then
  update_over()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="level" then
  draw_level()
 elseif mode=="over" then
  draw_over()
 end
end

function startlevel()
	countdownt=90
	mode="level"
end

function startgame()
	xpos = 60
 ypos = 110
 speed_x = 0
 speed_y = 0
 
 bulletspd = -4
 bullspr = 3
 bullets={}
 
 shipspr = 17
 flamespr = 19
 muzzle = 0
 score = 10000
 lives = 2
 bombs = 2
 bombsize = 0
 
 mode="game"
end

-->8
function starfield()
	for i=1,#stars do
	 local star=stars[i]
	 local starclr=13
	 
	 if star.spd < 1 then
	  starclr=2
	 elseif star.spd > 1.95 then
	  starclr=9
	 elseif star.spd > 1.5 then
	  starclr=6
	 end
	 
	 if star.spd > 1.95 then
	  line(star.x,star.y,star.x,star.y+2,starclr)
	  else
	   pset(star.x,star.y,starclr)	
	  end
	end
end

function animatestars()
 for i=1,#stars do
  local star = stars[i]
 	star.y += star.spd
 	
 	if star.y > 128 then
   star.y -= 128
  end
 end
end

function blink()
	local colors={13,13,13,13,13,13,13,13,13,13,13,13,14,14,15,15}
	if blinkt > #colors then
		blinkt = 1
	end
	return colors[blinkt]
end

function countdown()
	if countdownt>60 then
	 return 3
	elseif countdownt>30 then
	 return 2
	else 
	 return 1
	end
end
-->8
function drawbullets()
	for i=1,#bullets do
	 local bullet=bullets[i]
	 spr(bullspr,bullet.x,bullet.y)
	end
end

function animatebullets()
 for i=#bullets,1,-1 do
  local bullet=bullets[i]
  bullet.y += bulletspd

  --clear bullets
  if bullet.y < -8 then
   deli(bullets,i)
  end
 end
end
-->8
function update_game()
 speed_x = 0
 speed_y = 0
 shipspr = 17
 
 if btn(0) then
 	speed_x = -2
 	shipspr = 16
 end
 
 if btn(1) then
  speed_x = 2
  shipspr = 18
 end
 
 if btn(2) then
  speed_y = -2
 end
 
 if btn(3) then
  speed_y = 2
 end
 
 if btnp(4) then
  local bullet={}
  bullet.x=xpos
  bullet.y=ypos-4
  add(bullets,bullet)

  sfx(0)
  muzzle = 3
 end
 
 if btnp(5) then
  if bombs > 0 then
   bombs -= 1
   sfx(1)
   bombsize = 200
  end
 end
 
 if btnp(4) and btnp(5) then
  mode="over"
 end
 
 xpos = xpos + speed_x
 ypos = ypos + speed_y
-- bull_y = bull_y + buletspd
 
 muzzle = muzzle - 1
 bombsize -= 25
 
 flamespr += 1
 bullspr += 1
 
 if flamespr > 22 then
  flamespr = 19
 end 
 
 if bullspr > 6 then
  bullspr = 3
 end
 
 if xpos > 120 then
 	xpos = -0
 end
 
 if xpos < -0 then
  xpos = 120
 end
 
 if ypos < 0 then
  ypos = 120
 end
 
 if ypos > 120 then
  ypos = 0
 end

	animatestars()
	animatebullets()
	
end

function update_start()
 animatestars()
 
 if btnp(4) or btnp(5) then
 	startlevel()
 end
end

function update_level()
 animatestars()
 
 if countdownt==0 then
 	startgame()
 end
end

function update_over()
 animatestars()

 if btnp(4) or btnp(5) then
 	mode="start"
 end
end
-->8
function draw_game()
 cls(0)
 starfield()
 
 print(#bullets,0,110)
 
 spr(shipspr,xpos,ypos) -- ship
-- spr(bullspr,bull_x,bull_y) -- bullet
 spr(flamespr,xpos,ypos+5) -- flame
 
 if muzzle > 0 then 
  circfill(xpos+3,ypos-2,muzzle,7)
  circfill(xpos+4,ypos-2,muzzle,7)
 end
 
 if bombsize > 0 then
  --circfill(64,64,bombsize,7)
  rectfill(0,0,128,bombsize,rnd(15))
 end
 
 print("score: "..score,40,1,12)
 
 --draw lives
 for i=1,3 do
 	if i <= lives then
   spr(12,i*9-8,1)
  else
   spr(13,i*9-8,1)
  end
 end
 
 --draw bombs
 for i=1,2 do
 	if i <= bombs then
   spr(14,i*7+106,1)
  else
   spr(15,i*7+106,1)
  end
 end
 
 drawbullets()
 
end

function draw_start()
 cls(2)
 starfield()
 
 print("shmup hero",42,40,12)
 print("press any button to start",15,80,blink())
end

function draw_level()
 cls(0)
 starfield()
 
 print("level 1",50,40,7)
 print(countdown(),64,70,7)
end

function draw_over()
 cls(8)
 starfield()
 
 print("game over",42,40,12)
 print("press any button to continue",10,80,blink())
end
__gfx__
0000000000000000000000000000000000000000000000000000000000000000000000007000007000000000000000000880088001100110000dd00000011000
0000000000000000000000000000000000077000000aa000000000000000000000000000700000700000000000000000888888881001100100dddd0000100100
007007000000000000000000000000000079970000a99a0000000000000000000000000070700000000000000000000088888888100000010dddddd001000010
00077000000000000007700000088000009889000098890000088000000000000000000000700700000000000000000088888888100000010dddddd001000010
00077000000000000007700000088000009999000099990000099000000000000000000000700700000000000000000008888880010000100dddddd001000010
00700700000000000000000000000000000990000009900000000000000000000000000000000700000000000000000000888800001001000dddddd001111110
000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000880000001100000d00d0000100100
00000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000d0000d001000010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000000110000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000660000006600000066000000cc000000cc000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c6600006cc6000066c00000077000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600060660600066600000000000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080900090880900090800000000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000330503305009050080502e05029050240501c05015050100500e0500a0500605002050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000016450174500b350194501c4501e4501435020450234501735025450183502745018350284501635029450294502945027450274502745026450244501f4201a410136100c65008650026500165000650
