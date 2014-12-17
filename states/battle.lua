battle = {}

local padding = 40
local fixedHeight = 250
local barWidth, barHeight = 200, 30
local energyTime = 0.5

function battle.start(player, enemy) -- Sets opponents, and switches to battle gamestate.
	battle.player = nameToCountry(player)
	battle.enemy = nameToCountry(enemy)
	
	-- controlling random events
	battle.player.inBattle = true
	battle.enemy.inBattle = true
	
	battle.player.hp = battle.player.maxHP
	battle.enemy.hp = battle.enemy.maxHP
    
    battle.arena = Arena{x = 0, y = 0, width = the.screen.width, height = the.screen.height}
    
    local playerGroup = FighterGroup(battle.player.fighters)
    playerGroup:addEnemy(battle.enemy)
    battle.arena:add(playerGroup):to("allies")
    playerGroup:setPos(padding*2 + barWidth, the.screen.height/2)
    playerGroup:lookAt(the.screen.width - barWidth - padding*2,
                      the.screen.height/2, {still = true})
    
    local enemyGroup = FighterGroup(battle.enemy.fighters)
    enemyGroup:addEnemy(battle.player)
    battle.arena:add(enemyGroup):to("enemies")
    enemyGroup:setPos(0,0) -- without setting group's pos, width cannot be taken
    enemyGroup:setPos(the.screen.width - barWidth - padding*2 - enemyGroup:getWidth() - 100 ,
                      the.screen.height/2)
    enemyGroup:lookAt(padding*2 + barWidth, the.screen.height/2, {still = true})

    
    battle.arena:start()
	
    Gamestate.switch(battle)
end

-- backwards compatiblity
startBattle = battle.start


