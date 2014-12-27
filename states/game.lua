game = {}

function game.loadStatusbarText()
    game.statusbarTexts = {Player.country,
                           " Level: "..Player.level,
                           " XP: "..Player.xp.."/"..Player.xpToUp,
                           " Money: "..Player.money.."G"
                          }
end
function game:init()
    initMap()
    for _,country in pairs(countries) do
        country.midpoint = country:_midpoint()
    end
    
    infoBox:init()
    
    game.mapDrawn = true
    
    game.editModeString = "Q: Select country, E: Exit, "
                          .."Toggle regions map: F1, "
						  .."LMB: Place a point RMB: Undo, "
						  .."LShift + RMB: Delete a region"
    
    game.loadStatusbarText()
    
    
    function game.endTutorial()
        prefs.firstPlay = false
        savePrefs()
    end
end

function game:enter()
    if prefs.firstPlay then
        if not game.secondTutMsg then  
            local dbox = DialogBoxes:new(
                "Welcome to Clay! Press TAB to enter character screen and continue tutorial.",
                {"I know how to play, end tutorial", function() game.endTutorial() end}
            )
            
            dbox:defineKey("tab", function() venus.switch(charScr); dbox:hide() end)
            dbox:show()
        else
            DialogBoxes:new(
                "Attacking others is easy. Choose one of your regions "
                .."and all the neighboring regions will be selected.\n "
                .."Clicking a region of a neutral or enemy country "
                .."will trigger a battle.",
                
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
    
    worldTime:start()
    
    if game.borders_map then
        game.regionMapWidth = game.borders_map:getWidth()
        game.regionMapHeight = game.borders_map:getHeight()
        game.borders_map:setFilter("nearest")
    end

    
    game.loadStatusbarText()
end

function game:update(dt)
    if venus.current == game then updateMap(dt) end
    
    msgBox:update(dt)
    randEvent(dt)
    infoBox:update(dt)
end

function game:draw()
    drawMap()
    
    mapCam:attach()
    -- Dev mode region map
    if game.drawRegionMap and game.borders_map then
        local scalex = (mapW*mapImgScale)/game.regionMapWidth
        local scaley = (mapH*mapImgScale*1.16)/game.regionMapHeight

        love.graphics.push()
        love.graphics.scale(scalex, scaley)
        love.graphics.setColor(255,255,255,100)
        love.graphics.draw(game.borders_map, -2,58)
        love.graphics.setColor(255,255,255)
        love.graphics.pop()
    end
    mapCam:detach()

    -- GUI
    local guiRectH = 30
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", 0, the.screen.height-guiRectH, the.screen.width, guiRectH)
    
    local padding = 5
    local sumX = 5
    for i,text in pairs(game.statusbarTexts) do
        love.graphics.print(text, sumX, the.screen.height-25)
        sumX = sumX + gameFont["default"]:getWidth(text) + padding
        love.graphics.line(sumX,the.screen.height-guiRectH, sumX,the.screen.height)
    end
    
    if prefs.firstPlay then
        love.graphics.printf("Press 'Tab'", 0, the.screen.height-25, the.screen.width-15, "right")
    end
    
    love.graphics.setColor(255,255,255)
    
    msgBox:draw()
    
    if editMode.enabled then
        bgPrintf(game.editModeString, 1, the.screen.height-50, the.screen.width, "left")
        bgPrintf("Currently chosen country: "..editMode.country, 0,
        the.screen.height-70, the.screen.width, "left")
    else
        if DEBUG then
            bgPrintf("E - Enter edit mode.", 0, the.screen.height-50, the.screen.width, "left")
        end
    end
    
    if DEBUG then
        bgPrintf("FPS: "..love.timer.getFPS(), -5, the.screen.height-50, the.screen.width, "right")
    end
    
    infoBox:draw()
    
    if not prefs.firstPlay then
		worldTime:draw()
	end
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
    elseif key == "f1" then
        if not game.drawRegionMap then
            game.drawRegionMap = true
        else
            game.drawRegionMap = false
        end
    end
    
    if love.keyboard.isDown("1") and key == "return" then
		Player.money = Player.money + 100
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
        
        if key == "9" then
			Player.money = Player.money + 1
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
    worldTime:stop()
end
