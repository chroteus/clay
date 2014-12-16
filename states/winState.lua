winState = {}

winState.enemy = {
    att = 0,
    def = 0
}

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
    local netResult = (winState.enemy.def+winState.enemy.att) - (p.attack+p.defense)
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
    love.graphics.draw(winImg, the.screen.width/2-winImg:getWidth()/2, the.screen.height/2-winImg:getHeight())
    winBtn:draw()
    
    love.graphics.setColor(winXpRect.color)
    love.graphics.rectangle("line", winXpRect.x, winXpRect.y, winXpRect.width, winXpRect.height)
    love.graphics.rectangle("fill", winXpRect.x, winXpRect.y, winXpRect.fillWidth, winXpRect.height)
   
    love.graphics.setColor(200, 200, 200)
    local fontHeight = (love.graphics.getFont():getHeight())/2
    love.graphics.printf("XP: +"..winResultXp, winXpRect.x + 5, winXpRect.y + winXpRect.height/2 - fontHeight, winXpRect.width, "left")
    
    if leveledUp then
        love.graphics.printf("Level up!", winXpRect.x, winXpRect.y - winXpRect.height/2 - fontHeight, winXpRect.width, "left")
    end
    
    love.graphics.setFont(gameFont[22])
    love.graphics.printf("You've gained "..tostring(winMoneyAmnt).."G !", 0, winXpRect.y+50, the.screen.width, "center")
    love.graphics.setFont(gameFont[16])
        
    love.graphics.setColor(255,255,255)
end

function winState:mousereleased(x, y, button)
    winBtn:mousereleased(x, y, button)
end
