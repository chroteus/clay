charScr = {}

function charScr:init()
    charScr.char = Player:returnCountry()
    
    local function skillBtn(xOrder, yOrder, variable, amount)
        local numText = ""
        if amount > 0 then numText = "+" end
        
        local function upgFn()
            if Player[variable] + amount > 0 then
                if numText == "+" then
                    if Player.unspentPoints > 0 then
                        Player[variable] = Player[variable] + amount
                        Player.unspentPoints = Player.unspentPoints - 1
                    end
                else
                    if Player.unspentPoints >= 0 then
                        Player[variable] = Player[variable] + amount
                        Player.unspentPoints = Player.unspentPoints + 1
                    end
                end
            end
        end
        
        return Button((the.screen.width/2-250+50*xOrder) + 100*xOrder, (the.screen.height/2-100) + 70*yOrder, 50, 50, "["..numText..amount.."]", function() upgFn() end)
    end
    
    charScr.btn = {
        cont = GenericButton(the.screen.height/2 + 200, "Continue >>", function() Gamestate.switch(game) end),
        minusAtt = skillBtn(1, 1, "attack", -1),
        plusAtt = skillBtn(2, 1, "attack", 1),
        minusDef = skillBtn(1, 2, "defense", -1),
        plusDef = skillBtn(2, 2, "defense", 1),
    }
end

function charScr:enter()
    love.mouse.setVisible(true)
    randBg()
end

function charScr:update(dt)
    for _,btn in pairs(charScr.btn) do
        btn:update()
    end
end

function charScr:draw()
    local charX = the.screen.width/2 - charScr.char.leftImage:getWidth()/2
    local charY = the.screen.height/2 - 350

    love.graphics.draw(charScr.char.leftImage, charX, charY)
    
    local str = "| Points: "..Player.unspentPoints.." | Attack: "..Player.attack.." | Defense: "..Player.defense.." |" 
    love.graphics.printf(str, 0, charY+charScr.char.leftImage:getHeight()+10, the.screen.width, "center")
    
    for _,btn in pairs(charScr.btn) do
        btn:draw()
    end

    local padding = 5
    local function drawText(btn, text)
        love.graphics.setColor(guiColors.bg)
        love.graphics.rectangle("fill", btn.x+btn.width+padding, btn.y, 100-padding*2, 50)
        love.graphics.setColor(guiColors.fg)
        love.graphics.rectangle("line", btn.x+btn.width+padding, btn.y, 100-padding*2, 50)
        love.graphics.printf(text, btn.x+btn.width, btn.y+btn.height/2-love.graphics.getFont():getHeight()/2, 100, "center")
        love.graphics.setColor(255,255,255)
    end

    drawText(charScr.btn.minusAtt, "Attack")
    drawText(charScr.btn.minusDef, "Defense")
    
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

function charScr:leave()
    Player:returnCountry(true).attack = Player.attack
    Player:returnCountry(true).defense = Player.defense
end
