charScr = {}

function charScr:init()
    charScr.char = Player:returnCountry()
    
    charScr.btn = {
        cont = GenericButton(the.screen.height/2 + 200, "Continue >>", function() Gamestate.switch(game) end),
    }
end

function charScr:enter()
    love.mouse.setVisible(true)
end

function charScr:update(dt)
    for _,btn in pairs(charScr.btn) do
        btn:update()
    end
end

function charScr:draw()
    love.graphics.draw(charScr.char.leftImage, the.screen.width - 330, the.screen.height/2 - 250)
    
    for _,btn in pairs(charScr.btn) do
        btn:draw()
    end
end

function charScr:mousereleased(x,y,button)
    for _,btn in pairs(charScr.btn) do
        btn:mousereleased(x,y,button)
    end
end

function charScr:keyreleased(key)
    if key == "c" or key == "escape" then
        Gamestate.switch(game)
    end
end
