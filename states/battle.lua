leftCountry = 0
rightCountry = 0

function startBattle(argLeftCountry, argRightCountry) -- Sets opponents, and switched to battle gamestate.
    for _,country in pairs(countries) do
        if country.name == argLeftCountry or argRightCountry then
            if country.name == argLeftCountry then
                leftCountry = country
            elseif country.name == argRightCountry then
                rightCountry = country
            end
        end
    end
    
    Gamestate.switch(battle)
end

battle = {}

function battle:enter()
    love.mouse.setGrabbed(false)
    love.mouse.setVisible(true)
    -- Shortcuts
    player = leftCountry:clone()
    enemy = rightCountry:clone()
    
    player.image = player.rightImage
    player.x = 30
    player.y = 50
    player.buttons = {}
    player.maxHp = player.hp
    
    local btnW = 100
    local btnH = 30
    local btnX = ((player.x + 250) / 2) - btnW/2
    local btnY = player.y + player.image:getHeight() + 70
    for i,skill in ipairs(player.skills) do
        table.insert(player.buttons, 
            Button(btnX, btnY*i, btnW, btnH, skill.name, 
            function()
                if player.energy - skill.energy >= 0 then
                    skill:exec(player, enemy)
                    player.energy = player.energy - skill.energy
                end
            end
            )
        )
    end
    
    enemy.image = enemy.leftImage
    enemy.x = the.screen.width - 250 - 60
    enemy.y = 50
    enemy.maxHp = enemy.hp
    
    barWidth = 150
    barHeight = 20
    player.hpBar = {
        x = ((player.x + 250) / 2) - barWidth/2,
        y = barHeight,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth/ player.maxHp) * player.hp
    } 
    
    player.energyBar = {
        x = player.hpBar.x,
        y = 330,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth / 100) * player.energy
    }

    enemy.hpBar = {
        x = enemy.x + 250/2 - barWidth/2,
        y = 20,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth / enemy.maxHp) * enemy.hp
    }
    
    enemy.energyBar = {
        x = enemy.hpBar.x,
        y = 330,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth / 100) * enemy.energy
    }
        
        
    battleCam = Camera(the.screen.width/2, the.screen.height/2)
end

function battle:update(dt)
    for _,btn in pairs(player.buttons) do
        btn:update()
    end
    
    if player.hp <= 0 or enemy.hp <= 0 then
        Gamestate.switch(game)
    end
    
    player.hpBar.fillWidth = (barWidth/ player.maxHp) * player.hp
    enemy.hpBar.fillWidth = (barWidth / enemy.maxHp) * enemy.hp
    player.energyBar.fillWidth = (barWidth / 100) * player.energy
    enemy.energyBar.fillWidth = (barWidth / 100) * enemy.energy
end

function battle:mousereleased(x,y,button)
    for _,btn in pairs(player.buttons) do
        btn:mousereleased(x,y,button)
    end
end

function battle:draw()
    battleCam:attach()

    local playerScale = 250/player.image:getWidth()
    local enemyScale = 250/enemy.image:getWidth()
    
    love.graphics.push()
    love.graphics.scale(playerScale)
    love.graphics.draw(player.image, player.x, player.y)
    love.graphics.pop()
    
    love.graphics.rectangle("line", player.hpBar.x, player.hpBar.y, player.hpBar.width, player.hpBar.height)
    love.graphics.rectangle("fill", player.hpBar.x, player.hpBar.y, player.hpBar.fillWidth, player.hpBar.height)
    love.graphics.rectangle("line", player.energyBar.x, player.energyBar.y, player.energyBar.width, player.energyBar.height)
    love.graphics.rectangle("fill", player.energyBar.x, player.energyBar.y, player.energyBar.fillWidth, player.energyBar.height)
    
    love.graphics.push()
    love.graphics.scale(enemyScale)
    love.graphics.draw(enemy.image, enemy.x, enemy.y)
    love.graphics.pop()
    
    love.graphics.rectangle("line", enemy.hpBar.x, enemy.hpBar.y, enemy.hpBar.width, enemy.hpBar.height)
    love.graphics.rectangle("fill", enemy.hpBar.x, enemy.hpBar.y, enemy.hpBar.fillWidth, enemy.hpBar.height)
    love.graphics.rectangle("line", enemy.energyBar.x, enemy.energyBar.y, enemy.energyBar.width, enemy.energyBar.height)
    love.graphics.rectangle("fill", enemy.energyBar.x, enemy.energyBar.y, enemy.energyBar.fillWidth, enemy.energyBar.height)
    
    for _,btn in pairs(player.buttons) do
        btn:draw()
    end
    
    battleCam:detach()
end

function battle:leave()
    if enemy.hp <= 0 then
        for _,adjCellColumn in pairs(currAdjCells) do
            for _,adjCell in pairs(adjCellColumn) do
                for _,country in pairs(countries) do
                    if Player.country == country.name then
                        map[adjCell.columnIndex][adjCell.rowIndex] = country:clone()
                    end
                end
            end
        end
    end
    
    -- We want to save map AFTER claiming the cell, but only if enemy is defeated.
    if enemy.hp <= 0 then
        saveMap() 
    end
end
