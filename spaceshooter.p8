pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	invuln = 0
	old_score = 0
	score = 0
	player = {x=64, y=100, animation=1}
	state = "game"
	init_health()
	init_fire()
	init_starfield()
	init_enemies()
	init_shoot()
	
	frame_counter = 0
end

function _update()
	frame_counter += 1
	
	if state == "game" then
		update_health()
		moveplayer() -- movement
		update_fire() -- fire animation
		
		-- shoot
		if btnp(🅾️) then 
			shoot() 
		end
	
		update_enemies()
		
		increment_speed()	
	end
	
end

function _draw()
	if state=="game" then
		cls(1)
		
		star_draw()
		draw_health()
		bullet_draw()
		draw_enemies()
		draw_score(score)		
	
	
		-- draw player
		-- if invuln blink
		if invuln <= 0 then
			spr(player.animation, player.x, player.y)
		elseif sin(frame_counter/10) < 0 then
			spr(player.animation, player.x, player.y)
		end
		
		draw_fire() -- draw fire animation
		
		elseif state=="lose" then
			draw_lose()
	
	end
end


-->8
-- utils

function moveplayer() 
	if btn(➡️) then 
		player.x+=1 
		player.animation=3 -- turning right
		if player.x+8 > 128 then
			player.x = 120
		end
	elseif btn(⬅️) then
	 player.x-=1
	 player.animation=2 -- turning left 
		if player.x < 0 then
			player.x = 0
		end
	else
		player.animation=1
	end
		
	if btn(⬆️) then
	 player.y-=1 
		if player.y < 0 then
			player.y = 0
		end
	end
	
	if btn(⬇️) then 
		player.y+=1 
		if player.y+8 > 128 then
			player.y = 120
		end
	end
	
end

-- shooting
function init_shoot()
	bullet_list={}
	bullet_speed=3
	light_size=4 -- default value
	light_radius=0
end

function shoot()
	add(bullet_list, {x=player.x, y=player.y})
	sfx(0)
	end

function bullet_draw()
	-- if bullet ready: shoot
	for el in all(bullet_list) do
		spr(4, el.x, el.y)
		el.y -= bullet_speed
		
		-- remove if offbounds
		if el.y < -8 then 
			del(bullet_list, el)
		end
	end
end

-- stars
function init_starfield()
	star_speed = 1
	starfield_top = {}
	starfield_bottom = {}
	for i=0, 35 do
		add(starfield_top, {x=rnd(128), y=rnd(128)})
		for j=0, 5 do
			add(starfield_bottom, {x=rnd(128), y=rnd(128)})
		end
	end
end

function star_draw() 
	for star in all(starfield_top) do
		pset(star.x, star.y, 7)
		
		star.y += star_speed -- change speed
		star.y %= 128 -- move stars up
	end
	
	for star in all(starfield_bottom) do
		pset(star.x, star.y, 13)
		star.y += star_speed * 0.5
		star.y %= 128
	end
end

-- fire

function init_fire()
	fire_sprite = 15
	wait_frames = 10
	counter = 0
	waiting = true
end

function update_fire()
	if waiting then
		counter += 1
		if counter >= wait_frames then
			counter = 0
			fire_sprite += 1
			if fire_sprite > 18 then
				fire_sprite = 16
			end
		end
	end
	end

function draw_fire()
	-- start waiting
	if invuln <= 0 then
			spr(fire_sprite, player.x, player.y+8)
	elseif sin(frame_counter/10) < 0 then
			spr(fire_sprite, player.x, player.y+8)
	end
	
end

function count_digits(n)
 if n == 0 then
  return 1
 end

 n = abs(flr(n))
 
 local count_ = 0
 
 while n > 0 do
  n = flr(n / 10)
  count_ += 1
 end
 return count_
end