function battle.load()
	battle.btn = {}

	local player = battle.player
    local enemy = battle.enemy
    
	player.x = padding
	player.y = the.screen.height/2 - player.rightImage:getHeight()
    player.width = player.rightImage:getWidth()
	player.height = player.rightImage:getHeight()
    
	enemy.x = the.screen.width - enemy.leftImage:getWidth() - padding
	enemy.y = the.screen.height/2 - enemy.leftImage:getHeight()
    enemy.width = enemy.leftImage:getWidth()    
    enemy.height = enemy.leftImage:getHeight()
    
	battle.fighters = {player, enemy}
	
	-- for bars and such
	for _,fighter in pairs(battle.fighters) do
		fighter.static = {}
		fighter.static.x = fighter.x 
		fighter.static.y = the.screen.height/2 - fixedHeight
		
		fighter.buffs = {}
		
		fighter.dmgColor = {255,255,255,255}
	end
	
	--player.turnFinished = false; enemy.turnFinished = true
	
	local playerImg = battle.player.rightImage
	local i = 0
	for k,skill in pairs(battle.player.skills) do
		i = i + 1
		table.insert(battle.btn, SkillBtn(battle.player.x + playerImg:getWidth()/2 - SkillBtn.width/2, battle.player.y + fixedHeight + (i * 50), skill))
	end
    
	--[[
	local lastBtn = battle.btn[#battle.btn]
	battle.endTurnBtn = Button(
		lastBtn.x-10,lastBtn.y+lastBtn.height+80,
		lastBtn.width+20, lastBtn.height+20, 
		"End Turn", 
		function() battle.turnEnd(battle.player) end
	)]]
end

function battle.flash(fighter, color)
	if fighter.dmgColor then
		battle.timer:tween(0.1, fighter.dmgColor, {[1] = color[1]})
		battle.timer:tween(0.1, fighter.dmgColor, {[2] = color[2]})
		battle.timer:tween(0.1, fighter.dmgColor, {[3] = color[3]})
		
		battle.timer:add(0.11,
			function()
				battle.timer:tween(0.2, fighter.dmgColor, {[1] = 255})
				battle.timer:tween(0.2, fighter.dmgColor, {[2] = 255})
				battle.timer:tween(0.2, fighter.dmgColor, {[3] = 255})
			end
		)
	end
end

--[[

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
		battle.timer:add(1, function() battle.ai() end)
	end

	prevFighter.energy = prevFighter.maxEnergy
	
	-- progress 5-10 days
	for i=1,math.random(5,10) do
		worldTime:start(0)
		
		-- progress everything according to days passed
		game:update(worldTime.dayLength)
	end
	worldTime:stop()

	-- apply all buffs
	for _,fighter in pairs(battle.fighters) do
		for k,buff in pairs(fighter.buffs) do
			if buff.duration <= 1 then
				table.remove(fighter.buffs, k)
			else
				buff:exec(fighter)
			end
		end
	end
    
    for _,fighter in pairs(battle.fighters) do
        for _,country_fighter in pairs(fighter.fighters) do
            country_fighter:ai()
        end
    end
end
]]

function battle.ai()
	local enemy = battle.enemy
	local player = battle.player
    
    if enemy.hp / enemy.maxHP < 0.6 then
        local r = math.random(1,2)
        if     r == 1 then enemy.skills.attack:exec(enemy, player)
        elseif r == 2 then enemy.skills.heal:exec(enemy, player) end
    else
        enemy.skills.attack:exec(enemy, player)
    end
end


-- state funcs
function battle:init()
	battle.load()
	battle.timer = Timer.new()
end

function battle:enter()
	battle.load()
	
    for _,fighter in pairs(battle.fighters) do
        battle.timer:addPeriodic(energyTime, 
            function()
                fighter.energy = math.clamp(0, fighter.energy+1, fighter.maxEnergy)
            end)
    end
    
    battle.timer:addPeriodic(energyTime, battle.ai)
    
	TEsound.stop("music")
	battle.music = love.filesystem.getDirectoryItems("assets/music/battle")
    for i=1,#battle.music do battle.music[i] = "/assets/music/battle/"..battle.music[i] end
	TEsound.play(battle.music, "bMusic")
    
	love.mouse.setVisible(true)
end

function battle:update(dt)
	battle.timer:update(dt)

	for _,btn in pairs(battle.btn) do btn:update(dt) end
	--if not battle.player.turnFinished then battle.endTurnBtn:update(dt) end
	
	if battle.player.hp <= 0 then venus.switch(loseState)
	elseif battle.enemy.hp <= 0 then venus.switch(winState)
	end
    
    battle.arena:update(dt)
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
	
	if player.dmgColor then love.graphics.setColor(player.dmgColor) end
	love.graphics.draw(player.rightImage, player.x, player.y)
	if enemy.dmgColor  then love.graphics.setColor(enemy.dmgColor) end
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
	
		for i,buff in pairs(fighter.buffs) do
			local x = enBarX + ((i-1)*50)
			local y = enBarY - 50
			local fontHeight = love.graphics.getFont():getHeight()
			love.graphics.draw(buff.image,  x,y)
			bgPrintf(buff.duration, x, 
					y + buff.image:getHeight()/2-fontHeight/2, 
					buff.image:getWidth(), "center")
		end
	end
	
	love.graphics.setColor(255,255,255)
	
	for _,btn in pairs(battle.btn) do btn:draw() end
	
	--[[battle.endTurnBtn:draw()
	if battle.player.turnFinished then
		love.graphics.setColor(0,0,0,140)
		
		local btn = battle.endTurnBtn
		love.graphics.rectangle("fill",btn.x,btn.y,btn.width,btn.height)
	
		love.graphics.setColor(255,255,255)
	end
	]]
	
	------------------
	local msgx = the.screen.width/2  - msgBox.width/2
	local msgy = the.screen.height/2 - msgBox.height/2 - 200
	
	msgBox:draw(msgx, msgy)
	
	local timeh = 30
	guiRect(msgx, msgy+msgBox.height, msgBox.width, timeh)
	local font = love.graphics.getFont()
	worldTime:draw(
		msgx + msgBox.width/2 -  font:getWidth(worldTime.str)/2,
		msgy + msgBox.height + timeh/2 - font:getHeight()/2
	)
    
    battle.arena:draw()
end

function battle:mousereleased(x,y,button)
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
    
    for _,fighter in pairs(battle.fighters) do
		fighter.buffs = {}
		fighter.hp = fighter.maxHP
		fighter.energy = fighter.maxEnergy
		fighter.inBattle = false
	end
    
    
	battle.timer:clear()
    startedBattle = false
end
