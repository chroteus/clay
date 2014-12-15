-- not to be confused with "fighterScr"
fightersScr = {}

function fightersScr.setCountry(country)
    fightersScr.fighters = country.fighters
end
-------

local function addFighters()
    if fighterScr.fighters == nil then
        fightersScr.setCountry(Player:returnCountry())
    end
    
    local fy = the.screen.height - 200
    local total = #fightersScr.fighters
    local xorder_right = 0 -- for right side
    
    for xOrder,fighter in pairs(fightersScr.fighters) do
        fighter.orig_x = fighter.x
        fighter.orig_y = fighter.y

        if xOrder-1 < math.ceil(total/2) then
            fighter:setPos(the.screen.width/2 - ((xOrder-0.5) * fighter.width), 
                           fy)
        else
            xorder_right = xorder_right + 1
            fighter:setPos(the.screen.width/2 + ((xorder_right-0.5) * fighter.width), 
                           fy)
        end
            -- look down
            fighter:lookAt(fighter.x, fighter.y + 1, {still = true})
    end
end

function fightersScr:init()
    addFighters()
end

function fightersScr:enter()
    love.mouse.setVisible(true)
    addFighters()
end

function fightersScr:update(dt)

end

function fightersScr:draw()
    love.graphics.setFont(gameFont[32])
    love.graphics.printf("Fighters", 0, 60, the.screen.width, "center")
    love.graphics.setFont(gameFont["default"])
    
    for _,fighter in pairs(fightersScr.fighters) do
        fighter:draw(fighter.x, fighter.y, true)
        
        if fighter:collidesWith(the.mouse.x, the.mouse.y, 1,1) then
            love.graphics.printf(fighter.name, fighter.x, fighter.y - 30,
                                 fighter.width, "center")
        end
    end
    
    if #fightersScr.fighters == 0 then
        love.graphics.printf("You have no fighters.", 0, the.screen.height - 200,
                             the.screen.width, "center")
    end
end

function fightersScr:mousereleased(x,y,btn)
    if btn == "l" then
        for _,fighter in pairs(fightersScr.fighters) do
            if fighter:collidesWith(the.mouse.x, the.mouse.y, 1,1) then
                fighterScr.set(fighter)
                Gamestate.switch(fighterScr, "none")
            end
        end
    end
end

function fightersScr:leave()
    for _,fighter in pairs(fightersScr.fighters) do
        fighter.x = fighter.orig_x
        fighter.y = fighter.orig_y
    end
end
