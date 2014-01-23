menu = {}

function menu:init()
    menuButtons = {
        -- GenericButton(order, text, action)
        start = GenericButton(1, "Start", function() Gamestate.switch(countrySelect) end),
        quit = GenericButton(2, "Exit", function() love.event.quit() end)
}
end

function menu:update(dt)
    for _,button in pairs(menuButtons) do
        button:update()
    end
end

function menu:draw()
    for _,button in pairs(menuButtons) do
        button:draw()
    end
end

function menu:mousereleased(x,y,button)
    if button == "l" then
        for _,button in pairs(menuButtons) do
            button:mousereleased(x,y,button)
        end
    end
end
