pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- todo & init
-----------------
--enemy bullets

function _init()
 cls(0)
 mode="start"
 blinkt=1
 t=0
 buttonlock=0
 
 music(0)
 
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
 t+=1
 blinkt +=1

 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="wave" then
  update_wave()
 elseif mode=="over" then
  update_over()
 elseif mode=="win" then
  update_win()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="wave" then
  draw_wave()
 elseif mode=="over" then
  draw_over()
 elseif mode=="win" then
  draw_win()
 end
end

function startgame()
 t=0
 wave=0
 nextwave()
 
 music(-1,2000)
 
 ship=makespr()
	ship.x = 60
 ship.y = 110
 ship.xspd = 0
 ship.yspd = 0
 ship.spr = 17
 ship.inv = 0
 
 bulletspd = -4
 bullets={}
 bullettimer=0
 bullexps={} --explosions
 
 flamespr = 19
 muzzle = 0
 score = 0
 lives = 1
 bombs = 2
 bombsize = 0
 
 enemies={}
 explosions={}
 particles={}
 swaves={}
end

-->8
--helpers

function drawspr(myspr)	 
	 spr(myspr.spr,myspr.x,myspr.y,myspr.width,myspr.height)
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
 local a_right=a.x+(a.colw-1)
 local a_top=a.y
 local a_bottom=a.y+(a.colh-1)
 
 local b_left=b.x
 local b_right=b.x+(b.colw-1)
 local b_top=b.y
 local b_bottom=b.y+(b.colh-1)
 
 if (a_left)>b_right return false
 if (b_left)>a_right return false
 if (a_top)>b_bottom return false
 if (b_top)>a_bottom return false
 
	return true
end

function ship_explode(x,y)
	local e={}
	e.x=x
	e.y=y
	e.age=1
	add(explosions,e)
	
	swave(x,y+4,30,7,3.5)
	
	--sparks
 for i=1,20 do
	 local p={}
	 p.x=x
	 p.y=y
	 p.xspd=(rnd()-0.5)*8
	 p.yspd=(rnd()-0.5)*8
	 p.age=rnd(2)
	 p.maxage=10+rnd(10)
	 p.clr=7
	 p.sz=1+rnd(4)
	 p.spark=true
	 add(particles,p)
 end
	
end

function enemy_explode(x,y)
	local p={}
 p.x=x
 p.y=y
 p.xspd=0
 p.yspd=0
 p.age=0
 p.maxage=0
 p.clr=7
 p.sz=8
 add(particles,p)
	 
 for i=1,20 do
	 local p={}
	 p.x=x
	 p.y=y
	 p.xspd=(rnd()-0.5)*4
	 p.yspd=(rnd()-0.5)*4
	 p.age=rnd(2)
	 p.maxage=10+rnd(10)
	 p.clr=7
	 p.sz=1+rnd(4)
	 add(particles,p)
 end
 
 --sparks
 for i=1,20 do
	 local p={}
	 p.x=x
	 p.y=y
	 p.xspd=(rnd()-0.5)*8
	 p.yspd=(rnd()-0.5)*8
	 p.age=rnd(2)
	 p.maxage=10+rnd(10)
	 p.clr=7
	 p.sz=1+rnd(4)
	 p.spark=true
	 add(particles,p)
 end
 
 swave(x,y+4,30,7,3.5)
end

function bullexp(x,y)
	local e={}
	e.x=x
	e.y=y
	e.size=3
	add(bullexps,e)
end

function swave(x,y,tr,clr,spd)
	local sw={}
	sw.x=x
	sw.y=y
	sw.r=3
	sw.tr=tr --6
	sw.clr=clr --9
	sw.spd=spd --1
	add(swaves,sw)
end

function hit_sparks(x,y)
 local p={}
 p.x=x
 p.y=y
 p.xspd=(rnd()-0.5)*4
 p.yspd=(rnd()-1)*4
 p.age=rnd(2)
 p.maxage=10+rnd(10)
 p.clr=7
 p.sz=1+rnd(4)
 p.spark=true
 add(particles,p)
end

