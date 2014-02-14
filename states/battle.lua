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
    
    barWidth = 300
    barHeight = 20
    
    player.x = 130
    player.y = 50
    player.isLeft = true
    player.buttons = {}
    
    player.image = {
        data = player.rightImage,
        x = player.x,
        y = player.y
    }
    
    enemy.x = the.screen.width - 330
    enemy.y = 50
    enemy.isRight = true
    enemy.image = {
        data = enemy.leftImage,
        x = enemy.x,
        y = enemy.y
    }
    
    enemy.image.x = enemy.x
    
    SkillBtn = Button:subclass("SkillBtn")
    
    function SkillBtn:initialize(yOrder, skill, func)
        self.x = (player.x + 250) / 3 - 50
        self.y = (player.y + 250+40) + 40*yOrder
        self.width = 200
        self.fillWidth = 200
        self.height = 30
        self.func = func
        self.text = skill.name.." ["..-skill.energy.."]"
        self.hotkey = string.match(skill.name, "%((.?)%)")
        if self.hotkey then self.hotkey = string.lower(self.hotkey) end
        
        Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)

    end

    function SkillBtn:action()
        Button.action(self)
        if self.fillWidth >= self.width-0.0001 then -- Checking for equality doesn't work properly for some reason.
            self.fillWidth = 0
            Timer.tween(self.cooldown, self, {fillWidth = self.width}, "out-quad")
        end
    end

    function SkillBtn:keypressed(key)
        if self.hotkey and string.lower(key) == self.hotkey then
            self:action()
        end
    end
    
    -- Create buttons according to what skills player has.
    for i,skill in ipairs(player.skills) do
        table.insert(player.buttons, SkillBtn(i, skill, function() skill:exec(player, enemy) end))
        
        -- Fills the button depending on this variable.
        player.buttons[i].cooldown = skill.cooldownReset
    end
          
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
        fillWidth = (barWidth / 100) * player.energy,
        
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
        
    -- fighers: A table which is used to reduce duplicate code.
    fighters = {player, enemy}
    
    -- Simple AI
    -- Execute any possible skill (if cooldown is over) every second.
    enemyFightTimerHandle = Timer.addPeriodic(1,
        function()
            for _,skill in pairs(enemy.skills) do
                skill:exec(enemy, player)
            end
        end
    )
    
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
    
        for _,skill in pairs(fighter.skills) do
            skill:update(dt)
        end
    end
end

function battle:mousereleased(x,y,button)
    for _,btn in pairs(player.buttons) do
        btn:mousereleased(x,y,button)
    end
end

function battle:keypressed(key)
    for _,btn in pairs(player.buttons) do
        btn:keypressed(key)
    end
end

function battle:draw()
    battleCam:attach()
    
    for _,fighter in pairs(fighters) do
        love.graphics.draw(fighter.image.data, fighter.image.x, fighter.image.y)
        
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
    -- Claim the cell that we wanted to claim.
    if enemy.hp <= 0 then
        for _,adjCellColumn in pairs(currAdjCells) do
            for _,adjCell in pairs(adjCellColumn) do
                for _,country in pairs(countries) do
                    if Player.country == country.name then
                        if map[adjCell.columnIndex][adjCell.rowIndex].name ~= "Sea" and map[adjCell.columnIndex][adjCell.rowIndex].isSelected then
                            map[adjCell.columnIndex][adjCell.rowIndex] = country:clone()
                        end
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
