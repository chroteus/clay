charScr = {}
charScr.fadeInit = true
charScr.fadeEnter = true

function charScr:init()
    charScr.char = Player:returnCountry()
    charScr.text = ""
    
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
    
    local function newSkillBtn(yOrder, variable, amount) -- uses skillBtn to create two buttons.
        return skillBtn(1,yOrder,variable,-amount), skillBtn(2,yOrder,variable,amount)
    end
    
    charScr.btn = {
        cont = GenericButton(the.screen.height/2 + 200, "Continue >>", function() venus.switch(game); game.mapDrawn = true end),
    }
    
    local c = charScr.btn
    c.minusAtt,c.plusAtt = newSkillBtn(1, "attack", 1)
    c.minusDef,c.plusDef = newSkillBtn(2, "defense", 1)
end

function charScr:enter()
    if prefs.firstPlay then
        DialogBoxes:new(
            "This is character screen.\n You can change your stats and talk with other nations via diplomacy.",
             {"Close this box", function() game.secondTutMsg = true end}
        ):show()
    end
    
    charScr.text = ""
    love.mouse.setVisible(true)
end

function charScr:update(dt)
    for _,btn in pairs(charScr.btn) do
        btn:update()
    end

    local c = charScr.btn
    if checkCollision(the.mouse.x,the.mouse.y,1,1, c.minusAtt.x, c.minusAtt.y, (c.plusAtt.x+c.plusAtt.width)-c.minusAtt.x, c.minusAtt.height) then
        charScr.text = "Attack: Increases the damage inflicted to enemy."
    elseif checkCollision(the.mouse.x,the.mouse.y,1,1, c.minusDef.x, c.minusDef.y, (c.plusDef.x+c.plusDef.width)-c.minusDef.x, c.minusDef.height) then
        charScr.text = "Defense: Decreases the chance of your clay being taken. Decreases the damage in battles."
    end
end

function charScr:draw()
    local charX = the.screen.width/2 - charScr.char.leftImage:getWidth()/2
    local charY = the.screen.height/2 - 350

    love.graphics.draw(charScr.char.leftImage, charX, charY)
    
    local str = "| Points: "..Player.unspentPoints.." | Attack: "..Player.attack - Player.addAttack.." (+"..Player.addAttack..") | Defense: "..Player.defense - Player.addDefense.." (+"..Player.addDefense..") |" 
    love.graphics.printf(str, 0, charY+270, the.screen.width, "center")
    
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

    love.graphics.printf(charScr.text, the.screen.width/3, charScr.btn.minusDef.y + 80, the.screen.width/3, "center")
    
    DialogBoxes:draw()
end

function charScr:mousereleased(x,y,button)
    for _,btn in pairs(charScr.btn) do
        btn:mousereleased(x,y,button)
    end
end

function charScr:leave()
    Player:returnCountry(true).attack = Player.attack
    Player:returnCountry(true).defense = Player.defense
    
    game.secondTutMsg = true
end