function makespr()
	local myspr={}
  myspr.x=0
  myspr.y=0
  myspr.yspd=1
  myspr.xspd=1
  myspr.hp=5
  myspr.flash=0
  myspr.type=1
  myspr.aniframe=1
  myspr.width=1
  myspr.height=1
  myspr.spr=0
  myspr.colw=8
  myspr.colh=8
  
  return myspr
end
-->8
-- waves and enemies

function spawnwave()
 if wave==1 then
 	placen({
 		{1,1,1,1,1,1,1,1,1,1},
 		{3,3,3,3,3,3,3,3,3,3},
 		{2,2,2,2,2,2,2,2,2,2},
 		{4,4,4,4,4,4,4,4,4,4}
 	})
 elseif wave==2 then
  placen({
 		{1,1,1,1,1,1,1,1,1,1},
 		{3,3,3,3,3,3,3,3,3,3},
 		{2,2,2,2,2,2,2,2,2,2},
 		{4,4,4,4,4,4,4,4,4,4}
 	})
 elseif wave==3 then
  placen({
 		{1,1,1,1,1,1,1,1,1,1},
 		{3,3,3,3,3,3,3,3,3,3},
 		{2,2,2,2,2,2,2,2,2,2},
 		{4,4,4,4,4,4,4,4,4,4}
 	})
 elseif wave==4 then
  placen({
 		{0,0,0,0,0,0,0,0,0,0},
 		{0,0,0,0,5,0,0,0,0,0},
 		{0,0,0,0,0,0,0,0,0,0},
 		{0,0,0,0,0,0,0,0,0,0}
 	})
 	music(1)
 end
end

function nextwave()
	wave+=1
	if wave>4 then
		mode="win"
		buttonlock=t+30
		music(2)
	else
		mode="wave"
		if wave>1 then
			music(3)
		end
		countdownt=90
	end
end

function placen(lvl)
	for j=1,#lvl do
	 local myline=lvl[j]
	  for i=1,#myline do
	   if myline[i] !=0 then
		  	spawnen(myline[i],i*12-6,6+j*12)
	  	end
	  end
	end
end

function spawnen(entype,x,y)
 
	local enemy=makespr()
 enemy.x=x
 enemy.y=y
 enemy.yspd=rnd(1.5)+.5
 enemy.xspd=rnd(2)-1
 enemy.type=entype
 enemy.hp=1
 
 if (wave==4) enemy.type=5
 
 if enemy.type==1 or enemy.type==2 then
  enemy.ani={24,25,26,27}
 elseif enemy.type==3 or enemy.type==4 then
  enemy.ani={40,41,42}
 elseif enemy.type==5 then
  --boss enemy
  enemy.width=2
  enemy.height=2
  enemy.ani={32,34}
  enemy.colw=16
  enemy.colh=16
 end
 
 enemy.spr=enemy.ani[enemy.aniframe]

 add(enemies,enemy)
	
end
-->8
-- update

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
 
 if btn(4) then
  if bullettimer<=0 then
	  local bullet=makespr()
	  bullet.x=ship.x
	  bullet.y=ship.y-4
	  bullet.spr=3
	  add(bullets,bullet)
	
	  sfx(0)
	  muzzle = 3
	  bullettimer=4
  end
 end
 
 bullettimer -= 1
 
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
--  e.y+=e.yspd
--	 e.x+=e.xspd
	 e.aniframe+=.2
	 
	 if flr(e.aniframe)>#e.ani then
	  e.aniframe=1
  end
  
  e.spr=e.ani[flr(e.aniframe)]
	 
	 if e.y > 128 then
	  e.y = 0
	  e.x = rnd(128)
	 end
	end
	
	-- collision bullets x enemies
	for e in all(enemies) do
		for b in all(bullets) do
		 if col(e,b) then
		 		del(bullets,b)
		 		swave(b.x+4,b.y+4,6,9,1)
		 		bullexp(b.x,b.y)
		 		hit_sparks(e.x+4,e.y+4)
		   e.hp-=1
		   sfx(4)
		   e.flash=2
		  
		  if e.hp<=0 then
			 	sfx(3)
			 	del(enemies,e)
			 	score+=1
			 	enemy_explode(e.x+4,e.y+4)
		 	 
		 	 if #enemies==0 then
		 	  nextwave()
		 	 end 
		 	end
   end
		end
	end
	
	-- collision ship x enemies
	if ship.inv<=0 then
		for e in all(enemies) do
			if col(e, ship) then
				sfx(2)
				ship_explode(ship.x,ship.y)
				lives -= 1
				ship.inv=60
			end
		end
		else
		 ship.inv-=1
	end
	
	if lives<=0 and #explosions==0 then
	 mode="over"
	 buttonlock=t+30
	 music(1)
	 return
	end

	animatestars()
	animatebullets()
	
