countrySelect = {}

function countrySelect:init()
    countrySelectBtn = {}
    for i, country in ipairs(countries) do
        if country.name ~= "Sea" then
            table.insert(countrySelectBtn,
                GenericButton(i-1, country.name, 
                    function() 
                        Player.country = country.name
                        Player.attack, Player.defense = country.attack, country.defense 
                        Gamestate.switch(tutorial)
                    end)
            )
        end
    end
    
    countryCam = Camera(the.screen.width/2, the.screen.height/2)
end

function countrySelect:update(dt)
    -- Converting camera to mouse coordinates.
    the.mouse.x, the.mouse.y = countryCam:mousepos()

    for _,button in pairs(countrySelectBtn) do
        button:update()
    end
    
    if countryCam.y < 288 then
        countryCam.y = 288
    end
end

function countrySelect:draw()
    countryCam:attach()
    love.graphics.printf("Scroll down!", 0, 40, the.screen.width, "center")
    
    for _,button in pairs(countrySelectBtn) do
        button:draw()
    end
    
    countryCam:detach()
end

function countrySelect:mousepressed(x, y, button)
    if button == "wu" then
        Timer.tween(0.2, countryCam, {y = countryCam.y - 25}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, countryCam, {y = countryCam.y + 25}, "out-quad")
    end
end

function countrySelect:mousereleased(x, y, button)
    for _,button in pairs(countrySelectBtn) do
        button:mousereleased(x, y, button)
    end
end
