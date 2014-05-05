-- transition state
-- used to save the last state of screenBtn states, and perform various functions.
transState = {}
transState.lastState = charScr -- set in screenBtn

function transState:init()
end

function transState:enter()
    randBg()
    venus.switch(transState.lastState)
end

function transState:draw()
end
