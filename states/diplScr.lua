diplScr = {} -- Diplomacy screen
diplScr.margin = 10

function diplScr:init()
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
end

function diplScr:enter()
    diplScr.foeList = {}
    for _,foe in pairs(Player:returnCountry(true).foes) do
        table.insert(diplScr.foeList, foe)
    end
end

function diplScr:update(dt)

end

function diplScr:draw()
    diplCam:attach()
    
    for _,foe in ipairs(diplScr.foeList) do
        love.graphics.printf(foe.name, 0, diplScr.margin + 50, the.screen.width, "center")
    end        

    diplCam:detach()
end

function diplScr:mousepressed(x,y,button)
    if button == "wu" then
        Timer.tween(0.1, diplCam, {y = diplCam.y - 20})
    elseif button == "wd" then
        Timer.tween(0.1, diplCam, {y = diplCam.y + 20})
    end
end

function diplScr:keyreleased(key)
    if key == "tab" or key == "escape" then
        Gamestate.switch(game)
    end
end
