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
 mode="game"
 
 ship={}
	ship.x = 60
 ship.y = 110
 ship.xspd = 0
 ship.yspd = 0
 ship.spr = 17
 ship.inv = false
 
 bulletspd = -4
 bullets={}
 
 flamespr = 19
 muzzle = 0
 score = 10000
 lives = 3
 bombs = 2
 bombsize = 0
 
 enemies={}
 
 for i=1,5 do
 	local enemy={}
  enemy.x=flr(rnd(128))
  enemy.y=flr(rnd(128)*-1)
  enemy.yspd=rnd(1.5)+.5
  enemy.xspd=rnd(2)-1
  enemy.type=flr(rnd(2)+1)
  if enemy.type == 1 then
   enemy.spr=24
  elseif enemy.type==2 then
   enemy.spr=40
  end
 
  add(enemies,enemy)
 end
 
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

function col(a,b)
 local a_left=a.x
 local a_right=a.x+7
 local a_top=a.y
 local a_bottom=a.y+7
 
 local b_left=b.x
 local b_right=b.x+7
 local b_top=b.y
 local b_bottom=b.y+7
 
 if (a_left)>b_right return false
 if (b_left)>a_right return false
 if (a_top)>b_bottom return false
 if (b_top)>a_bottom return false
 
	return true
end
-->8
function drawspr(myspr)
	 spr(myspr.spr,myspr.x,myspr.y)
end

function animatebullets()
 for i=#bullets,1,-1 do
  local bullet=bullets[i]
  bullet.y += bulletspd
  bullet.spr += 1
  
  if bullet.spr > 6 then
   bullet.spr = 3
  end

  --clear bullets
  if bullet.y < -8 then
   deli(bullets,i)
  end
 end
end
-->8
function update_game()
 ship.spdx = 0
 ship.spdy = 0
 ship.spr = 17
 
 if btn(0) then
 	ship.spdx = -2
 	ship.spr = 16
 end
 
 if btn(1) then
  ship.spdx = 2
  ship.spr = 18
 end
 
 if btn(2) then
  ship.spdy = -2
 end
 
 if btn(3) then
  ship.spdy = 2
 end
 
 if btnp(4) then
  local bullet={}
  bullet.x=ship.x
  bullet.y=ship.y-4
  bullet.spr=3
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
 
 ship.x += ship.spdx
 ship.y += ship.spdy
 
 muzzle = muzzle - 1
 bombsize -= 25
 
 flamespr += 1
 
 if flamespr > 22 then
  flamespr = 19
 end 
 
 if ship.x > 120 then
 	ship.x = -0
 end
 
 if ship.x < -0 then
  ship.x = 120
 end
 
 if ship.y < 0 then
  ship.y = 120
 end
 
 if ship.y > 120 then
  ship.y = 0
 end
 
 --move enemies
 for e in all(enemies) do
  e.y+=e.yspd
	 e.x+=e.xspd
	 e.spr+=.2
	 
	 if e.type==1 and e.spr>=28 then
	   e.spr = 24
  end
  
  if e.type==2 and e.spr>=43 then
	   e.spr = 40
  end
	 
	 if e.y > 128 then
	  e.y = 0
	  e.x = rnd(128)
	 end
	end
	
	-- collision ship x enemies
	for e in all(enemies) do
		if ship.inv!=true and col(e, ship) then
		 lives -= 1
			sfx(2)
			ship.inv=true
		end
	end
	
	if lives<=0 then
	 mode="over"
	 return
	end
	
	if ship.inv==true then
		--do something then
		--ship.inv=false
	end

	animatestars()
	animatebullets()
	
	-- collision bullets x enemies
	for b in all(bullets) do
		for e in all(enemies) do
		 if col(b,e) then
		 	sfx(3)
		 	del(enemies,e)
		 	del(bullets,b)
   end
		end
	end
	
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
 
 spr(ship.spr,ship.x,ship.y) -- ship
 spr(flamespr,ship.x,ship.y+5) -- flame
 
 if muzzle > 0 then 
  circfill(ship.x+3,ship.y-2,muzzle,7)
  circfill(ship.x+4,ship.y-2,muzzle,7)
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
 
 --draw enemies
 foreach(enemies,drawspr)
 
 --draw bullets
 foreach(bullets,drawspr)
 
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
00000000000000000000000000000000000000000000000000000000000000000030030000300300003003000030030000000000000000000000000000000000
00010000000110000000100000000000000000000000000000000000000000000373373003733730037337300373373000000000000000000000000000000000
000660000006600000066000000cc000000cc000000cc00000000000000000003772277337722773377227733772277300000000000000000000000000000000
000c6600006cc6000066c00000077000000770000007700000000000000000003777777337777773377777733777777300000000000000000000000000000000
00066600060660600066600000000000000770000007700000000000000000000373373303733733037337330373373300000000000000000000000000000000
00080900090880900090800000000000000770000000000000000000000000000030030000300300003003000030030000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000030030000300300003003000030030000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000030030003000030003003000003300000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000020000002000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000e000000e20000002e000000e0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ee0000eeee0000eeee0000ee0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000efe00efeefe00efeefe00efe0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000effeeffeeffeeffeeffeeffe0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000e2ff2e00e8ff8e00e2ff2e00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000effe0000effe0000effe000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000ee000000ee000000ee0000000000000000000000000000000000000000000
__sfx__
00010000330503305009050080502e05029050240501c05015050100500e0500a0500605002050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000016450174500b350194501c4501e4501435020450234501735025450183502745018350284501635029450294502945027450274502745026450244501f4201a410136100c65008650026500165000650
000400003b6503a6503965034650326502e6502a650246501e650186400a6400c64007630036200062002620006100b6000460001600006000000000000000000000000000000000000000000000000000000000
0001000001650076500c65013650176501c650216502365027650296502c6502f65031650336503565037650386503b6503d6503e6503f64000530005203d600396003a6003f6000000000000000000000000000
