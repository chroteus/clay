game = {}

function game:init()
    initMap()

    -- add needed skills for countries (after loading the game)
    for _,country in pairs(countries) do
        if country.name == Player.country then
            country:addSkill("attack")
        else
            country:addSkill("aiAttack")
        end
    end
    
    game.mapDrawn = true
    
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
    infoBox.id = 1

    function infoBox:update(dt)
        for _,region in pairs(map) do
            if PointWithinShape(region.vertices, mapMouse.x, mapMouse.y) then
                self.countryName = countries[region.id].name
                self.name = region.name
                self.region = region
                self.id = region.id
            end
        end
    end

    function infoBox:draw(x,y)
        local x = x or self.x
        local y = y or self.y
        
        guiRect(x, y, self.width, self.height)
        love.graphics.setColor(guiColors.fg)
        if countries[self.id].name ~= "Sea" then
            love.graphics.printf(self.name..", "..self.countryName, x+5, y+5, self.width, "left")
        else
            love.graphics.printf(self.countryName, x+5, y+5, self.width, "left")
        end
        
        love.graphics.setColor(255,255,255)
    end
    
    game.editModeString = "Q: Select country, E: Exit, B: Disable cam limits, LMB: Place a point, RMB: Undo/Remove point, LShift + RMB: Delete a region, LAlt + LMB: Move a point"

    function game.endTutorial()
        prefs.firstPlay = false
        savePrefs()
    end
end

function game:enter()
    if prefs.firstPlay then
        if not game.secondTutMsg then  
            DialogBoxes:new(
                "Welcome to Clay! Press TAB to enter character screen and continue tutorial.",
                {"I know how to play, end tutorial", function() game.endTutorial() end}
            ):show()
        else
            DialogBoxes:new(
                "Attacking others is easy. Choose one of your regions and all the neighboring regions will be selected.\n Clicking a region of a neutral or enemy country will trigger a battle.",
                {"Hide this box.", function() end}
            ):show()
        end
    end

    love.graphics.setFont(gameFont[16])
    
    enteredMap()
    game.timerHandle = Timer.addPeriodic(2, function() checkIfDead() end)
    
    if not prefs.firstPlay then
        love.mouse.setVisible(false)
        love.mouse.setGrabbed(true)
    end
end

function game:update(dt)
    updateMap(dt)
    msgBox:update(dt)
    randEvent(dt)
    infoBox:update(dt)
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
    
    msgBox:draw()
    
    if editMode.enabled then
        bgPrintf(game.editModeString, 1, the.screen.height-50, the.screen.width, "left")
        bgPrintf("Current chosen country: "..editMode.country, 0, the.screen.height-70, the.screen.width, "left")
    else
        if DEBUG then
            bgPrintf("E - Enter edit mode.", 0, the.screen.height-50, the.screen.width, "left")
        end
    end
    
    if DEBUG then
        bgPrintf("FPS: "..love.timer.getFPS(), -5, the.screen.height-50, the.screen.width, "right")
    end
    
    infoBox:draw()
end

function game:mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end

function game:mousereleased(x,y,button)
    mousereleasedMap(x,y,button)
end

function game:keyreleased(key)
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

function game:leave()
    Timer.cancel(game.timerHandle)
end