function collision(a, b)
	local a_top = a.y
	local a_left = a.x
	local a_bottom = a_top+7
	local a_right = a_left+7
	
	
	local b_top = b.y
	local b_left = b.x
	local b_bottom = a_top+7
	local b_right = b_left+7
	
	if a_top > b_bottom then return false end
	if b_top > a_bottom then return false end
	if a_left > b_right then return false end
	if b_left > a_right then return false end

	return true
end

function increment_speed()
 if score > old_score then
 	interval -= 0.005*score
 	old_score = score
 end	
 if interval <= 0.5 then
 	interval = 0.5
 end
end
-->8
-- enemies

function random_asteroid()
	rnd_x = 8+rnd(104)
	return {x=rnd_x, y=-8, xr=rnd(1) < 0.5, yr=rnd(1) < 0.5}
end

function init_enemies()
 last_time = 0
 last_time_inv = 0
	interval = 3 -- every three seconds
	
	enemy_count = 1
	enemies = {}
	
	for enemy=1, enemy_count do
		add(enemies,random_asteroid())
	end
end

function update_enemies()
	function update_enemies()
	-- enemy movement and removal
	for enemy in all(enemies) do
		enemy.y += 1

		if enemy.y > 128 then
			del(enemies, enemy)
			interval += 0.01 * score
		end
	end

	-- check for player-enemy collisions
	if invuln <= 0 then
		for enemy in all(enemies) do
			if collision(enemy, player) then
				reduce_health()
				invuln = 60
				break -- only take one hit
			end
		end
	end

	for enemy in all(enemies) do
		for bullet in all(bullet_list) do
			if collision(enemy, bullet) then
				del(enemies, enemy)
				del(bullet_list, bullet)
				score += 1	
				sfx(2)
				break
			end
		end
	end

	-- spawn enemies
	if time() - last_time >= interval then
		last_time = time()
		add(enemies, random_asteroid())
	end

	if invuln > 0 then
		invuln -= 1
	end
end


end

function draw_enemies()
	for enemy in all(enemies) do
		spr(34, enemy.x, enemy.y, 1, 1, enemy.xr, enemy.yr)
	end
end
-->8
-- ui
function init_health() 
	starting_health=3
	health = {}
	
	for heart=starting_health, 1, -1 do
		add(health, {x=8*heart, y=8})
	end
end

function update_health()
	if #health == 0 then
		state = "lose"
	end
end

function draw_health()
	for heart in all(health) do
		spr(32, heart.x, heart.y)
	end
end

function reduce_health()
	for h in all(health) do
		del(health, h)
		break	
	end
	
	sfx(1)
end

function draw_lose()
	cls(8)
		
	local text = "gamover!"
	print("gameover!", flr((128-#text*3)/2)-6,51, 7)
		
	text = "highscore: "
	print(text..score, flr((128-(#text+count_digits(score))*3)/2)-6, 59, 7)
	
	if btn(❎) then
		_init()
	end
end

function draw_score(score_) 
	local text = "score: "
	print(text .. score_, 100-#text*3-count_digits(score)*3, 8, 7)
end
-->8
-- particles
__gfx__
00000000000220000002200000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002882000028820000288200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700002882000028820000288200000840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700002e88e2002e88e2002e88e200087a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770002e8888e202e8882002888e20009849000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007002887c882027c882002887c20000980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000028558200255882002885520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002992000029920000299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007a9000097a900000a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099aa000097aa00009aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa900000a9000009a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009a000000000000009a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000d2d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700770077007700df5252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
72877ee770077007d624565400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
728ee8e770000007254545f200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
728888e770000007d554555400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07288e70070000702555655400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00722700007007000df5252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000077000002f440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002a1202612023120201201e1201c1201a1201713015130141301213011130101300f1300d1200c1200c1000910009100001000010001100021000410005100071000b1000e10011100171001d10025100
000300002e6502b65027650226501f6501c6501a6501865017650176501765017650186501865013640116300d6200d610296002d600306002d60000000000000000000000000000000000000000000000000000
000200001f6501f6501e6501e6501a65017650166501465013640126401264012640146401763008630076300763006630066300663006630076300e6000b6000960007600056000360002600006002b60031600
