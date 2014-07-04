battle = {}

local padding = 20
local barWidth, barHeight = 100, 15

function battle.start(player, enemy) -- Sets opponents, and switches to battle gamestate.
	battle.player = nameToCountry(player)
	battle.enemy = nameToCountry(enemy)
	
    Gamestate.switch(battle)
end

startBattle = battle.start

function battle.load()
	battle.btn = {}

	local player = battle.player
	player.x = padding
	player.y = the.screen.height/2 - player.rightImage:getHeight()/2
	
	local enemy = battle.enemy
	enemy.x = the.screen.width - enemy.leftImage:getWidth() - padding*2
	enemy.y = the.screen.height/2 - enemy.leftImage:getHeight()/2

	battle.fighters = {player, enemy}	
end

function battle:init()
	battle.load()
end

function battle:enter()
	battle.load()
	
	for i,skill in ipairs(battle.player.skills) do
		table.insert(battle.btn, SkillBtn(battle.player.x, i, skill))
	end
	
	love.mouse.setVisible(true)
end

function battle:update(dt)
	for _,btn in pairs(battle.btn) do btn:update(dt) end
end

function battle:draw()
	local player,enemy = battle.player, battle.enemy
	love.graphics.draw(player.rightImage, player.x, player.y)
	love.graphics.draw(enemy.leftImage, enemy.x, enemy.y)
	
	for _,fighter in pairs(battle.fighters) do
		love.graphics.setColor(255,20,20)
		love.graphics.rectangle("line", fighter.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.y - barHeight*2, barWidth, barHeight)
		love.graphics.rectangle("fill", fighter.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.y - barHeight*2, (barWidth/fighter.maxHP)*fighter.hp, barHeight)
	
		love.graphics.setColor(20,20,255)
		love.graphics.rectangle("line", fighter.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.y + fighter.leftImage:getHeight() + barHeight*2, barWidth, barHeight)
		love.graphics.rectangle("fill", fighter.x + fighter.leftImage:getWidth()/2 - barWidth/2, fighter.y + fighter.leftImage:getHeight() + barHeight*2, (barWidth/fighter.maxEnergy)*fighter.energy, barHeight)
	end
	
	love.graphics.setColor(255,255,255)
	
	for _,btn in pairs(battle.btn) do btn:draw() end
end

function battle:mousereleased(x,y,buttom)
	for _,btn in pairs(battle.btn) do btn:mousereleased(x,y,button) end
end

function battle:leave()
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
    
    -- Set lose message
    if player.hp <= 0 then
        loseState.msg = "You lose. (No HP left)"
    elseif player.energy <= 0 then
        loseState.msg = "You lose. (No energy left)"
    end
    
    checkIfDead() -- check if any of the countries are dead.
    
    TEsound.stop("bMusic")
    TEsound.playLooping(musicFiles, "music")
    
    startedBattle = false
end
