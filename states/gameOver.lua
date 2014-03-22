gameOver = {}

function gameOver:init()
    local function endGame()
        love.filesystem.remove("map.lua")
        Gamestate.switch(menu)
    end

    gameOver.img = love.graphics.newImage("assets/image/gameOverImg.png")
    gameOver.menuBtn = GenericButton(the.screen.height/2 + 100, "<< Menu", function() endGame() end)
end

function gameOver:enter()
    love.mouse.setVisible(true)
end

function gameOver:update(dt)
    gameOver.menuBtn:update()
end

function gameOver:draw()
    love.graphics.draw(gameOver.img, the.screen.width/2-gameOver.img:getWidth()/2, the.screen.height/2-gameOver.img:getHeight())
    love.graphics.printf("You've lost all of your land.", 0, the.screen.height/2 + 50, the.screen.width, "center") 
    gameOver.menuBtn:draw()
end

function gameOver:mousereleased(x,y,button)
    gameOver.menuBtn:mousereleased(x,y,button)
end
