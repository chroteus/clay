diplScr = {} -- Diplomacy screen
diplScr.margin = 20
diplScr.country = ""
diplScr.enabled = false -- indicates if player clicked on the country to talk

local function randFoeMsg(foe)
    local m = {
        "We, the people of "..foe.name.." curse you. What do you want?",
        "What do you want, "..Player.country.."?",
        "Stop stealing my clay, "..Player.country.."!",
    }
        
    return m[math.random(#m)]
end

local rectW,rectH = 130,80

function diplScr:init()
    diplCam = Camera(the.screen.width/2, the.screen.height/2)
    
    -- a button to go back to list of countries
    diplScr.disBtn = GenericButton(6, "<< Back", function() diplScr.enabled = false end)
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
            Button(the.screen.width/2-rectW/2, ((rectH*1.5)*i)+rectH, rectW, btnH, "Talk", 
                function() 
                    diplScr.country = foe
                    diplScr.enabled = true
                    diplScr.message = randFoeMsg(foe)
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
    else
        diplScr.disBtn:update()
    end
    
    screenBtn:update()
end




function diplScr:draw()
    if not diplScr.enabled then
        diplCam:attach()
        
        for i,foe in ipairs(Player:returnCountry(true).foes) do
            love.graphics.setColor(guiColors.bg)
            love.graphics.rectangle("fill",the.screen.width/2-rectW/2, ((rectH*1.5)*i), rectW, rectH)
            love.graphics.setColor(guiColors.fg)
            love.graphics.rectangle("line",the.screen.width/2-rectW/2, ((rectH*1.5)*i), rectW, rectH)
            love.graphics.printf(foe.name, 0, diplScr.margin*2.5+(rectH*1.5*i), the.screen.width, "center")
            love.graphics.setColor(255,255,255)

            local ball = foe.miniature
            ball:setFilter("nearest", "nearest")
            love.graphics.push()
            love.graphics.scale(2)
            love.graphics.draw(ball, (the.screen.width/4)-(ball:getWidth()/2), (rectH*0.75*i)+diplScr.margin/4) --0.75 because it's scaled
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
    
    else -- if talking with country
        love.graphics.setFont(bigFont)
        love.graphics.draw(diplScr.country.leftImage, the.screen.width/2 - diplScr.country.leftImage:getWidth()/2, the.screen.height/2 - diplScr.country.leftImage:getHeight())
        love.graphics.printf(diplScr.country.name, 0, diplScr.margin, the.screen.width, "center")
        love.graphics.printf(diplScr.message, the.screen.width/4, the.screen.height/2 + diplScr.margin, the.screen.width/2, "center")
        love.graphics.setFont(gameFont)
        
        diplScr.disBtn:draw()
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
    else
        diplScr.disBtn:mousereleased(x,y,button)
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
