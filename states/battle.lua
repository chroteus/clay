battle = {}

print("12th JULY! Congratulate a German Bernd.")

local padding = 40
local fixedHeight = 250
local barWidth, barHeight = 200, 30

function battle.start(player, enemy) -- Sets opponents, and switches to battle gamestate.
	battle.player = nameToCountry(player)
	battle.enemy = nameToCountry(enemy)
	
	battle.player.hp = battle.player.maxHP
	battle.enemy.hp = battle.enemy.maxHP
	
    venus.switch(battle)
end

startBattle = battle.start


function battle.load()
	battle.btn = {}

	local player = battle.player
	player.x = padding
	player.y = the.screen.height/2 - player.rightImage:getHeight()
	
	local enemy = battle.enemy
	enemy.x = the.screen.width - enemy.leftImage:getWidth() - padding*2
	enemy.y = the.screen.height/2 - enemy.leftImage:getHeight()

	battle.fighters = {player, enemy}
	
	-- for bars and such
	for _,fighter in pairs(battle.fighters) do
		fighter.static = {}
		fighter.static.x = fighter.x 
		fighter.static.y = the.screen.height/2 - fixedHeight
		
		fighter.buffs = {}
	end
	
	player.turnFinished = false; enemy.turnFinished = true
	
	local playerImg = battle.player.rightImage
	local i = 0
	for k,skill in pairs(battle.player.skills) do
		i = i + 1
		table.insert(battle.btn, SkillBtn(battle.player.x + playerImg:getWidth()/2 - SkillBtn.width/2, battle.player.y + fixedHeight + (i * 50), skill))
	end
	
	local lastBtn = battle.btn[#battle.btn]
	battle.endTurnBtn = Button(
		lastBtn.x-10,lastBtn.y+lastBtn.height+80,
		lastBtn.width+20, lastBtn.height+20, 
		"End Turn", 
		function() battle.turnEnd(battle.player) end
	)
end

function battle.showDmg(fighter, dmg)
end

function battle.turnEnd(prevFighter)
	-- prevFighter: Fighter whose turn ends
	-- nextFighter: Fighter whose turn begins.

	local nextFighter
	
	if prevFighter == battle.player then
		nextFighter = battle.enemy
	else
		nextFighter = battle.player
	end

	-- called everytime a turn ends
	prevFighter.turnFinished = true
	nextFighter.turnFinished = false

	if nextFighter == battle.enemy then
		Timer.add(1, function() battle.ai() end)
	end

	prevFighter.energy = prevFighter.maxEnergy
	
	for _,buff in pairs(nextFighter.buffs) do
		buff.effect(nextFighter)
	end
end


function battle.ai()
	local enemy = battle.enemy
	local player = battle.player
	if not enemy.turnFinished then
		if enemy.hp / enemy.maxHP < 0.6 then
			local r = math.random(1,2)
			if r == 1 then enemy.skills.attack:exec(enemy, player)
			elseif r == 2 then enemy.skills.heal:exec(enemy, player) end
		else
			enemy.skills.attack:exec(enemy, player)
		end
		
		Timer.add(1, function() battle.ai() end)
	end
end

function battle:init()
	battle.load()
end

function battle:enter()
	battle.load()
	
	TEsound.stop("music")
	
	battle.music = love.filesystem.getDirectoryItems("assets/music/battle")
    for i=1,#battle.music do battle.music[i] = "/assets/music/battle/"..battle.music[i] end
	
	TEsound.play(battle.music, "bMusic")
	
	love.mouse.setVisible(true)
end

function battle:update(dt)
	for _,btn in pairs(battle.btn) do btn:update(dt) end
	if not battle.player.turnFinished then battle.endTurnBtn:update(dt) end
	
	if battle.player.hp <= 0 then venus.switch(loseState)
	elseif battle.enemy.hp <= 0 then venus.switch(winState)
	end
end

function battle:draw()
	-- tint
	love.graphics.setColor(45,45,55)
	love.graphics.rectangle("fill", 0,0, the.screen.width, the.screen.height)
		
	-- lines
	love.graphics.setColor(0,0,0, 200)
	love.graphics.draw(bgLineImg,bgLineQ,0,0)
	
	love.graphics.setColor(255,255,255)
	
	local player,enemy = battle.player, battle.enemy
	love.graphics.draw(player.rightImage, player.x, player.y)
	love.graphics.draw(enemy.leftImage, enemy.x, enemy.y)
	
	for _,fighter in pairs(battle.fighters) do
		local hpBarX, hpBarY = fighter.static.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.static.y - barHeight*2
		local enBarX, enBarY = fighter.static.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.static.y + fixedHeight
		
		love.graphics.setColor(255,20,20, 150)
		love.graphics.rectangle("line", hpBarX, hpBarY, barWidth, barHeight)
		love.graphics.rectangle("fill", hpBarX, hpBarY, (barWidth/fighter.maxHP)*fighter.hp, barHeight)
			
		love.graphics.setColor(20,20,255, 150)
		love.graphics.rectangle("line", enBarX, enBarY, barWidth, barHeight)
		love.graphics.rectangle("fill", enBarX, enBarY, (barWidth/fighter.maxEnergy)*fighter.energy, barHeight)
	
		love.graphics.setColor(255,255,255)
		love.graphics.print("HP: " .. fighter.hp .. "/" .. fighter.maxHP, hpBarX + 10, hpBarY + barHeight/2 - love.graphics.getFont():getHeight()/2)
		love.graphics.print("Energy: " .. fighter.energy .. "/" .. fighter.maxEnergy, enBarX + 10, enBarY + barHeight/2 - love.graphics.getFont():getHeight()/2)
	end
	
	love.graphics.setColor(255,255,255)
	
	for _,btn in pairs(battle.btn) do btn:draw() end
	
	battle.endTurnBtn:draw()
	if battle.player.turnFinished then
		love.graphics.setColor(0,0,0,140)
		
		local btn = battle.endTurnBtn
		love.graphics.rectangle("fill",btn.x,btn.y,btn.width,btn.height)
	
		love.graphics.setColor(255,255,255)
	end
end

function battle:mousereleased(x,y,buttom)
	for _,btn in pairs(battle.btn) do btn:mousereleased(x,y,button) end
	if not battle.player.turnFinished then battle.endTurnBtn:mousereleased(x,y,button) end
end

function battle:keypressed(key)
	for _,btn in pairs(battle.btn) do btn:keypressed(key) end
end

function battle:leave()
    local enemy = battle.enemy
    local player = battle.player
    
    if enemy.hp <= 0 then
        winState.enemy.att = enemy.attack
        winState.enemy.def = enemy.defense
        
        for i,region in ipairs(map) do
            if region.name == battle.attackedRegion then
                local player = Player:returnCountry() 
                region:changeOwner(player)
            end
            
            -- Deselect all regions
            if region.selected then region.selected = false end
        end
    end
    
    checkIfDead() -- check if any of the countries are dead.
    
    TEsound.stop("bMusic")
    TEsound.playLooping(musicFiles, "music")
    
    startedBattle = false
end
