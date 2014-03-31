-- buttons to change between screens
screenBtn = {}

-- add a state here if it needs to be shown
-- syntax to add is as follows: {"name",state}
screenBtn.states = {
    {"Character", charScr},
    {"Diplomacy", diplScr},
}

screenBtn.list = {}

function screenBtn:initialize()
    local w = the.screen.width/#screenBtn.states
    local h = 35
    for i,state in ipairs(screenBtn.states) do
        table.insert(screenBtn.list,
            Button(w*(i-1), the.screen.height-h, w, h, state[1], 
                function() 
                    Gamestate.switch(state[2])
                    transState.lastState = state[2]
                end
            )
        )
    end
end

function screenBtn:update()
    for _,btn in pairs(screenBtn.list) do
        btn:update()
    end
end

function screenBtn:draw()
    love.graphics.setFont(bigFont)
    for _,btn in pairs(screenBtn.list) do
        btn:draw()
    end
    love.graphics.setFont(gameFont)
end

function screenBtn:mousereleased(x,y,button)
    for _,btn in pairs(screenBtn.list) do
        btn:mousereleased(x,y,button)
    end
end
