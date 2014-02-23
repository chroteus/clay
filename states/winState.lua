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
end

function winState:enter()
    local xpAmnt = math.random(Player.level*3+math.random(2), Player.level*Player.level+math.random(5))
    
    local winStartXp = Player.xp
    local winFinXp = Player:gainXP(xpAmnt) -- gainXP returns the final xp value


    winResultXp = winFinXp - winStartXp
end

function winState:update(dt)
    winXpRect.fillWidth = (winXpRect.width/Player.xpToUp) * Player.xp
    
    winBtn:update()
end

function winState:draw()
    love.graphics.draw(winImg, the.screen.width/2-winImg:getWidth()/2, the.screen.height/2-winImg:getHeight())
    winBtn:draw()
    
    love.graphics.setColor(winXpRect.color)
    love.graphics.rectangle("line", winXpRect.x, winXpRect.y, winXpRect.width, winXpRect.height)
    love.graphics.rectangle("fill", winXpRect.x, winXpRect.y, winXpRect.fillWidth, winXpRect.height)
   
    love.graphics.setColor(50, 50, 50)
    local fontHeight = (love.graphics.getFont():getHeight())/2
    love.graphics.printf("XP: +"..winResultXp, winXpRect.x + 5, winXpRect.y + winXpRect.height/2 - fontHeight, winXpRect.width, "left")
    love.graphics.setColor(255,255,255)
end

function winState:mousereleased(x, y, button)
    winBtn:mousereleased(x, y, button)
end
