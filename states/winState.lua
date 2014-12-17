winState = {}

function winState:init()
    winImg = love.graphics.newImage("assets/image/winImg.png")
    winBtn = GenericButton(the.screen.height/2 + 200, "Continue >>", function() Gamestate.switch(game) end)
    
    winXpRect = {
        x = the.screen.width/2 - 150,
        y = the.screen.height/2 + 100,
        fillWidth = 0, -- set in update func
        width = 300,
        height = 40,
        color = {100, 100, 255}
    }
    
    winResultXp = 0
    winMoneyAmnt = 0
end


function winState:enter()
    if prefs.firstPlay then
        DialogBoxes:new(
            "Congratulations! You've won your first battle. From now on, you're on your own. Good luck.",
            {"Finish tutorial", function() game.endTutorial() end}
        ):show()
    end

    local p = Player:returnCountry()
    local netResult = (battle.enemy.defense+battle.enemy.attack) - (p.attack+p.defense)
    
    -- Account for fighters
    for _,fighter in pairs(battle.player.fighters) do
        netResult = netResult - fighter.attack_stat/50
        netResult = netResult - fighter.defense/50
    end
    
    for _,fighter in pairs(battle.enemy.fighters) do
        netResult = netResult + fighter.attack_stat/50
        netResult = netResult + fighter.defense/50
    end
    
    if netResult <= 0 then netResult = 1 end
    
    
    
    math.randomseed(os.time())
    --local xpAmnt = math.random(Player.level*3+math.random(2), Player.level*4+math.random(netResult))
    --local xpAmnt = math.ceil(math.random((netResult/3)*(Player.level/2), (netResult*2)*(Player.level/2)))
    local xpAmnt = math.random(netResult*2*Player.level, netResult*5*Player.level)
    
    local winStartXp = Player.xp
    winFinXp, leveledUp = Player:gainXP(xpAmnt) -- gainXP returns the final xp value, and true if player leveled up
    winResultXp = winFinXp - winStartXp
    
    math.randomseed(math.random(os.time()))
    winMoneyAmnt = math.random(netResult*2*Player.level, netResult*5*Player.level)
    Player:returnCountry():addMoney(winMoneyAmnt)
end

function winState:update(dt)
    winXpRect.fillWidth = (winXpRect.width/Player.xpToUp) * Player.showXP
    
    winBtn:update()
end

function winState:draw()
    local rect = winXpRect
    
    love.graphics.draw(winImg, the.screen.width/2-winImg:getWidth()/2, the.screen.height/2-winImg:getHeight())
    winBtn:draw()
    
    love.graphics.setColor(rect.color)
    love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.fillWidth, rect.height)
   
    love.graphics.setColor(200, 200, 200)
    local fontHeight = (love.graphics.getFont():getHeight())/2
    love.graphics.printf("XP: +"..winResultXp, rect.x + 5, rect.y + rect.height/2 - fontHeight, rect.width, "left")
    
    if leveledUp then
        love.graphics.printf("Level up!", rect.x, rect.y - rect.height/2 - fontHeight, rect.width, "left")
    end
    
    love.graphics.setFont(gameFont[22])
    love.graphics.printf("You've gained "..tostring(winMoneyAmnt).."G !", 0, rect.y+50, the.screen.width, "center")
    love.graphics.setFont(gameFont[16])
        
    love.graphics.setColor(255,255,255)
end

function winState:mousereleased(x, y, button)
    winBtn:mousereleased(x, y, button)
end
