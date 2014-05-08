game = {}

function game:init()
    game.mapDrawn = true
    initMap()

    --[[ REWRITE ]]
    -- If death message was printed already previous game, don't print it again at the start of the game.
    for _,country in pairs(countries) do
        local num = 0
    end
    
    ------------
    --Info Box--
    infoBox = {}
    infoBox.delay = 0.5
    infoBox.delayReset = infoBox.delay
    infoBox.width = 280
    infoBox.height = 120
    infoBox.x = the.screen.width/2-infoBox.width/2
    infoBox.y = 5
    infoBox.countryName = ""
    infoBox.name = ""

    function infoBox:update(dt)
        for _,region in pairs(map) do
            if PointWithinShape(region.vertices, mapMouse.x, mapMouse.y) then
                self.countryName = countries[region.id].name
                self.name = region.name
            end
        end
    end

    function infoBox:draw()
        guiRect(self.x, self.y, self.width, self.height)
        love.graphics.setColor(guiColors.fg)
        if self.name ~= "" then
            love.graphics.printf(self.name..", "..self.countryName, self.x+5, self.y+5, self.width, "left")
        end
        love.graphics.setColor(255,255,255)
    end
    
    game.editModeString = "Q: Select country, E: Exit, B: Disable cam limits, LMB: Place a point, RMB: Undo/Remove point, LShift + RMB: Delete a region"
end

function game:enter()
    if prefs.firstPlay then
        prefs.firstPlay = false
        savePrefs()
    end

    love.graphics.setFont(gameFont)
    
    enteredMap()
    game.timerHandle = Timer.addPeriodic(2, function() checkIfDead() end)
    
    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)
end

function game:update(dt)
    if not DialogBoxes:present() then
        updateMap(dt)
        msgBox:update(dt)
        randEvent(dt)
        infoBox:update(dt)
    end
    
    DialogBoxes:update(dt)
end

function game:draw()
    
    drawMap() 
     
    -- GUI
    local guiRectH = 30
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.printf("| "..Player.country.." | Level: "..Player.level.." | XP: "..Player.xp.."/"..Player.xpToUp.." | Money: "..Player.money.."G", 10, the.screen.height-25, the.screen.width, "left")
    
    if prefs.firstPlay then
        love.graphics.printf("Press 'Tab'", 0, the.screen.height-25, the.screen.width-15, "right")
    end
    
    love.graphics.setColor(255,255,255)
    
    DialogBoxes:draw()
    msgBox:draw()
    
    if editMode.enabled then
        bgPrintf(game.editModeString, 1, the.screen.height-50, the.screen.width, "left")
        bgPrintf("Current chosen country: "..editMode.country, 0, the.screen.height-70, the.screen.width, "left")
    else
        if DEBUG then
            bgPrintf("E - Enter edit mode.", 0, the.screen.height-50, the.screen.width, "left")
        end
    end
    
    infoBox:draw()
end

function game:mousepressed(x, y, button)
    if not DialogBoxes:present() then
        mousepressedMap(x, y, button)
    end
end

function game:mousereleased(x,y,button)
    if not DialogBoxes:present() then
        mousereleasedMap(x,y,button)
    else
        DialogBoxes:mousereleased(x,y,button)
    end
end

function game:keyreleased(key)
    if not DialogBoxes:present() then
        if key == "escape" then
            venus.switch(pause)
        elseif key == "tab" then
            venus.switch(transState.lastState)
        end

        if DEBUG then
            if key == "b" then
                if mapBorderCheck then
                    mapBorderCheck = false
                else
                    mapBorderCheck = true
                end
            end
        
            if key == "e" then
                if editMode.enabled then
                    editMode.enabled = false
                else
                    editMode.enabled = true
                end
            end
            
            if editMode.enabled then
                if key == "q" then
                    venus.switch(selection)
                end
            end
        end
    end
end

function game:keypressed(key)
    DialogBoxes:keypressed(key)
end

function game:textinput(t)
    DialogBoxes:textinput(t)
end

function game:leave()
    Timer.cancel(game.timerHandle)
end
