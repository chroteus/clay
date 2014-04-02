diplScr = {} -- Diplomacy screen
diplScr.margin = 20
diplScr.country = ""
diplScr.enabled = false -- indicates if player clicked on the country to talk

local rectW,rectH = 130,80

function diplScr:init()
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
end

function diplScr:enter()
    love.mouse.setVisible(true)
    
    love.graphics.setFont(bigFont)
    
    if #nameToCountry(Player.country).foes == 0 then
        diplScr.noFoes = true
    else
        diplScr.noFoes = false
    end
    
    diplScr.btn = {}
    local btnH = 30
    for i,foe in ipairs(Player:returnCountry(true).foes) do
        table.insert(diplScr.btn,
            Button(the.screen.width/2-rectW/2, (rectW+(btnH/3))*i, rectW, btnH, "Talk", 
                function() 
                    diplScr.country = foe
                    diplScr.enabled = true
                end
            )
        )
    end
end

function diplScr:update(dt)
    if not diplScr.enabled then
        -- Converting camera to mouse coordinates so that mouse's coordinates would be correct.
        the.mouse.x, the.mouse.y = diplCam:mousepos()
        
        for _,btn in pairs(diplScr.btn) do
            btn:update()
        end
    end
    
    screenBtn:update()
end




function diplScr:draw()
    if not diplScr.enabled then
        diplCam:attach()
        
        for i,foe in ipairs(Player:returnCountry(true).foes) do
            love.graphics.setColor(guiColors.bg)
            love.graphics.rectangle("fill",the.screen.width/2-rectW/2, (60*i), rectW, rectH)
            love.graphics.setColor(guiColors.fg)
            love.graphics.rectangle("line",the.screen.width/2-rectW/2, (60*i), rectW, rectH)
            love.graphics.printf(foe.name, 0, diplScr.margin+(90*i), the.screen.width, "center")
            love.graphics.setColor(255,255,255)

            local ball = foe.miniature
            ball:setFilter("nearest", "nearest")
            love.graphics.push()
            love.graphics.scale(2)
            love.graphics.draw(ball, (the.screen.width/4)-(ball:getWidth()/2), (diplScr.margin+((50/2)*i))-ball:getHeight()/2)
            love.graphics.pop()
        end
        
        love.graphics.setFont(bigFont)
        if diplScr.noFoes then
            love.graphics.printf("You have no enemies!", 0, diplScr.margin+50, the.screen.width, "center")
            
        else
             love.graphics.printf("Foes", 0, diplScr.margin, the.screen.width, "center")
        end
        
        love.graphics.setFont(gameFont)
        
        for _,btn in pairs(diplScr.btn) do
            btn:draw()
        end
        
        diplCam:detach()
    else
        love.graphics.draw(diplScr.country.leftImage, the.screen.width/2 - diplScr.country.leftImage:getWidth()/2, the.screen.height/2 - 350)
    end
    
    screenBtn:draw()
end

function diplScr:mousepressed(x,y,button)
    if button == "wu" then
        Timer.tween(0.2, diplCam, {y = diplCam.y - 40}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, diplCam, {y = diplCam.y + 40}, "out-quad")
    end
end

function diplScr:mousereleased(x,y,button)
    screenBtn:mousereleased(x,y,button)
    
    if not diplScr.enabled then
        for _,btn in pairs(diplScr.btn) do
            btn:mousereleased(x,y,button)
        end
    end
end

function diplScr:keyreleased(key)
    if key == "tab" or key == "escape" then
        Gamestate.switch(game)
    end
end

function diplScr:leave()
    love.graphics.setFont(gameFont)
end