end

function update_start()
 animatestars()
 
 if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(4) or btnp(5) then
 		startgame()
 		btnreleased=false
 	end
	end
end

function update_wave()
 update_game()
 countdownt-=1
 if countdownt<=0 then
 	mode="game"
 	spawnwave()
 end
end

function update_over()
 animatestars()
 
 if t<buttonlock then
 	return
 end

 if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(4) or btnp(5) then
 		mode="start"
 		music(0)
 		btnreleased=false
 	end
	end
end

function update_win()
 animatestars()
 
 if t<buttonlock then
 	return
 end

	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	
	if btnreleased then
		if btnp(4) or btnp(5) then
 		mode="start"
 		music(0)
 		btnreleased=false
 	end
	end
 
end
-->8
-- draw

function draw_game()
 cls(0)
 starfield()
 
 -- draw ship
 if lives>0 then
	 if ship.inv<=0 then
	 	drawspr(ship)
	 	spr(flamespr,ship.x,ship.y+5) -- flame
	 else
	  if sin(t/3)<0 then
		 	drawspr(ship)
		 	spr(flamespr,ship.x,ship.y+5)
	 	end
	 end
 end
 
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
 
 --draw swaves
	for sw in all(swaves) do
		circ(sw.x,sw.y,sw.r,sw.clr)
		sw.r+=sw.spd
		if sw.r>sw.tr then
			del(swaves,sw)
		end
	end
 
 --draw explosions
 local espr={64,64,66,68,70,70,72,72}
 for e in all(explosions) do
  spr(espr[e.age],e.x-4,e.y-4,2,2)
  e.age+=1
  if e.age>#espr then
   del(explosions,e)
  end
 end

	--draw particles
	for p in all(particles) do
	
		if p.spark then
		 pset(p.x,p.y,7)
		else
		 circfill(p.x,p.y,p.sz,p.clr)
  end
  
		p.x+=p.xspd
		p.y+=p.yspd+1
		
		p.xspd=p.xspd*0.9
		p.yspd=p.yspd*0.9
		
		p.age+=1
		
		if (p.age>5) p.clr=10
		if (p.age>7) p.clr=9
		if (p.age>10) p.clr=8
		if (p.age>12) p.clr=2
		if (p.age>15) p.clr=5
		
		if p.age>p.maxage then
		 p.sz-=1
		 if p.sz<0 then
				del(particles,p)
			end
		end
	end
 
 --draw enemies
 for e in all(enemies) do
  if e.type==2 then
  	pal(3,12)
  end
  if e.type==4 then
  	pal(14,2)
  	pal(15,13)
  end
  if e.flash>0 then
   e.flash-=1
   for i=1,15 do
    pal(i,7)
   end
  end
 	drawspr(e,e.width,e.height)
 	pal()
 end
 
 --draw bullets
 foreach(bullets,drawspr)
 
 --draw bull explosions
 for b in all(bullexps) do
 	if b.size>0 then
 		circfill(b.x+3,b.y,b.size,7)
 		b.size-=1
		end
 end
 
end

function draw_start()
 cls(2)
 starfield()
 
 print("shmup hero",42,40,12)
 print("press any button to start",15,80,blink())
end

function draw_wave()
 draw_game()
 
 print("wave "..wave,50,40,7)
 print(countdown(),64,70,7)
end

function draw_over()
 draw_game()
 print("game over",42,40,8)
 print("press any button to continue",10,80,blink())
end

