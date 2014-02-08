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
    player.maxHP = player.hp
    
    player:addSkill("heal")
    
    SkillBtn = Button:subclass("SkillBtn")
    
    function SkillBtn:initialize(yOrder, skill, func)
        self.x = (player.x + 250) / 2 - 50
        self.y = (player.y + player.image:getHeight()+40) + 40*yOrder
        self.width = 100
        self.fillWidth = 100
        self.height = 30
        self.func = func
        self.text = skill.name.." ("..-skill.energy..")"
        
        
        Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
    end
    
    for i,skill in ipairs(player.skills) do
        table.insert(player.buttons, SkillBtn(i, skill, function() skill:exec(player, enemy) end))
        
        -- Fills the button depending on this variable.
        player.buttons[i].cooldown = skill.cooldownReset
    end
    
    enemy.image = enemy.leftImage
    enemy.x = the.screen.width - 250 - 60
    enemy.y = 50
    enemy.maxHP = enemy.hp
    
    barWidth = 150
    barHeight = 20
    player.hpBar = {
        x = ((player.x + 250) / 2) - barWidth/2,
        y = barHeight,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth/ player.maxHP) * player.hp
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
        fillWidth = (barWidth / enemy.maxHP) * enemy.hp
    }
    
    enemy.energyBar = {
        x = enemy.hpBar.x,
        y = 330,
        width = barWidth,
        height = barHeight,
        fillWidth = (barWidth / 100) * enemy.energy
    } 
        
    -- fighers: A table which holds both player and enemy. Used to reduce 
    -- duplicate code in update and draw functions.
    fighters = {player, enemy}
    
    battleCam = Camera(the.screen.width/2, the.screen.height/2)
end

function battle:update(dt)
    for _,btn in pairs(player.buttons) do
        btn:update()
    end
    
    if player.hp <= 0 or enemy.hp <= 0 then
        Gamestate.switch(game)
    end
    
    for _,fighter in pairs(fighters) do
        fighter.hpBar.fillWidth = (barWidth/ fighter.maxHP) * fighter.hp
        fighter.energyBar.fillWidth = (barWidth / 100) * fighter.energy
        
        if fighter.hp > fighter.maxHP then fighter.hp = fighter.maxHP end
    end
    
    for _,skill in pairs(player.skills) do
        skill:update(dt)
    end
end

function battle:mousereleased(x,y,button)
    for _,btn in pairs(player.buttons) do
        btn:mousereleased(x,y,button)
    end
end

function battle:draw()
    battleCam:attach()
    
    for _,fighter in pairs(fighters) do
        local fighterScale = 250/fighter.image:getWidth()
        love.graphics.push()
        love.graphics.scale(fighterScale)
        love.graphics.draw(fighter.image, fighter.x, fighter.y)
        love.graphics.pop()
        
        love.graphics.setColor(190,30,30)
        love.graphics.rectangle("line", fighter.hpBar.x, fighter.hpBar.y, fighter.hpBar.width, fighter.hpBar.height)
        love.graphics.rectangle("fill", fighter.hpBar.x, fighter.hpBar.y, fighter.hpBar.fillWidth, fighter.hpBar.height)
        
        love.graphics.setColor(0,150,200)
        love.graphics.rectangle("line", fighter.energyBar.x, fighter.energyBar.y, fighter.energyBar.width, fighter.energyBar.height)
        love.graphics.rectangle("fill", fighter.energyBar.x, fighter.energyBar.y, fighter.energyBar.fillWidth, fighter.energyBar.height)
    
        love.graphics.setColor(255,255,255)
        
        local fontHeight = (love.graphics.getFont():getHeight())/2
        love.graphics.printf("Energy: "..fighter.energy.."/100", fighter.energyBar.x+5, fighter.energyBar.y + barHeight/2 - fontHeight, barWidth, "left")
        love.graphics.printf("Health "..fighter.hp.."/"..fighter.maxHP, fighter.hpBar.x+5, fighter.hpBar.y + barHeight/2 - fontHeight, barWidth, "left")
        
        love.graphics.printf("Attack: "..fighter.attack, fighter.energyBar.x, fighter.energyBar.y - barHeight, barWidth, "left")
        love.graphics.printf("Defense: "..fighter.defense, fighter.energyBar.x, fighter.energyBar.y - barHeight, barWidth, "right")
    end
    
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
    
    -- We want to save map AFTER claiming the cell, but only if the enemy is defeated.
    if enemy.hp <= 0 then
        saveMap() 
    end
    
    startedBattle = false
end
