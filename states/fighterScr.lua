-- not to be confused with "fightersScr", which is plural "fighters"
fighterScr = {}

function fighterScr.set(fighter)
    fighterScr.fighter = fighter
end

function fighterScr:enter()
    if fighterScr.fighter == nil then 
        error("Set fighter to display with fighterScr.set") 
    end
end

function fighterScr:update(dt)
    local fighter = fighterScr.fighter
    fighter.anim[fighter.anim_state]:update(dt)
    screenBtn:update(dt)
end

function fighterScr:draw()
    screenBtn:draw()
    
    love.graphics.setColor(20,20,20,128)
    love.graphics.rectangle("fill", 0,0,the.screen.width,the.screen.height)
    love.graphics.setColor(255,255,255)
    
    local fighter = fighterScr.fighter
    fighter:draw()
    
    love.graphics.setFont(gameFont[20])
    love.graphics.printf("ATT: " .. fighter.attack_stat,
                         fighter.x-5, fighter.y +fighter.height + 15, fighter.width, "center")

    love.graphics.printf("DEF: " .. fighter.defense,
                         fighter.x-5, fighter.y + fighter.height + 35,
                         fighter.width, "center")
    
    love.graphics.setFont(gameFont["default"])
end

function fighterScr:mousereleased(x,y,btn)
    if btn == "l" and y < screenBtn.list[1].y then
        Gamestate.switch(fightersScr, "none")
    end
    
    screenBtn:mousereleased(x,y,btn)
end

function fighterScr:keyreleased(key)
    if key == "tab" or key == "escape" then
        Gamestate.switch(fightersScr, "none")
    end
end