function draw_win()
 draw_game()
 print("congratulations",30,40,12)
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
000000eeeeee0000000000000000000000000000000000000000000000000000e000000e20000002e000000e0000000000000000000000000000000000000000
00000eeffffeee000000000eeee0000000000000000000000000000000000000ee0000eeee0000eeee0000ee0000000000000000000000000000000000000000
0000eefffff77ee00000eeeeffeeee0000000000000000000000000000000000efe00efeefe00efeefe00efe0000000000000000000000000000000000000000
000eefffdfff7fe0000e6fffff77fee000000000000000000000000000000000effeeffeeffeeffeeffeeffe0000000000000000000000000000000000000000
00eef66ffdffffe000ee66fffdf7fee0000000000000000000000000000000000e2ff2e00e8ff8e00e2ff2e00000000000000000000000000000000000000000
00effdf66fffdde000effdf6ffdfdde00000000000000000000000000000000000effe0000effe0000effe000000000000000000000000000000000000000000
099fffff66ffffee099fffdf66fddfee00000000000000000000000000000000000ee000000ee000000ee0000000000000000000000000000000000000000000
09444444444444490944444444444449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09449444944494490944944494449449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99444944944444499944494494444449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99944494449494499994449444949449000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99444444444444999944444444444499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999999999999900999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000800000000005555555555500000055555555500000000055055500500000000000000000000000000000000000000000000000000
0000000000000000000008988880080000558d9ddd8dd5500055dd9dddd5500000500000dd555000000000000000000000000000000000000000000000000000
00070707aa07a00000088889998980000558e98888898d55050da9558898d50000d00000000d5000000000000000000000000000000000000000000000000000
00000aaa7aaa00700008989aa999890005d988899988edd500d9d55aa8d6dd5005555d5d0000d000000000000000000000000000000000000000000000000000
0000aaa7777aaa000088999a7a999800058e889979988ede0dd98595dd989555050500000005d555000000000000000000000000000000000000000000000000
000aaa7777777a00000899a777aa998005d8899aaaa98ddd05d585a750add9d0005d000000d50005000000000000000000000000000000000000000000000000
0707a7777777a70000089977777a998055d889a7777a989d00dd8d7dd77ad89d0500005000000055000000000000000000000000000000000000000000000000
000aa7777777aa7008089a77777a989059d899a7777a9edd05dd9d7d7ddad89d0000000000505d50000000000000000000000000000000000000000000000000
000aa7777777aa0000099977777a9808098899a7777988dd0d0d9a57d7da89a505d0500000005505000000000000000000000000000000000000000000000000
0007a7777777a7000808897777a8880055de89aaaaa88dd505d85d7577d859d500d005000005055d000000000000000000000000000000000000000000000000
00a77a7777aaaa000008899aaa889800055d8999aa889ed5005d855dda589d000500000050050000000000000000000000000000000000000000000000000000
0000aaaaaaa707000009088998908080005dd888988edd850055d888888dd5500000000005050000000000000000000000000000000000000000000000000000
00070a7aa7a00000000080888900000000558dde88ddd8500d00dd999ddd5050050500d00dd55500000000000000000000000000000000000000000000000000
000007007007000000000000000800000005558ddddde55000005505555500000000555d05550d00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000005555555550000000000000000000050000550050000000000000000000000000000000000000000000000000000
__sfx__
00010000330503305009050080502e05029050240501c05015050100500e0500a0500605002050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000016450174500b350194501c4501e4501435020450234501735025450183502745018350284501635029450294502945027450274502745026450244501f4201a410136100c65008650026500165000650
000400003b6503a6503965034650326502e6502a650246501e650186400a6400c64007630036200062002620006100b6000460001600006000000000000000000000000000000000000000000000000000000000
0001000001650076500c65013650176501c650216502365027650296502c6502f65031650336503565037650386503b6503d6503e6503f64000530005203d600396003a6003f6000000000000000000000000000
00030000233501c350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001300001b5501d55024550275501b5501b5501d5501b5501855029550275503055030550305502e5502e5501d5502955027550245501b5501f550275502b5502e550165502e5502e5501f5502b550295501b550
411000001810203072181020305218102030721810203052181020307218102030521810203072181020305218102030721810203052181020307218102030521810203072181020305218102030721810203052
001800001d7521b752307523075218752277521b7520f702117521b75224752297022e752337523a7523a7523c7023c7523c752377522775224752227521b70218752137520f7520c7020c752007020070200702
010b0000205002050020500205002055020550205502055022550245501c550165502755027550275302752027510275100050000500005000050000500005000050000500005000050000500005000050000500
__music__
03 05464344
03 41064344
04 07424344
04 08424344

