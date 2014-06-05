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

function battle:init()
    function battle.load()
    
        player = leftCountry:clone()
        enemy = rightCountry:clone()
        
        globalAttackName = "Attack"
        
        barWidth = 300
        barHeight = 20
        
        player.x = 130
        player.y = the.screen.height/2 - 250
        player.isLeft = true
        player.buttons = {}
        
        player.image = {
            data = player.rightImage,
            --x = player.x-250/2,
            --y = player.y
        }
        
        player.image.x = player.x-player.image.data:getWidth()/2 + 50
        player.image.y = the.screen.height/2 - player.image.data:getHeight()/2 - 100
        
        enemy.x = the.screen.width - 330
        enemy.y = player.y
        enemy.isRight = true
        enemy.image = {
            data = enemy.leftImage
        }
        enemy.image.x = enemy.x-enemy.image.data:getWidth()/2 + 50
        enemy.image.y = the.screen.height/2 - enemy.image.data:getHeight()/2 - 100
        enemy.image.x = enemy.x
        
         -- Create buttons according to what skills player has.
        for i,skill in ipairs(player.skills) do
            table.insert(player.buttons, SkillBtn(i, skill, function() skill:exec(player, enemy) end))
            
            -- Fills the button depending on this variable.
            player.buttons[i].cooldown = skill.cooldownReset
        end
        
        for i,btn in ipairs(player.buttons) do
            if btn.name == globalAttackName then
                btn.hotkey = " "
            end
        end
              
        local padding = 100
        player.hpBar = {
            x = ((player.x + 250) / 2) - barWidth/2,
            y = player.y - padding,
            width = barWidth,
            height = barHeight,
            fillWidth = (barWidth/ player.maxHP) * player.hp
        } 
        
        player.energyBar = {
            x = player.hpBar.x,
            y = player.y+250+padding,
            width = barWidth,
            height = barHeight,
            fillWidth = (barWidth / player.maxEnergy) * player.energy,
            
        }

        enemy.hpBar = {
            x = enemy.x + 250/2 - barWidth/2,
            y = enemy.y - padding,
            width = barWidth,
            height = barHeight,
            fillWidth = (barWidth / enemy.maxHP) * enemy.hp
        }
        
        enemy.energyBar = {
            x = enemy.hpBar.x,
            y = enemy.y+250+padding,
            width = barWidth,
            height = barHeight,
            fillWidth = (barWidth / enemy.maxEnergy) * enemy.energy
        } 
        
        for _,skill in pairs(player.skills) do
            if skill.name == globalAttackName then
                skill.slider.x = player.hpBar.x
                skill.slider.y = player.hpBar.y + player.hpBar.height + 5
            end
        end
            
        fighters = {player, enemy}
    end

    battle.load()
    
    battle.music = love.filesystem.getDirectoryItems("assets/music/battle")
    for i=1,#battle.music do battle.music[i] = "/assets/music/battle/"..battle.music[i] end
    
    battleCam = Camera(the.screen.width/2, the.screen.height/2)
end

function battle:enter()
    love.mouse.setGrabbed(false)
    love.mouse.setVisible(true)
    
    battle.load()
    
    TEsound.stop("music")
    TEsound.playLooping(battle.music, "bMusic")
    
    -- VERY Simple AI
    -- Execute any possible skill (if cooldown is over) every second.
    enemyFightTimerHandle = Timer.addPeriodic(1,
        function()
            for _,skill in pairs(enemy.skills) do
                skill:exec(enemy, player)
            end
        end
    )
end

function battle:update(dt)
    for _,btn in pairs(player.buttons) do
        btn:update()
    end
    
    if enemy.hp <= 0 or enemy.energy <= 0 then
        Gamestate.switch(winState)
    elseif player.hp <= 0 or player.energy <= 0 then
        Gamestate.switch(loseState)
    end
    
    for _,fighter in pairs(fighters) do
        fighter.hpBar.fillWidth = (barWidth/ fighter.maxHP) * fighter.hp
        fighter.energyBar.fillWidth = (barWidth / fighter.maxEnergy) * fighter.energy
    
        for _,skill in pairs(fighter.skills) do
            skill:update(dt)
            
            if skill.name == globalAttackName then
                skill:updateSlider(dt)
            end
        end
    end
end

function battle:mousereleased(x,y,button)
    for _,btn in pairs(player.buttons) do
        if btn.name ~= globalAttackName then
            btn:mousereleased(x,y,button)
        end
    end
end

function battle:keypressed(key)
    for _,btn in pairs(player.buttons) do
        btn:keypressed(key)
    end
    for _,fighter in pairs(fighters) do
        for _,skill in pairs(fighter.skills) do
            if skill.name == globalAttackName then
                skill:keypressed(key)
            end
        end
    end
end

function battle:draw()
    battleCam:attach()

    love.graphics.setColor(60, 220, 60)
    love.graphics.rectangle("fill", 0, the.screen.height/2 - 100, the.screen.width, the.screen.height)
    love.graphics.setColor(155, 220, 255)
    love.graphics.rectangle("fill", 0, 0, the.screen.width, the.screen.height/2 - 100)
    love.graphics.setColor(255,255,255)
    
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
        love.graphics.printf("Energy: "..fighter.energy.."/"..fighter.maxEnergy, fighter.energyBar.x+5, fighter.energyBar.y + barHeight/2 - fontHeight, barWidth, "left")
        love.graphics.printf("Health "..fighter.hp.."/"..fighter.maxHP, fighter.hpBar.x+5, fighter.hpBar.y + barHeight/2 - fontHeight, barWidth, "left")
        
        love.graphics.printf("Attack: "..fighter.attack, fighter.energyBar.x, fighter.energyBar.y - barHeight, barWidth, "left")
        love.graphics.printf("Defense: "..fighter.defense, fighter.energyBar.x, fighter.energyBar.y - barHeight, barWidth, "right")
    end
    
    for _,btn in pairs(player.buttons) do
        if btn.name ~= globalAttackName then
            btn:draw()
        end
    end
    
    for _,skill in pairs(player.skills) do
        if skill.name == globalAttackName then
            skill:drawSlider()
        end
    end
    
    battleCam:detach()
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
